import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/patient_record.dart';

class PdfExporter {
  static Future<Uint8List> generateDentalReportPdf(PatientRecord record) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(record),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.teal700, thickness: 2),
            pw.SizedBox(height: 12),

            // Patient & Doctor Information Grid
            _buildInfoGrid(record, dateFormat),
            pw.SizedBox(height: 16),

            // Clinical Summary (Chief Complaint & Diagnosis)
            _buildClinicalSummary(record),
            pw.SizedBox(height: 14),

            // Medical, Dental, Allergies & Habits
            _buildHistoryAndAllergies(record),
            pw.SizedBox(height: 16),

            // Tooth Procedures & Treatment Plan Table
            _buildProceduresTable(record),
            pw.SizedBox(height: 14),

            // Prescriptions (if any)
            if (record.prescriptions.isNotEmpty) ...[
              _buildPrescriptionsTable(record),
              pw.SizedBox(height: 14),
            ],

            // Financial Breakdown & Signatures
            _buildFinancialAndSignature(record, dateFormat),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Foxwel.ai Dental Intelligence Engine • Confidential Medical Record',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(PatientRecord record) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              record.clinicName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'DEPARTMENT OF DENTAL MEDICINE & ORAL SURGERY',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.teal700, letterSpacing: 0.5),
            ),
            if (record.clinicContact != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                'Contact: ${record.clinicContact}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
            border: pw.Border.all(color: PdfColors.teal700, width: 1),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'CLINICAL EXAMINATION RECORD',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.Text(
                'Record ID: ${record.id.substring(0, 8).toUpperCase()}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoGrid(PatientRecord record, DateFormat dateFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PATIENT INFORMATION', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                pw.SizedBox(height: 4),
                _fieldRow('Full Name', record.patientName),
                _fieldRow('Age / Gender', '${record.age != null ? "${record.age} yrs" : "N/A"} • ${record.gender ?? "N/A"}'),
                if (record.phone != null) _fieldRow('Phone', record.phone!),
                _fieldRow('Visit Date', dateFormat.format(record.recordDate)),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ATTENDING DENTIST', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                pw.SizedBox(height: 4),
                _fieldRow('Doctor', record.doctorName),
                if (record.doctorQualification != null) _fieldRow('Qualification', record.doctorQualification!),
                if (record.registrationNumber != null) _fieldRow('Registration #', record.registrationNumber!),
                _fieldRow('OCR Confidence', '${(record.ocrConfidence * 100).toStringAsFixed(0)}% verified'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _fieldRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 80, child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static pw.Widget _buildClinicalSummary(PatientRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.teal300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CHIEF COMPLAINT & SYMPTOMS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
          pw.SizedBox(height: 3),
          pw.Text(record.chiefComplaint, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
          if (record.clinicalDiagnosis != null && record.clinicalDiagnosis!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text('DIAGNOSIS & CLINICAL FINDINGS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
            pw.SizedBox(height: 2),
            pw.Text(record.clinicalDiagnosis!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryAndAllergies(PatientRecord record) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('MEDICAL & DENTAL HISTORY', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Medical: ${record.medicalHistory.isNotEmpty ? record.medicalHistory.join(", ") : "No significant medical issues reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Dental: ${record.dentalHistory.isNotEmpty ? record.dentalHistory.join(", ") : "None reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: record.allergies.isNotEmpty ? PdfColors.red50 : PdfColors.grey50,
              border: pw.Border.all(color: record.allergies.isNotEmpty ? PdfColors.red300 : PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ALLERGIES & HABITS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: record.allergies.isNotEmpty ? PdfColors.red900 : PdfColors.teal800)),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Allergies: ${record.allergies.isNotEmpty ? record.allergies.join(", ") : "NKDA (None reported)"}',
                  style: pw.TextStyle(fontSize: 8, fontWeight: record.allergies.isNotEmpty ? pw.FontWeight.bold : pw.FontWeight.normal, color: record.allergies.isNotEmpty ? PdfColors.red900 : PdfColors.grey800),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Habits: ${record.habits.isNotEmpty ? record.habits.join(", ") : "None reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProceduresTable(PatientRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PROCEDURES & TOOTH DETAILS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(3.0),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal50),
              children: [
                _tableCell('Tooth #', isHeader: true),
                _tableCell('Procedure / Treatment', isHeader: true),
                _tableCell('Surface', isHeader: true),
                _tableCell('Status', isHeader: true),
                _tableCell('Est. Cost', isHeader: true, alignRight: true),
              ],
            ),
            ...record.toothProcedures.map(
              (p) => pw.TableRow(
                children: [
                  _tableCell('#${p.toothNumber}'),
                  _tableCell(p.procedureName),
                  _tableCell(p.surface ?? 'General'),
                  _tableCell(p.status),
                  _tableCell(p.estimatedCost != null ? 'Rs. ${p.estimatedCost!.toStringAsFixed(2)}' : '-', alignRight: true),
                ],
              ),
            ),
          ],
        ),
        if (record.treatmentPlan.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text('Overall Treatment Plan: ${record.treatmentPlan}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
        ],
      ],
    );
  }

  static pw.Widget _buildPrescriptionsTable(PatientRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PRESCRIPTION (Rx)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3.0),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2.0),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal50),
              children: [
                _tableCell('Medication', isHeader: true),
                _tableCell('Dosage', isHeader: true),
                _tableCell('Duration', isHeader: true),
                _tableCell('Instructions', isHeader: true),
              ],
            ),
            ...record.prescriptions.map(
              (rx) => pw.TableRow(
                children: [
                  _tableCell(rx.medicineName),
                  _tableCell(rx.dosage),
                  _tableCell(rx.duration),
                  _tableCell(rx.instructions ?? 'As directed'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFinancialAndSignature(PatientRecord record, DateFormat dateFormat) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Financial Table
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.SizedBox(height: 4),
                _financialRow('Total Estimated Cost', 'Rs. ${record.estimatedCost.toStringAsFixed(2)}'),
                _financialRow('Insurance Coverage', '-Rs. ${record.insuranceCovered.toStringAsFixed(2)}'),
                _financialRow('Advance / Copay Paid', '-Rs. ${record.advancePaid.toStringAsFixed(2)}'),
                pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                _financialRow('Balance Due', 'Rs. ${record.balanceDue.toStringAsFixed(2)}', isBold: true),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        // Signature Block
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 20),
              pw.Container(
                width: 150,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 1)),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(record.doctorName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Authorized Dental Surgeon', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              pw.Text('Date: ${dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _financialRow(String label, String amount, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(amount, style: pw.TextStyle(fontSize: 8.5, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: isBold ? PdfColors.teal900 : PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: isHeader ? 8.5 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.teal900 : PdfColors.grey800,
        ),
      ),
    );
  }
}
