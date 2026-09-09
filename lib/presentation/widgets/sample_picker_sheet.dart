import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DentalSamplePreset {
  final String title;
  final String subtitle;
  final String assetPath;
  final String typeTag; // "Handwritten", "Printed Form", "Skewed Mobile"
  final Color tagColor;
  final IconData icon;

  const DentalSamplePreset({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.typeTag,
    required this.tagColor,
    required this.icon,
  });
}

class SamplePickerSheet extends StatelessWidget {
  final Function(String assetPath) onSelectAsset;
  final VoidCallback onCaptureCamera;
  final VoidCallback onPickGallery;

  static const List<DentalSamplePreset> presets = [
    DentalSamplePreset(
      title: 'Handwritten Dental Prescription',
      subtitle: 'Dr. Arthur Pendelton • SmileCraft Clinic (RCT #46, Cefuroxime Rx)',
      assetPath: 'assets/samples/sample_1_handwritten_rx.jpg',
      typeTag: 'Handwritten',
      tagColor: AppTheme.primaryTeal,
      icon: Icons.draw_rounded,
    ),
    DentalSamplePreset(
      title: 'Printed Clinical Chart & Billing',
      subtitle: 'Dr. Evelyn Reed • Apex Dental (Scaling, #14 Composite, Insurance)',
      assetPath: 'assets/samples/sample_2_printed_chart.jpg',
      typeTag: 'Printed Form',
      tagColor: AppTheme.accentCyan,
      icon: Icons.receipt_long_rounded,
    ),
    DentalSamplePreset(
      title: 'Skewed Smartphone Record',
      subtitle: 'Dr. Michael Chang • Family Dentistry (Tooth #11 Trauma, Shade A2)',
      assetPath: 'assets/samples/sample_3_skewed_record.jpg',
      typeTag: 'Skewed / Real-life',
      tagColor: AppTheme.accentAmber,
      icon: Icons.crop_rotate_rounded,
    ),
  ];

  const SamplePickerSheet({
    super.key,
    required this.onSelectAsset,
    required this.onCaptureCamera,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Scan or Upload Record',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slate900, letterSpacing: -0.2),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Click photo with camera or choose from gallery',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.slate400),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppTheme.slate400),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action 1: Click Picture with Camera
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onCaptureCamera();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Click Picture with Camera',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Open device camera to snap prescription or chart',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Action 2: Upload Image from Gallery
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onPickGallery();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upload from Photo Gallery',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.slate900),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select any JPG, PNG photo or document screenshot',
                          style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryTeal, size: 16),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppTheme.slate200)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR TEST BENCHMARK SAMPLES',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.slate400),
                  ),
                ),
                Expanded(child: Divider(color: AppTheme.slate200)),
              ],
            ),
          ),

          ...presets.map((preset) => _buildPresetTile(context, preset)),
        ],
      ),
    );
  }

  Widget _buildPresetTile(BuildContext context, DentalSamplePreset preset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onSelectAsset(preset.assetPath);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: preset.tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(preset.icon, color: preset.tagColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            preset.title,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.slate900),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: preset.tagColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            preset.typeTag,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: preset.tagColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.subtitle,
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.slate400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.slate400),
            ],
          ),
        ),
      ),
    );
  }
}
