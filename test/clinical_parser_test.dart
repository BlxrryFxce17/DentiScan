import 'package:flutter_test/flutter_test.dart';
import 'package:dental_record_ocr/services/clinical_parser.dart';

void main() {
  group('ClinicalParser & OCR Extraction Tests', () {
    test('Correctly extracts 9 categories from handwritten dental prescription', () {
      const sampleText = '''
SmileCraft Dental Clinic
123 Oral Health Ave, Dental City
Patient Name: David Miller
Age: 38    Gender: Male    Date: Sept 08 2026
Doctor: Dr. Arthur Pendelton
Qualification: MDS Endodontics    Reg #: DEN-88219

Chief Complaint: Severe throbbing pain in lower right molar tooth #46, aggravated by cold and chewing for 4 days.
Medical History: Well-controlled hypertension on Amlodipine 5mg.
Dental History: Previous silver amalgam filling on #36.
Allergies: Penicillin allergy, non-smoker.
Clinical Findings: Deep occlusal caries on tooth #46, tender to percussion.
Treatment Plan: Endodontic Root Canal Therapy (RCT) on #46 followed by Zirconia Crown.

Rx:
1. Cefuroxime 500mg BD x 5 days
2. Ibuprofen 400mg TDS

Estimated Cost: \$650
Advance Paid: \$200
Balance: \$450
''';

      final record = ClinicalParser.parseTextToRecord(rawText: sampleText);

      // 1. Patient Details
      expect(record.patientName, equals('David Miller'));
      expect(record.age, equals(38));
      expect(record.gender, equals('Male'));

      // 2. Doctor Details
      expect(record.doctorName, equals('Dr. Arthur Pendelton'));
      expect(record.clinicName, contains('SmileCraft'));
      expect(record.registrationNumber, equals('DEN-88219'));

      // 3. Chief Complaint
      expect(record.chiefComplaint, contains('Severe throbbing pain in lower right molar tooth #46'));

      // 4. Medical History
      expect(record.medicalHistory.any((m) => m.toLowerCase().contains('hypertension')), isTrue);

      // 5. Dental History
      expect(record.dentalHistory.any((d) => d.toLowerCase().contains('amalgam')), isTrue);

      // 6. Allergies / Habits
      expect(record.allergies.any((a) => a.toLowerCase().contains('penicillin')), isTrue);
      expect(record.habits.any((h) => h.toLowerCase().contains('non-smoker')), isTrue);

      // 7. Treatment Plan
      expect(record.treatmentPlan, contains('Root Canal'));

      // 8. Procedures / Tooth Details
      expect(record.toothProcedures.any((tp) => tp.toothNumber == '46'), isTrue);

      // 9. Financial Details
      expect(record.estimatedCost, equals(650.0));
      expect(record.advancePaid, equals(200.0));
      expect(record.balanceDue, equals(450.0));
    });

    test('Correctly extracts printed dental examination chart', () {
      const sampleText = '''
Apex Dental Specialties & Implantology
DENTAL EXAMINATION & TREATMENT PLAN
Doctor: Dr. Evelyn Reed, DDS (License #10943)
Patient: Sophia Martinez    Age: 29    Gender: Female
Date: 2026-09-07    Phone: (555) 342-9910

Chief Complaint: Bleeding and inflamed gums around upper left canine (#23)
Medical History: None reported, Diabetes Negative
Dental History: Orthodontic braces completed 4 years ago
Allergies / Habits: Latex allergy (significant), non-smoker

Procedures / Tooth Details:
Tooth #23 Subgingival scaling and curettage
Tooth #14 Composite resin restoration

Financial Summary:
Total Cost: \$480.00
Insurance Covered: \$200.00
Patient Copay Paid: \$150.00
Balance Due: \$130.00
''';

      final record = ClinicalParser.parseTextToRecord(rawText: sampleText);

      expect(record.patientName, equals('Sophia Martinez'));
      expect(record.age, equals(29));
      expect(record.gender, equals('Female'));
      expect(record.allergies.any((a) => a.toLowerCase().contains('latex')), isTrue);
      expect(record.toothProcedures.any((tp) => tp.toothNumber == '23'), isTrue);
      expect(record.toothProcedures.any((tp) => tp.toothNumber == '14'), isTrue);
      expect(record.estimatedCost, equals(480.0));
      expect(record.insuranceCovered, equals(200.0));
      expect(record.advancePaid, equals(150.0));
      expect(record.balanceDue, equals(130.0));
    });

    test('Handles edge cases and missing fields gracefully without crashing', () {
      const minimalText = 'Random notes without patient header or structure.';
      final record = ClinicalParser.parseTextToRecord(rawText: minimalText);

      expect(record.id.isNotEmpty, isTrue);
      expect(record.patientName.isNotEmpty, isTrue);
      expect(record.toothProcedures.isNotEmpty, isTrue); // Fallback tooth procedure
      expect(record.estimatedCost, greaterThanOrEqualTo(0.0));
    });

    test('Correctly extracts financial details with INR currency symbols (₹, Rs.)', () {
      const inrText = '''
Apollo White Dental
Patient Name: Rajesh Sharma
Doctor: Dr. Sunita Rao
Total Cost: ₹15,500.00
Insurance Covered: Rs. 5000.00
Advance Paid: ₹3,000.00
Balance Due: ₹7,500.00
''';
      final record = ClinicalParser.parseTextToRecord(rawText: inrText);

      expect(record.patientName, equals('Rajesh Sharma'));
      expect(record.estimatedCost, equals(15500.0));
      expect(record.insuranceCovered, equals(5000.0));
      expect(record.advancePaid, equals(3000.0));
      expect(record.balanceDue, equals(7500.0));
    });

    test('Correctly parses Gemini Vision AI multimodal handwriting transcription format', () {
      const geminiOutput = '''
Clinic: Fortis Dental Care
Doctor: Dr. Ananya Sen, MDS (Reg #D-9982)
Patient Name: Priya Verma
Age: 32
Gender: Female
Phone: +91 98765 43210
Date: 2026-09-09

Chief Complaint: Sharp pain in upper left premolar tooth #24 on chewing.
Medical History: Type 2 Diabetes (HbA1c 6.8)
Dental History: Routine scaling 6 months ago
Allergies: Penicillin, Sulfa drugs
Habits: None reported

Clinical Findings: Distal cavity on #24 with pulpal involvement.

Treatment Plan / Procedures:
Tooth #24 Root Canal Treatment & Ceramic Inlay - Cost: ₹5500

Rx / Medications:
1. Amoxicillin Clavulanate 625mg 1-0-1 x 5 days
2. Ketorolac 10mg PRN

Financial Summary:
Total Cost: ₹5,500.00
Advance Paid: ₹2,000.00
Insurance Covered: ₹0.00
Balance Due: ₹3,500.00

Notes / Instructions: Avoid hard foods on left side until obturation.
''';

      final record = ClinicalParser.parseTextToRecord(rawText: geminiOutput);

      expect(record.patientName, equals('Priya Verma'));
      expect(record.age, equals(32));
      expect(record.gender, equals('Female'));
      expect(record.doctorName, contains('Dr. Ananya Sen'));
      expect(record.chiefComplaint, contains('tooth #24'));
      expect(record.allergies.any((a) => a.toLowerCase().contains('penicillin')), isTrue);
      expect(record.toothProcedures.any((p) => p.toothNumber == '24'), isTrue);
      expect(record.prescriptions.length, greaterThanOrEqualTo(1));
      expect(record.estimatedCost, equals(5500.0));
      expect(record.advancePaid, equals(2000.0));
      expect(record.balanceDue, equals(3500.0));
    });
  });
}

