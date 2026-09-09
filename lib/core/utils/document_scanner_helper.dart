import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/patient_record.dart';
import '../../presentation/screens/scan_upload_screen.dart';
import '../../presentation/widgets/sample_picker_sheet.dart';
import '../theme/app_theme.dart';

class DocumentScannerHelper {
  /// Opens the document scanner modal bottom sheet with camera, gallery,
  /// file upload, and sample options. If [existingRecord] is provided, rescanned
  /// or uploaded documents are tagged to overwrite that specific visit.
  /// If [existingBytes] is provided, it also offers an option to re-evaluate the existing document.
  static void openScannerModal(
    BuildContext context, {
    PatientRecord? existingRecord,
    Uint8List? existingBytes,
    String? existingFileName,
  }) {
    if (existingBytes != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  existingRecord != null ? 'Rescan & Overwrite Visit' : 'Rescan Options',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slate900),
                ),
                const SizedBox(height: 4),
                Text(
                  existingRecord != null
                      ? 'Re-evaluate current document or upload a new photo to update visit for ${existingRecord.patientName}'
                      : 'Choose how you want to re-evaluate this dental record',
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.slate400),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.slate200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal, size: 22),
                    ),
                    title: const Text('Re-scan Current Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Adjust contrast, rotate 90°, or re-run AI OCR', style: TextStyle(fontSize: 12, color: AppTheme.slate600)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanUploadScreen(
                            customBytes: existingBytes,
                            customFileName: existingFileName ?? 'Document_Rescan.jpg',
                            existingRecord: existingRecord,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.slate200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentCyan, size: 22),
                    ),
                    title: const Text('Capture or Upload New Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Take a new photo or select from gallery to overwrite', style: TextStyle(fontSize: 12, color: AppTheme.slate600)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showSamplePickerSheet(context, existingRecord: existingRecord);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      _showSamplePickerSheet(context, existingRecord: existingRecord);
    }
  }

  static void _showSamplePickerSheet(BuildContext context, {PatientRecord? existingRecord}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SamplePickerSheet(
        isOverwriteMode: existingRecord != null,
        overwritePatientName: existingRecord?.patientName,
        onSelectAsset: (assetPath) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                preselectedAssetPath: assetPath,
                existingRecord: existingRecord,
              ),
            ),
          );
        },
        onCaptureCamera: () {
          captureCamera(context, existingRecord: existingRecord);
        },
        onPickGallery: () {
          pickGallery(context, existingRecord: existingRecord);
        },
        onPickCustomFile: () {
          pickCustomFile(context, existingRecord: existingRecord);
        },
      ),
    );
  }

  static Future<void> captureCamera(BuildContext context, {PatientRecord? existingRecord}) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 92);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                customBytes: bytes,
                customFileName: 'Camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
                existingRecord: existingRecord,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e'), backgroundColor: AppTheme.accentCoral),
        );
      }
    }
  }

  static Future<void> pickGallery(BuildContext context, {PatientRecord? existingRecord}) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                customBytes: bytes,
                customFileName: photo.name,
                existingRecord: existingRecord,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        pickCustomFile(context, existingRecord: existingRecord);
      }
    }
  }

  static Future<void> pickCustomFile(BuildContext context, {PatientRecord? existingRecord}) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                customBytes: bytes,
                customFileName: file.name,
                existingRecord: existingRecord,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker error: $e'), backgroundColor: AppTheme.accentCoral),
        );
      }
    }
  }
}
