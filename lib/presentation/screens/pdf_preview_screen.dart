import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/patient_record.dart';
import '../../core/utils/pdf_exporter.dart';
import '../../core/theme/app_theme.dart';

class PdfPreviewScreen extends StatelessWidget {
  final PatientRecord record;

  const PdfPreviewScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = 'Dental_Record_${record.patientName.replaceAll(RegExp(r'\s+'), '_')}_${record.id.substring(0, 6)}.pdf';

    return Scaffold(
      backgroundColor: AppTheme.slate800,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.slate900,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.patientName} - Clinical PDF',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Print, Share or Export Document',
              style: TextStyle(fontSize: 11, color: AppTheme.slate400),
            ),
          ],
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfExporter.generateDentalReportPdf(record),
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      ),
    );
  }
}
