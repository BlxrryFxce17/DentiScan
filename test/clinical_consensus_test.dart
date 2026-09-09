import 'package:flutter_test/flutter_test.dart';
import 'package:dental_record_ocr/models/patient_record.dart';
import 'package:dental_record_ocr/models/tooth_procedure.dart';
import 'package:dental_record_ocr/models/prescription_item.dart';
import 'package:dental_record_ocr/services/clinical_consensus_engine.dart';

void main() {
  group('ClinicalConsensusEngine - Dual-AI Debate & Reconcile', () {
    test('reconciles matching patient details and boosts consensus confidence', () {
      final geminiRecord = PatientRecord(
        id: 'rec_1',
        patientName: 'Arundhati Roychowdhury',
        age: 65,
        gender: 'Female',
        recordDate: DateTime(2019, 8, 20),
        doctorName: 'Dr. Sreya Pal',
        clinicName: "Dr. T. K. Pal's Dental Clinic & Implant Centre",
        chiefComplaint: 'Pain in upper left tooth',
        treatmentPlan: 'Tooth #24 Endodontic Evaluation / Restorative Treatment',
        toothProcedures: [
          ToothProcedure(
            toothNumber: '24',
            procedureName: 'Endodontic Evaluation / Restorative Treatment (Distal Carious Exposure)',
            status: 'Planned',
            estimatedCost: 0.0,
          ),
        ],
        prescriptions: [
          PrescriptionItem(
            medicineName: 'Tab. Zostum-O',
            dosage: '1 tablet BD',
            duration: 'x 5 days',
            instructions: 'After food',
          ),
          PrescriptionItem(
            medicineName: 'Tab. Megaflexon',
            dosage: '1 tablet BD',
            duration: 'x 6 days',
            instructions: 'After food',
          ),
        ],
        diagnostics: 'IOPA advised for tooth 24',
      );

      final mistralRecord = PatientRecord(
        id: 'rec_2',
        patientName: 'Arundhati Roychowdhury',
        age: 65,
        gender: 'Female',
        recordDate: DateTime(2019, 8, 20),
        doctorName: 'Dr. Sreya Pal',
        clinicName: "Dr. T. K. Pal's Dental Clinic",
        chiefComplaint: 'Tooth pain',
        treatmentPlan: 'Restorative Treatment',
        toothProcedures: [
          ToothProcedure(
            toothNumber: '24',
            procedureName: 'IOPA & Restorative Treatment',
            status: 'Advised',
            estimatedCost: 0.0,
          ),
        ],
        prescriptions: [
          PrescriptionItem(
            medicineName: 'Zostum-O',
            dosage: '1 tablet BD',
            duration: 'x 5 days (Total 10 tabs)',
            instructions: 'After food',
          ),
          PrescriptionItem(
            medicineName: 'Megaflexon',
            dosage: '1 tablet BD',
            duration: 'x 6 days (Total 12 tabs)',
            instructions: 'After food',
          ),
        ],
        advice: 'Warm saline mouthwash 3-4 times daily',
      );

      final report = ClinicalConsensusEngine.reconcile(
        geminiRecord: geminiRecord,
        mistralRecord: mistralRecord,
      );

      // Verify consensus
      expect(report.record.patientName, equals('Arundhati Roychowdhury'));
      expect(report.record.doctorName, equals('Dr. Sreya Pal'));
      expect(report.record.age, equals(65));
      expect(report.record.gender, equals('Female'));

      // Both models matched Tooth 24
      expect(report.record.toothProcedures.length, equals(1));
      expect(report.record.toothProcedures.first.toothNumber, equals('24'));

      // Both models matched the 2 medications and combined dosage / durations
      expect(report.record.prescriptions.length, equals(2));
      expect(report.record.prescriptions.any((p) => p.medicineName.contains('Zostum')), isTrue);
      expect(report.record.prescriptions.any((p) => p.medicineName.contains('Megaflexon')), isTrue);

      // Advice preserves medical advice cleanly without internal AI debate text
      expect(report.record.advice, equals('Warm saline mouthwash 3-4 times daily'));
      expect(report.record.rawOcrText, contains('Dual-AI Consensus'));

      // Score should reach high verified confidence
      expect(report.consensusScore, greaterThanOrEqualTo(0.95));
      expect(report.debateNotes.isEmpty, isTrue);
    });

    test('complementary merges tooth procedures when each model catches distinct teeth', () {
      final geminiRecord = PatientRecord(
        id: 'rec_a',
        patientName: 'John Doe',
        recordDate: DateTime(2026, 9, 1),
        doctorName: 'Dr. Smith',
        clinicName: 'Dental Care',
        chiefComplaint: 'Toothache',
        treatmentPlan: 'RCT',
        toothProcedures: [
          ToothProcedure(toothNumber: '24', procedureName: 'Root Canal Treatment', status: 'Planned', estimatedCost: 3000.0),
        ],
      );

      final mistralRecord = PatientRecord(
        id: 'rec_b',
        patientName: 'John Doe',
        recordDate: DateTime(2026, 9, 1),
        doctorName: 'Dr. Smith',
        clinicName: 'Dental Care',
        chiefComplaint: 'Toothache',
        treatmentPlan: 'Scaling',
        toothProcedures: [
          ToothProcedure(toothNumber: '11', procedureName: 'Composite Restoration', status: 'Planned', estimatedCost: 1500.0),
        ],
      );

      final report = ClinicalConsensusEngine.reconcile(
        geminiRecord: geminiRecord,
        mistralRecord: mistralRecord,
      );

      // Both teeth (24 and 11) should be preserved in the merged record!
      expect(report.record.toothProcedures.length, equals(2));
      expect(report.record.toothProcedures.map((p) => p.toothNumber), containsAll(['24', '11']));
    });
  });
}
