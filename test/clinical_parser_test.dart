import 'package:flutter_test/flutter_test.dart';
import 'package:dental_record_ocr/services/clinical_parser.dart';

void main() {
  group('ClinicalParser - Cyrus Ortiz Prescription Tests', () {
    const rawOcrText = '''
Clinic: SmileCrest Dental Clinic
Raleigh, NC 27601
Doctor: [Not visible]
Patient Name: Cyrus Ortiz
Age: 42
Gender: Male
Date: 2055-10-08
Phone: 222 555 7777
Address: [Not visible]

Vitals: [Not recorded]
Diagnostics: [Not recorded]

Chief Complaint: Tooth abscess
Medical History: [Not recorded]
Dental History: [Not recorded]
Allergies: [Not recorded]
Habits: [Not recorded]

Clinical Findings: Tooth abscess

Treatment Plan / Procedures:
[No specific dental procedures with tooth numbers are listed]

Rx / Medications:
1. Amoxicillin 500mg 1 tablet Every 8 hours x 7 days
2. Ibuprofen 400mg 1 tablet Every 8 hours x 7 days

Advice / Instructions: Take medication with food, avoid alcohol.
Next Appointment: 2055-10-15

Financial Summary: [Not visible]

Notes / Instructions: Prescription No.: DC-2055-00123
''';

    test('parses Cyrus Ortiz record cleanly without placeholder leaks', () {
      final record = ClinicalParser.parseTextToRecord(rawText: rawOcrText);

      // Patient identity
      expect(record.patientName, equals('Cyrus Ortiz'));
      expect(record.age, equals(42));
      expect(record.gender, equals('Male'));
      expect(record.phone, equals('222 555 7777'));
      expect(record.address, isNull); // [Not visible] cleaned to null
      expect(record.clinicName, contains('SmileCrest Dental Clinic'));
      expect(record.doctorName, equals('Attending Dental Surgeon'));
      expect(record.registrationNumber, equals('DC-2055-00123'));

      // Date
      expect(record.recordDate.year, equals(2055));
      expect(record.recordDate.month, equals(10));
      expect(record.recordDate.day, equals(8));

      // Vitals & Diagnostics must be null (not '[Not recorded]')
      expect(record.vitals, isNull);
      expect(record.diagnostics, isNull);

      // Chief complaint & diagnosis
      expect(record.chiefComplaint, equals('Tooth abscess'));
      expect(record.clinicalDiagnosis, equals('Tooth abscess'));

      // Allergies must be empty to avoid false warning badge
      expect(record.allergies, isEmpty);
      expect(record.medicalHistory, isEmpty);
      expect(record.dentalHistory, isEmpty);
      expect(record.habits, isEmpty); // "avoid alcohol" should not trigger alcohol habit

      // Treatment Plan
      expect(record.toothProcedures, isEmpty);
      expect(record.treatmentPlan, isNot(contains('[No specific')));

      // Prescriptions: exactly 2 drugs, no "Advice" or "Next"
      expect(record.prescriptions.length, equals(2));
      expect(record.prescriptions[0].medicineName, equals('Amoxicillin 500mg'));
      expect(record.prescriptions[0].dosage, contains('TDS'));
      expect(record.prescriptions[0].duration, equals('7 days'));

      expect(record.prescriptions[1].medicineName, equals('Ibuprofen 400mg'));
      expect(record.prescriptions[1].dosage, contains('TDS'));
      expect(record.prescriptions[1].duration, equals('7 days'));

      // Advice & Next visit
      expect(record.advice, equals('Take medication with food, avoid alcohol.'));
      expect(record.nextVisit, equals('2055-10-15'));

      // Financials
      expect(record.estimatedCost, equals(0.0));
      expect(record.balanceDue, equals(0.0));
    });
  });

  group('ClinicalParser - Kanika Practo Dental Bill Tests', () {
    const rawBillText = '''
Clinic: HSR DENTAL CLINIC & IMPLANT CENTRE
Phone: 080-22580522, 099 80 445555
Doctor: Dr. Deepak Daryani
Patient Name: KANIKA
Date: 12 Dec, 2024

Treatment Plan / Procedures:
Consultation - Cost: ₹500.00
Scaling & Polishing - Cost: ₹2,500.00
Laser bacterial decontamination - Cost: ₹2,500.00
Laser assisted RCT - Cost: ₹7,000.00
Fibre Optic Post Placement - Cost: ₹3,000.00
Composite Crown Buildup - Cost: ₹2,500.00
Intra Oral Scanning - Cost: ₹1,000.00
crown fixation with resin cement - Cost: ₹900.00

Financial Summary:
Total Cost: ₹19,900.00
Advance Paid: ₹19,900.00
Balance Due: ₹0.00

Notes / Instructions:
Receipt Number: RCPT2324
Invoice Number: INV2324
Mode of Payment: Cash
Generated On: 12 Dec 2024
''';

    test('correctly parses date 12 Dec 2024, all 8 treatments, and invoice ID', () {
      final record = ClinicalParser.parseTextToRecord(rawText: rawBillText);

      // Patient & Clinic Details
      expect(record.patientName, equals('KANIKA'));
      expect(record.clinicName, contains('HSR DENTAL CLINIC & IMPLANT CENTRE'));
      expect(record.doctorName, equals('Dr. Deepak Daryani'));
      expect(record.phone, contains('080-22580522'));

      // Date parsing: MUST be Dec 12, 2024, NOT current date
      expect(record.recordDate.year, equals(2024));
      expect(record.recordDate.month, equals(12));
      expect(record.recordDate.day, equals(12));

      // Reference / Registration Number
      expect(record.registrationNumber, equals('INV2324'));

      // Consultation fee must be extracted separately into consultationFee, NOT in tooth procedures
      expect(record.consultationFee, equals(500.0));

      // Exactly 7 clinical dental procedures (without Consultation)
      expect(record.toothProcedures.length, equals(7));

      expect(record.toothProcedures[0].procedureName, equals('Scaling & Polishing'));
      expect(record.toothProcedures[0].estimatedCost, equals(2500.0));

      expect(record.toothProcedures[1].procedureName, equals('Laser bacterial decontamination'));
      expect(record.toothProcedures[1].estimatedCost, equals(2500.0));

      expect(record.toothProcedures[2].procedureName, equals('Laser assisted RCT'));
      expect(record.toothProcedures[2].estimatedCost, equals(7000.0));

      expect(record.toothProcedures[3].procedureName, equals('Fibre Optic Post Placement'));
      expect(record.toothProcedures[3].estimatedCost, equals(3000.0));

      expect(record.toothProcedures[4].procedureName, equals('Composite Crown Buildup'));
      expect(record.toothProcedures[4].estimatedCost, equals(2500.0));

      expect(record.toothProcedures[5].procedureName, equals('Intra Oral Scanning'));
      expect(record.toothProcedures[5].estimatedCost, equals(1000.0));

      expect(record.toothProcedures[6].procedureName, equals('Crown fixation with resin cement'));
      expect(record.toothProcedures[6].estimatedCost, equals(900.0));

      // Financials
      expect(record.estimatedCost, equals(19900.0));
      expect(record.advancePaid, equals(19900.0));
      expect(record.balanceDue, equals(0.0));

      // Advice should NOT contain receipt/invoice numbers
      expect(record.advice, isNull);
    });

    test('correctly extracts actual rates and never confuses row numbers (1., 2.) with price', () {
      const numberedBillText = '''
Clinic: HSR DENTAL CLINIC & IMPLANT CENTRE
Doctor: Dr. Deepak Daryani
Patient Name: KANIKA
Date: 12 Dec, 2024

Treatment Plan / Procedures:
1. Consultation - Cost: ₹500.00
2. Scaling & Polishing - Cost: ₹2,500.00
3. Laser bacterial decontamination - Cost: ₹2,500.00
4. Laser assisted RCT - Cost: ₹7,000.00
5. Fibre Optic Post Placement - Cost: ₹3,000.00
6. Composite Crown Buildup - Cost: ₹2,500.00
7. Intra Oral Scanning - Cost: ₹1,000.00
8. crown fixation with resin cement - Cost: ₹900.00

Financial Summary:
Total Cost: ₹19,900.00
Advance Paid: ₹19,900.00
Balance Due: ₹0.00
''';

      final record = ClinicalParser.parseTextToRecord(rawText: numberedBillText);
      expect(record.consultationFee, equals(500.0));
      expect(record.toothProcedures.length, equals(7));
      expect(record.toothProcedures[0].procedureName, equals('Scaling & Polishing'));
      expect(record.toothProcedures[0].estimatedCost, equals(2500.0));
      expect(record.toothProcedures[1].procedureName, equals('Laser bacterial decontamination'));
      expect(record.toothProcedures[1].estimatedCost, equals(2500.0));
      expect(record.toothProcedures[2].procedureName, equals('Laser assisted RCT'));
      expect(record.toothProcedures[2].estimatedCost, equals(7000.0));
      expect(record.toothProcedures[3].procedureName, equals('Fibre Optic Post Placement'));
      expect(record.toothProcedures[3].estimatedCost, equals(3000.0));
      expect(record.toothProcedures[4].procedureName, equals('Composite Crown Buildup'));
      expect(record.toothProcedures[4].estimatedCost, equals(2500.0));
      expect(record.toothProcedures[5].procedureName, equals('Intra Oral Scanning'));
      expect(record.toothProcedures[5].estimatedCost, equals(1000.0));
      expect(record.toothProcedures[6].procedureName, equals('Crown fixation with resin cement'));
      expect(record.toothProcedures[6].estimatedCost, equals(900.0));
    });
  });

  group('ClinicalParser - Arundhati Roychowdhury Handwritten Prescription Tests', () {
    const rawPrescriptionText = '''
Clinic: Dr. T. K. Pal's Dental Clinic & Implant Centre / Quadra Medical Services Pvt. Ltd., 262, B. B. Chatterjee Road, Kasba, Kolkata - 700 042
Doctor: Prof. Dr. Tamal Kanti Pal, B.D.S. (C.U.), M.D.S. (Periodontics, L.U.) / Dr. Sreya Pal, B.D.S., M.D.S. (WBUHS), Consultant Conservative & Endodontist
Patient Name: Arundhati Roychowdhury
Age: 65
Gender: Female
Date: 20/08/2019
Phone: None
Address: None

Vitals: None
Diagnostics: IOPA advised for tooth 24 (Palmer: 4 in upper left quadrant)

Chief Complaint: None
Medical History: None
Dental History: None
Allergies: None
Habits: None

Clinical Findings:
Tooth 24: Carious exposure (distal)

Treatment Plan / Procedures: None

Rx / Medications:
1. Tab. Zostum-O - Total: 10 tablets - 1 tablet BD (twice daily) x 5 days (after food)
2. Tab. Megaflexon - Total: 12 tablets - 1 tablet TDS (three times daily) x 4 days (after food)
3. H/S (Hot saline) mouthwash

Advice / Instructions:
Take medications after food
Frequent warm/hot saline mouth rinses

Next Appointment: None
Financial Summary: None
''';

    test('correctly parses tooth 24, all 3 medications, date 20/08/2019, and advice', () {
      final record = ClinicalParser.parseTextToRecord(rawText: rawPrescriptionText);

      // Patient identity
      expect(record.patientName, equals('Arundhati Roychowdhury'));
      expect(record.age, equals(65));
      expect(record.gender, equals('Female'));

      // Date: 20/08/2019 -> August 20, 2019
      expect(record.recordDate.year, equals(2019));
      expect(record.recordDate.month, equals(8));
      expect(record.recordDate.day, equals(20));

      // Clinic & Doctor
      expect(record.clinicName, contains("Pal's Dental Clinic"));
      expect(record.doctorName, contains('Pal'));

      // Diagnostics & Chief complaint
      expect(record.diagnostics, contains('IOPA advised for tooth 24'));
      expect(record.clinicalDiagnosis, contains('Carious exposure (distal)'));

      // Tooth 24 must be captured as a procedure / finding
      expect(record.toothProcedures.any((p) => p.toothNumber == '24'), isTrue);
      final tooth24 = record.toothProcedures.firstWhere((p) => p.toothNumber == '24');
      expect(tooth24.surface, equals('Distal'));
      expect(tooth24.procedureName, contains('Carious Exposure'));

      // All 3 medications must be parsed
      expect(record.prescriptions.length, equals(3));

      final zostum = record.prescriptions.firstWhere((r) => r.medicineName.contains('Zostum-O'));
      expect(zostum.dosage, contains('BD'));
      expect(zostum.duration, equals('5 days'));
      expect(zostum.instructions, contains('After food'));

      final megaflexon = record.prescriptions.firstWhere((r) => r.medicineName.contains('Megaflexon'));
      expect(megaflexon.dosage, contains('TDS'));
      expect(megaflexon.duration, equals('4 days'));
      expect(megaflexon.instructions, contains('After food'));

      final mouthwash = record.prescriptions.firstWhere((r) => r.medicineName.toLowerCase().contains('mouthwash'));
      expect(mouthwash.instructions, contains('warm saline'));

      // Advice
      expect(record.advice, contains('Take medications after food'));

      // Placeholders must be sanitized to null / empty
      expect(record.phone, isNull);
      expect(record.address, isNull);
      expect(record.vitals, isNull);
      expect(record.allergies, isEmpty);
      expect(record.medicalHistory, isEmpty);
    });

    test('sanitizes "Specific tooth number not specified" and parses multi-tooth Palmer notation', () {
      const rawText = '''
Clinic: Satguru Dental Centre
Doctor: Dr. Sanjay Chawla, BDS
Patient Name: Harish
Age: 55
Gender: Male
Vitals: Temp 95.9°F, SpO2 99%
Chief Complaint: Tooth abscess (Specific tooth number not specified in the document)
Diagnosis: Tooth abscess (Specific tooth number not specified in the document)
Clinical Findings:
Pocket _|4 5 IOPA taken

Treatment Plan / Procedures:
Tooth #24, #25: Periodontal Debridement & Deep Scaling - Status: Planned

Rx / Medications:
1. Tab. Dox-L-100 1 tablet BD x 3 days (After food)
2. Tab. Acemiz-S 1 tablet BD x 3 days
3. Rexidine M Forte Gel (Local application)

Advice: Warm saline rinses
''';

      final record = ClinicalParser.parseTextToRecord(
        rawText: rawText,
        imagePath: 'test_path.jpg',
        ocrConfidence: 0.98,
      );

      // Verify disclaimers are cleanly stripped
      expect(record.chiefComplaint, equals('Tooth abscess'));
      expect(record.clinicalDiagnosis, equals('Tooth abscess'));
      expect(record.treatmentPlan, isNot(contains('not specified')));
      expect(record.treatmentPlan, isNot(contains('Specific tooth')));

      // Both Tooth #24 and #25 should be parsed
      expect(record.toothProcedures.any((p) => p.toothNumber == '24'), isTrue);
      expect(record.toothProcedures.any((p) => p.toothNumber == '25'), isTrue);
    });
  });
}
