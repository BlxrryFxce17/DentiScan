import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  const ScanUploadScreen({
    super.key,
    this.preselectedAssetPath,
    this.customBytes,
    this.customFileName,
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
    _scannerAnimController.dispose();
    super.dispose();
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

    final provider = context.read<DentalRecordsProvider>();
    final parsed = await provider.processDocumentImage(_imageBytes!, filePath: _sourceIdentifier);

    if (parsed != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewEditScreen(
            initialRecord: parsed,
            documentImageBytes: _imageBytes,
          ),
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
          children: const [
            Text(
              'Document Preprocessing & OCR',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Align, enhance and neural-extract clinical data',
              style: TextStyle(color: AppTheme.slate400, fontSize: 11),
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
            tooltip: 'AI Engine Settings',
            icon: const Icon(Icons.psychology_rounded, color: AppTheme.accentCyan),
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
          // Document Image Preview with Viewfinder
          Center(
            child: _isLoadingImage
                ? const CircularProgressIndicator(color: AppTheme.primaryTeal)
                : _imageBytes != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
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

                          // Document Scanner Reticle Corners
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: _buildReticle(),
                              ),
                            ),
                          ),

                          // Laser Scan Line Animation during OCR
                          if (provider.isProcessingOcr)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _scannerAnimController,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(0, (_scannerAnimController.value * 2) - 1),
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.accentCyan.withValues(alpha: 0.0),
                                              AppTheme.accentCyan,
                                              Colors.white,
                                              AppTheme.accentCyan,
                                              AppTheme.accentCyan.withValues(alpha: 0.0),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.accentCyan.withValues(alpha: 0.6),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
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

          // OCR Processing Modal Overlay
          if (provider.isProcessingOcr)
            Container(
              color: Colors.black.withValues(alpha: 0.80),
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.slate800,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.psychology_rounded, size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Neural OCR Pipeline',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.ocrStatusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.slate300, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: provider.ocrProgress > 0 ? provider.ocrProgress : null,
                          backgroundColor: AppTheme.slate700,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Extracting 9 Categories & INR',
                            style: TextStyle(color: AppTheme.slate400, fontSize: 11),
                          ),
                          Text(
                            '${(provider.ocrProgress * 100).toInt()}%',
                            style: const TextStyle(color: AppTheme.accentCyan, fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    final engineLabel = engineMode == 'mlkit'
                        ? 'Google ML Kit (Offline)'
                        : (engineMode == 'gemini' ? 'Gemini 1.5 Flash Vision' : 'Auto (Gemini + ML Kit Fallback)');
                    final icon = engineMode == 'mlkit'
                        ? Icons.phonelink_setup_rounded
                        : (engineMode == 'gemini' ? Icons.cloud_done_rounded : Icons.auto_awesome_rounded);

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
                              'AI Engine: $engineLabel',
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
                              'Pinch to zoom • Ready for neural extraction',
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
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Extract & Structure', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
