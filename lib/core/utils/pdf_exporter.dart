import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/patient_record.dart';

class PdfExporter {
  static const _primaryColor = PdfColor.fromInt(0xFF0F766E); // Deep Teal
  static const _secondaryColor = PdfColor.fromInt(0xFF0D9488); // Teal
  static const _headerBg = PdfColor.fromInt(0xFFF0FDFA); // Light Mint
  static const _cardBg = PdfColor.fromInt(0xFFF8FAFC); // Clean Slate Card
  static const _borderColor = PdfColor.fromInt(0xFFCBD5E1); // Slate Border
  static const _textDark = PdfColor.fromInt(0xFF0F172A); // Slate 900
  static const _textMuted = PdfColor.fromInt(0xFF64748B); // Slate 500

  static Future<Uint8List> generateDentalReportPdf(PatientRecord record) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        build: (pw.Context context) {
          return [
            // Elegant Medical Clinic Header
            _buildHeader(record, dateFormat),
            pw.SizedBox(height: 14),

            // Patient & Attending Dentist Information Grid
            _buildInfoGrid(record, dateFormat),
            pw.SizedBox(height: 14),

            // Clinical Summary (Chief Complaint & Diagnosis)
            _buildClinicalSummary(record),
            pw.SizedBox(height: 14),

            // Medical History, Dental History & Allergies
            _buildHistoryAndAllergies(record),
            pw.SizedBox(height: 14),

            // Tooth Procedures & Treatment Plan
            _buildProceduresOrTreatmentPlan(record),
            pw.SizedBox(height: 14),

            // Prescriptions (Rx)
            if (record.prescriptions.isNotEmpty) ...[
              _buildPrescriptionsTable(record),
              pw.SizedBox(height: 14),
            ],

            // Care Advice & Follow-up Recall (if any)
            if (record.advice != null || record.nextVisit != null) ...[
              _buildAdviceAndFollowup(record),
              pw.SizedBox(height: 14),
            ],

            // Financial Summary & Signature Block
            _buildFinancialAndSignature(record, dateFormat),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 14),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DentiScan Clinical Intelligence System | Confidential Dental Medical Document',
                  style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(PatientRecord record, DateFormat dateFormat) {
    final clinicTitle = record.clinicName.trim().isNotEmpty
        ? record.clinicName.trim().toUpperCase()
        : 'DENTAL SPECIALTY CLINIC';

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primaryColor, width: 2.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  clinicTitle,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'DEPARTMENT OF DENTAL MEDICINE & ORAL HEALTHCARE',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: _secondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (record.clinicContact != null && record.clinicContact!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Contact: ${record.clinicContact}',
                    style: const pw.TextStyle(fontSize: 8, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _headerBg,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _secondaryColor, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'CLINICAL EXAMINATION SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'ID: ${record.id.length >= 8 ? record.id.substring(0, 8).toUpperCase() : record.id}',
                  style: const pw.TextStyle(fontSize: 8, color: _textDark),
                ),
                pw.Text(
                  dateFormat.format(record.recordDate),
                  style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoGrid(PatientRecord record, DateFormat dateFormat) {
    final showReg = record.registrationNumber != null &&
        record.registrationNumber!.trim().length >= 3 &&
        record.registrationNumber!.trim().toLowerCase() != 'd';

    final ageGenderText = '${record.age != null ? "${record.age} yrs" : "N/A"} | ${record.gender ?? "N/A"}';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PATIENT INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                _fieldRow('Full Name', record.patientName),
                _fieldRow('Age / Gender', ageGenderText),
                if (record.phone != null && record.phone!.trim().isNotEmpty)
                  _fieldRow('Contact', record.phone!),
                if (record.address != null && record.address!.trim().isNotEmpty)
                  _fieldRow('Address', record.address!),
                _fieldRow('Visit Date', dateFormat.format(record.recordDate)),
              ],
            ),
          ),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ATTENDING DENTIST',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                _fieldRow('Doctor', record.doctorName),
                if (record.doctorQualification != null && record.doctorQualification!.trim().isNotEmpty)
                  _fieldRow('Qualification', record.doctorQualification!),
                if (showReg)
                  _fieldRow('Registration #', record.registrationNumber!),
                if (record.vitals != null && record.vitals!.trim().isNotEmpty)
                  _fieldRow('Vitals', record.vitals!),
                if (record.diagnostics != null && record.diagnostics!.trim().isNotEmpty)
                  _fieldRow('Diagnostics', record.diagnostics!),
                _fieldRow('Record Status', 'Verified & Signed'),
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
          pw.SizedBox(
            width: 75,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 8, color: _textMuted),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textDark),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClinicalSummary(PatientRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CHIEF COMPLAINT & FINDINGS',
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            record.chiefComplaint.isNotEmpty ? record.chiefComplaint : 'Routine clinical examination and consultation.',
            style: const pw.TextStyle(fontSize: 8.5, color: _textDark),
          ),
          if (record.clinicalDiagnosis != null && record.clinicalDiagnosis!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'CLINICAL DIAGNOSIS',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _secondaryColor),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              record.clinicalDiagnosis!,
              style: const pw.TextStyle(fontSize: 8.5, color: _textDark),
            ),
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
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _cardBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _borderColor, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MEDICAL & DENTAL HISTORY',
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Medical: ${record.medicalHistory.isNotEmpty ? record.medicalHistory.join(", ") : "No significant medical issues reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: _textDark),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Dental: ${record.dentalHistory.isNotEmpty ? record.dentalHistory.join(", ") : "None reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: _textDark),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: record.allergies.isNotEmpty ? const PdfColor.fromInt(0xFFFEF2F2) : _cardBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(
                color: record.allergies.isNotEmpty ? const PdfColor.fromInt(0xFFFCA5A5) : _borderColor,
                width: 0.8,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ALLERGIES & HABITS',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: record.allergies.isNotEmpty ? const PdfColor.fromInt(0xFFB91C1C) : _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Allergies: ${record.allergies.isNotEmpty ? record.allergies.join(", ") : "NKDA (None reported)"}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: record.allergies.isNotEmpty ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: record.allergies.isNotEmpty ? const PdfColor.fromInt(0xFFB91C1C) : _textDark,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Habits: ${record.habits.isNotEmpty ? record.habits.join(", ") : "None reported."}',
                  style: const pw.TextStyle(fontSize: 8, color: _textDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _cleanAdvice(String text) {
    final cleaned = text
        .replaceAll(
          RegExp(r'(\n|\s)*(?:[^\x00-\x7F]|\[\?\])?\s*Dual-AI Consensus:[\s\S]*', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'(\n|\s)*[•\-\|*]?\s*[^:\n]+(?:discrepancy|vs\s+Mistral|vs\s+Gemini)[\s\S]*', caseSensitive: false),
          '',
        )
        .trim();
    return _sanitizePdfText(cleaned);
  }

  static String _sanitizePdfText(String text) {
    return text
        .replaceAll('₹', 'Rs. ')
        .replaceAll('•', ' | ')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}]', unicode: true), '')
        .trim();
  }

  static pw.Widget _buildProceduresOrTreatmentPlan(PatientRecord record) {
    if (record.toothProcedures.isEmpty) {
      if (record.treatmentPlan.isEmpty) return pw.SizedBox();
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _cardBg,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: _borderColor, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TREATMENT PLAN & RECOMMENDATIONS',
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              _sanitizePdfText(record.treatmentPlan),
              style: const pw.TextStyle(fontSize: 8.5, color: _textDark),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PROCEDURES & TREATMENTS (${record.toothProcedures.length})',
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: _borderColor, width: 0.6),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(3.2),
            2: const pw.FlexColumnWidth(1.6),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _headerBg),
              children: [
                _tableCell('Tooth / Item', isHeader: true),
                _tableCell('Procedure / Treatment', isHeader: true),
                _tableCell('Site / Surface', isHeader: true),
                _tableCell('Status', isHeader: true),
                _tableCell('Cost', isHeader: true, alignRight: true),
              ],
            ),
            ...record.toothProcedures.map(
              (p) => pw.TableRow(
                children: [
                  _tableCell(
                    RegExp(r'^\d+$').hasMatch(p.toothNumber)
                        ? '#${p.toothNumber}'
                        : (p.toothNumber.isNotEmpty && p.toothNumber != '—' ? p.toothNumber : 'Tx'),
                  ),
                  _tableCell(_sanitizePdfText(p.procedureName)),
                  _tableCell(_sanitizePdfText(p.surface ?? 'Clinical')),
                  _tableCell(p.status),
                  _tableCell(
                    p.estimatedCost != null
                        ? 'Rs. ${p.estimatedCost!.toStringAsFixed(2)}'
                        : '-',
                    alignRight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPrescriptionsTable(PatientRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRESCRIPTIONS (Rx)',
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: _borderColor, width: 0.6),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.8),
            1: const pw.FlexColumnWidth(1.4),
            2: const pw.FlexColumnWidth(1.4),
            3: const pw.FlexColumnWidth(2.4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _headerBg),
              children: [
                _tableCell('Medication Name', isHeader: true),
                _tableCell('Dosage', isHeader: true),
                _tableCell('Duration', isHeader: true),
                _tableCell('Instructions', isHeader: true),
              ],
            ),
            ...record.prescriptions.map(
              (rx) => pw.TableRow(
                children: [
                  _tableCell(_sanitizePdfText(rx.medicineName)),
                  _tableCell(_sanitizePdfText(rx.dosage)),
                  _tableCell(_sanitizePdfText(rx.duration)),
                  _tableCell(_sanitizePdfText(rx.instructions ?? 'After meals')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAdviceAndFollowup(PatientRecord record) {
    final cleanAdviceText = record.advice != null ? _cleanAdvice(record.advice!) : '';
    final hasNextVisit = record.nextVisit != null && record.nextVisit!.trim().isNotEmpty;

    if (cleanAdviceText.isEmpty && !hasNextVisit) {
      return pw.SizedBox();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _headerBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _secondaryColor, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CARE INSTRUCTIONS & APPOINTMENT RECALL',
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
          ),
          if (cleanAdviceText.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Advice: $cleanAdviceText',
              style: const pw.TextStyle(fontSize: 8, color: _textDark),
            ),
          ],
          if (hasNextVisit) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Next Appointment / Recall: ${_sanitizePdfText(record.nextVisit!)}',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _primaryColor),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialAndSignature(PatientRecord record, DateFormat dateFormat) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Financial Breakdown Card
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _cardBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _borderColor, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FINANCIAL SUMMARY',
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryColor),
                ),
                pw.SizedBox(height: 6),
                _financialRow('Total Estimated Cost', 'Rs. ${record.estimatedCost.toStringAsFixed(2)}'),
                _financialRow('Insurance Coverage', '-Rs. ${record.insuranceCovered.toStringAsFixed(2)}'),
                _financialRow('Advance / Paid', '-Rs. ${record.advancePaid.toStringAsFixed(2)}'),
                pw.Divider(color: _borderColor, thickness: 0.6),
                _financialRow(
                  'Balance Due',
                  'Rs. ${record.balanceDue.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 24),
        // Official Signature & Verification Stamp
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 18),
              pw.Container(
                width: 140,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: _textDark, width: 1)),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                record.doctorName,
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _textDark),
              ),
              pw.Text(
                'Authorized Dental Surgeon',
                style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
              ),
              pw.Text(
                'Date: ${dateFormat.format(record.recordDate)}',
                style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: _headerBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: _secondaryColor, width: 0.6),
                ),
                child: pw.Text(
                  'OFFICIALLY RECORDED & VERIFIED',
                  style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
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
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? _textDark : _textMuted,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? _primaryColor : _textDark,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 7.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? _primaryColor : _textDark,
        ),
      ),
    );
  }
}
