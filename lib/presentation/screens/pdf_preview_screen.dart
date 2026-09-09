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
      backgroundColor: AppTheme.slate900,
      appBar: AppBar(
        backgroundColor: AppTheme.slate900,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.patientName} — Clinical Report',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Document ID: ${record.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 11, color: AppTheme.slate400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Print Report',
            icon: const Icon(Icons.print_rounded, color: AppTheme.accentCyan),
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (format) => PdfExporter.generateDentalReportPdf(record),
                name: fileName,
              );
            },
          ),
          IconButton(
            tooltip: 'Download / Share PDF',
            icon: const Icon(Icons.share_rounded, color: AppTheme.primaryTeal),
            onPressed: () async {
              final bytes = await PdfExporter.generateDentalReportPdf(record);
              await Printing.sharePdf(bytes: bytes, filename: fileName);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfExporter.generateDentalReportPdf(record),
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        useActions: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      ),
    );
  }
}
