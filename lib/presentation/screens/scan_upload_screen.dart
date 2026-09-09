import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/patient_record.dart';
import '../providers/dental_records_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_processor.dart';
import '../../services/hive_storage_service.dart';
import '../widgets/ai_settings_dialog.dart';
import 'review_edit_screen.dart';

class ScanUploadScreen extends StatefulWidget {
  final String? preselectedAssetPath;
  final Uint8List? customBytes;
  final String? customFileName;
  final PatientRecord? existingRecord;

  const ScanUploadScreen({
    super.key,
    this.preselectedAssetPath,
    this.customBytes,
    this.customFileName,
    this.existingRecord,
  });

  @override
  State<ScanUploadScreen> createState() => _ScanUploadScreenState();
}

class _ScanUploadScreenState extends State<ScanUploadScreen> with SingleTickerProviderStateMixin {
  Uint8List? _imageBytes;
  String? _sourceIdentifier;
  bool _isLoadingImage = true;
  bool _contrastEnhanced = false;
  late AnimationController _scannerAnimController;
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _scannerAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    HapticFeedback.selectionClick();
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      final x = -position.dx * 1.5;
      final y = -position.dy * 1.5;
      final zoomed = Matrix4.identity()
        ..setEntry(0, 0, 2.5)
        ..setEntry(1, 1, 2.5)
        ..setEntry(0, 3, x)
        ..setEntry(1, 3, y);
      _transformationController.value = zoomed;
    }
  }

  Future<void> _loadImage() async {
    setState(() => _isLoadingImage = true);

    if (widget.customBytes != null) {
      _imageBytes = widget.customBytes;
      _sourceIdentifier = widget.customFileName ?? 'Custom Document';
    } else if (widget.preselectedAssetPath != null) {
      final data = await rootBundle.load(widget.preselectedAssetPath!);
      _imageBytes = data.buffer.asUint8List();
      _sourceIdentifier = widget.preselectedAssetPath;
    }

    setState(() => _isLoadingImage = false);
  }

  void _rotateImage() {
    if (_imageBytes == null) return;
    setState(() {
      _imageBytes = ImageProcessor.rotate90(_imageBytes!);
    });
  }

  Future<void> _toggleContrast() async {
    if (_imageBytes == null) return;
    setState(() => _isLoadingImage = true);
    final processed = await ImageProcessor.preprocessDocument(
      _imageBytes!,
      enhanceContrast: !_contrastEnhanced,
    );
    setState(() {
      _imageBytes = processed.bytes;
      _contrastEnhanced = !_contrastEnhanced;
      _isLoadingImage = false;
    });
  }

  Future<void> _executeOcr() async {
    if (_imageBytes == null) return;

    final isCustomImage = widget.preselectedAssetPath == null &&
        (_sourceIdentifier == null ||
            (!_sourceIdentifier!.contains('sample_') && !_sourceIdentifier!.contains('assets/samples/')));

    if (kIsWeb && isCustomImage && !HiveStorageService.hasGeminiApiKey()) {
      final shouldConfigure = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.psychology_rounded, color: AppTheme.accentCyan, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gemini AI Key Needed',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: const Text(
            'To transcribe custom uploaded documents and handwriting in the browser, Google Gemini Vision AI is used.\n\nPlease enter your free Gemini API key to proceed.',
            style: TextStyle(color: AppTheme.slate300, fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.slate400)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enter API Key'),
            ),
          ],
        ),
      );

      if (shouldConfigure == true && mounted) {
        await showDialog(
          context: context,
          builder: (_) => const AiSettingsDialog(),
        );
      }

      if (!HiveStorageService.hasGeminiApiKey()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A Gemini API key is required to scan custom documents on Web.'),
              backgroundColor: Colors.amber,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    _scannerAnimController.reset();
    _scannerAnimController.repeat(reverse: true);

    final provider = context.read<DentalRecordsProvider>();
    final parsed = await provider.processDocumentImage(_imageBytes!, filePath: _sourceIdentifier);

    if (parsed != null && mounted) {
      final recordToReview = widget.existingRecord != null
          ? parsed.copyWith(
              id: widget.existingRecord!.id,
              createdAt: widget.existingRecord!.createdAt,
              patientName: (parsed.patientName.trim().isNotEmpty && parsed.patientName.toLowerCase() != 'unknown')
                  ? parsed.patientName
                  : widget.existingRecord!.patientName,
            )
          : parsed;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewEditScreen(
            initialRecord: recordToReview,
            documentImageBytes: _imageBytes,
            isRescanOverwrite: widget.existingRecord != null,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.ocrStatusMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentalRecordsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingRecord != null ? 'Rescan Visit' : 'Scan Document',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.existingRecord != null
                  ? 'Overwriting visit for ${widget.existingRecord!.patientName}'
                  : 'Review image and extract clinical notes',
              style: const TextStyle(color: AppTheme.slate400, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Rotate 90°',
            icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
            onPressed: _rotateImage,
          ),
          IconButton(
            tooltip: _contrastEnhanced ? 'Reset Contrast' : 'Enhance Contrast',
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _contrastEnhanced ? AppTheme.accentCyan.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _contrastEnhanced ? Icons.contrast_rounded : Icons.exposure_rounded,
                color: _contrastEnhanced ? AppTheme.accentCyan : Colors.white,
              ),
            ),
            onPressed: _toggleContrast,
          ),
          IconButton(
            tooltip: 'Scanner Settings',
            icon: const Icon(Icons.tune_rounded, color: AppTheme.accentCyan),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => const AiSettingsDialog(),
              );
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Overwrite Visit Information Banner
          if (widget.existingRecord != null)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B48).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_rounded, color: AppTheme.accentCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rescanning Visit: ${widget.existingRecord!.patientName}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'New photo or file will overwrite this visit\'s extracted notes in Hive.',
                            style: TextStyle(color: AppTheme.slate300, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Document Image Preview with Viewfinder
          Center(
            child: _isLoadingImage
                ? const CircularProgressIndicator(color: AppTheme.primaryTeal)
                : _imageBytes != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onDoubleTapDown: _handleDoubleTapDown,
                            onDoubleTap: _handleDoubleTap,
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              minScale: 0.8,
                              maxScale: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Document Scanner Reticle Corners
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: _buildReticle(),
                              ),
                            ),
                          ),

                          // Mobile Gesture Hint Pill
                          Positioned(
                            bottom: 12,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.pinch_rounded, size: 14, color: Colors.white70),
                                    SizedBox(width: 6),
                                    Text(
                                      'Double-tap or pinch to inspect handwriting',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Animated Scanner Laser Line during Scanning
                          if (provider.isProcessingOcr)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _scannerAnimController,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(0, (_scannerAnimController.value * 2) - 1),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Laser beam
                                          Container(
                                            height: 3,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.accentCyan.withValues(alpha: 0.0),
                                                  AppTheme.accentCyan.withValues(alpha: 0.8),
                                                  Colors.white,
                                                  AppTheme.accentCyan.withValues(alpha: 0.8),
                                                  AppTheme.accentCyan.withValues(alpha: 0.0),
                                                ],
                                                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.accentCyan.withValues(alpha: 0.8),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Subtle glow wash
                                          Container(
                                            height: 24,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  AppTheme.accentCyan.withValues(alpha: 0.18),
                                                  AppTheme.accentCyan.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white70),
                      ),
          ),

          // Clean, Non-Intrusive Bottom Scanning Pill
          if (provider.isProcessingOcr)
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scanning Document...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.ocrStatusMessage.isNotEmpty
                                ? provider.ocrStatusMessage
                                : 'Reading text...',
                            style: const TextStyle(
                              color: AppTheme.slate400,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(provider.ocrProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppTheme.accentCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Control Panel
          if (!provider.isProcessingOcr)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.slate800.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.slate700),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    final engineMode = HiveStorageService.getOcrEngineMode();
                    final engineLabel = switch (engineMode) {
                      'consensus' => 'Double-Check Mode (High Accuracy)',
                      'gemini' => 'Google Cloud Reader',
                      'mistral' => 'Mistral Cloud Reader',
                      'mlkit' => 'Offline Mode',
                      _ => 'Smart Auto (Recommended)',
                    };
                    final icon = switch (engineMode) {
                      'consensus' => Icons.fact_check_rounded,
                      'gemini' => Icons.cloud_done_rounded,
                      'mistral' => Icons.cloud_outlined,
                      'mlkit' => Icons.wifi_off_rounded,
                      _ => Icons.auto_awesome_rounded,
                    };

                    return InkWell(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => const AiSettingsDialog(),
                        );
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.slate700),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 13, color: AppTheme.accentCyan),
                            const SizedBox(width: 6),
                            Text(
                              'Reader: $engineLabel',
                              style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.tune_rounded, size: 12, color: AppTheme.slate400),
                          ],
                        ),
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sourceIdentifier ?? 'Document',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pinch to zoom or rotate',
                              style: TextStyle(color: AppTheme.slate400, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _executeOcr,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(widget.existingRecord != null ? Icons.sync_rounded : Icons.document_scanner_rounded, size: 20),
                        label: Text(
                          widget.existingRecord != null ? 'Scan & Overwrite' : 'Scan Document',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReticle() {
    return Stack(
      children: [
        // Top Left
        Align(
          alignment: Alignment.topLeft,
          child: _cornerBracket(isTop: true, isLeft: true),
        ),
        // Top Right
        Align(
          alignment: Alignment.topRight,
          child: _cornerBracket(isTop: true, isLeft: false),
        ),
        // Bottom Left
        Align(
          alignment: Alignment.bottomLeft,
          child: _cornerBracket(isTop: false, isLeft: true),
        ),
        // Bottom Right
        Align(
          alignment: Alignment.bottomRight,
          child: _cornerBracket(isTop: false, isLeft: false),
        ),
      ],
    );
  }

  Widget _cornerBracket({required bool isTop, required bool isLeft}) {
    const size = 26.0;
    const thickness = 3.0;
    const color = AppTheme.accentCyan;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BracketPainter(isTop: isTop, isLeft: isLeft, thickness: thickness, color: color),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final double thickness;
  final Color color;

  _BracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
