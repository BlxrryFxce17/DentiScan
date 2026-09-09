import 'package:hive/hive.dart';
import 'tooth_procedure.dart';
import 'prescription_item.dart';

class PatientRecord {
  final String id;

  // 1. Patient Details
  final String patientName;
  final int? age;
  final String? gender; // "Male", "Female", "Other"
  final String? phone;
  final String? email;
  final String? address;
  final DateTime recordDate;

  // 2. Doctor Details
  final String doctorName;
  final String clinicName;
  final String? doctorQualification;
  final String? registrationNumber;
  final String? clinicContact;

  // 3. Chief Complaint
  final String chiefComplaint;
  final String? complaintDuration;
  final String? complaintLocation;

  // 4. Medical History
  final List<String> medicalHistory; // e.g. ["Hypertension", "Diabetes Negative"]
  final String? medicalNotes;

  // 5. Dental History
  final List<String> dentalHistory; // e.g. ["Previous RCT #16", "Amalgam filling #36"]
  final String? dentalNotes;

  // 6. Allergies / Habits
  final List<String> allergies; // e.g. ["Penicillin", "Latex"]
  final List<String> habits;    // e.g. ["Non-smoker", "Bruxism"]

  // 7. Treatment Plan
  final String treatmentPlan;
  final String? clinicalDiagnosis;
  final String? estimatedTimeline;

  // 8. Procedures / Tooth Details
  final List<ToothProcedure> toothProcedures;

  // 9. Payment / Financial Details
  final double estimatedCost;
  final double insuranceCovered;
  final double advancePaid;
  final double balanceDue;
  final String? paymentMethod; // "Cash", "Credit Card", "Insurance"
  final List<PrescriptionItem> prescriptions;

  // OCR & Document Metadata
  final String? imagePath;
  final String? rawOcrText;
  final double ocrConfidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientRecord({
    required this.id,
    required this.patientName,
    this.age,
    this.gender,
    this.phone,
    this.email,
    this.address,
    required this.recordDate,
    required this.doctorName,
    required this.clinicName,
    this.doctorQualification,
    this.registrationNumber,
    this.clinicContact,
    required this.chiefComplaint,
    this.complaintDuration,
    this.complaintLocation,
    List<String>? medicalHistory,
    this.medicalNotes,
    List<String>? dentalHistory,
    this.dentalNotes,
    List<String>? allergies,
    List<String>? habits,
    required this.treatmentPlan,
    this.clinicalDiagnosis,
    this.estimatedTimeline,
    List<ToothProcedure>? toothProcedures,
    this.estimatedCost = 0.0,
    this.insuranceCovered = 0.0,
    this.advancePaid = 0.0,
    this.balanceDue = 0.0,
    this.paymentMethod,
    List<PrescriptionItem>? prescriptions,
    this.imagePath,
    this.rawOcrText,
    this.ocrConfidence = 0.95,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : medicalHistory = medicalHistory ?? <String>[],
        dentalHistory = dentalHistory ?? <String>[],
        allergies = allergies ?? <String>[],
        habits = habits ?? <String>[],
        toothProcedures = toothProcedures ?? <ToothProcedure>[],
        prescriptions = prescriptions ?? <PrescriptionItem>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PatientRecord copyWith({
    String? id,
    String? patientName,
    int? age,
    String? gender,
    String? phone,
    String? email,
    String? address,
    DateTime? recordDate,
    String? doctorName,
    String? clinicName,
    String? doctorQualification,
    String? registrationNumber,
    String? clinicContact,
    String? chiefComplaint,
    String? complaintDuration,
    String? complaintLocation,
    List<String>? medicalHistory,
    String? medicalNotes,
    List<String>? dentalHistory,
    String? dentalNotes,
    List<String>? allergies,
    List<String>? habits,
    String? treatmentPlan,
    String? clinicalDiagnosis,
    String? estimatedTimeline,
    List<ToothProcedure>? toothProcedures,
    double? estimatedCost,
    double? insuranceCovered,
    double? advancePaid,
    double? balanceDue,
    String? paymentMethod,
    List<PrescriptionItem>? prescriptions,
    String? imagePath,
    String? rawOcrText,
    double? ocrConfidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientRecord(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      recordDate: recordDate ?? this.recordDate,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      doctorQualification: doctorQualification ?? this.doctorQualification,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      clinicContact: clinicContact ?? this.clinicContact,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      complaintDuration: complaintDuration ?? this.complaintDuration,
      complaintLocation: complaintLocation ?? this.complaintLocation,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      dentalHistory: dentalHistory ?? this.dentalHistory,
      dentalNotes: dentalNotes ?? this.dentalNotes,
      allergies: allergies ?? this.allergies,
      habits: habits ?? this.habits,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      clinicalDiagnosis: clinicalDiagnosis ?? this.clinicalDiagnosis,
      estimatedTimeline: estimatedTimeline ?? this.estimatedTimeline,
      toothProcedures: toothProcedures ?? this.toothProcedures,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      insuranceCovered: insuranceCovered ?? this.insuranceCovered,
      advancePaid: advancePaid ?? this.advancePaid,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      prescriptions: prescriptions ?? this.prescriptions,
      imagePath: imagePath ?? this.imagePath,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'recordDate': recordDate.toIso8601String(),
      'doctorName': doctorName,
      'clinicName': clinicName,
      'doctorQualification': doctorQualification,
      'registrationNumber': registrationNumber,
      'clinicContact': clinicContact,
      'chiefComplaint': chiefComplaint,
      'complaintDuration': complaintDuration,
      'complaintLocation': complaintLocation,
      'medicalHistory': medicalHistory,
      'medicalNotes': medicalNotes,
      'dentalHistory': dentalHistory,
      'dentalNotes': dentalNotes,
      'allergies': allergies,
      'habits': habits,
      'treatmentPlan': treatmentPlan,
      'clinicalDiagnosis': clinicalDiagnosis,
      'estimatedTimeline': estimatedTimeline,
      'toothProcedures': toothProcedures.map((e) => e.toMap()).toList(),
      'estimatedCost': estimatedCost,
      'insuranceCovered': insuranceCovered,
      'advancePaid': advancePaid,
      'balanceDue': balanceDue,
      'paymentMethod': paymentMethod,
      'prescriptions': prescriptions.map((e) => e.toMap()).toList(),
      'imagePath': imagePath,
      'rawOcrText': rawOcrText,
      'ocrConfidence': ocrConfidence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PatientRecord.fromMap(Map<dynamic, dynamic> map) {
    return PatientRecord(
      id: map['id'] as String? ?? '',
      patientName: map['patientName'] as String? ?? 'Unnamed Patient',
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      recordDate: map['recordDate'] != null
          ? DateTime.tryParse(map['recordDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      doctorName: map['doctorName'] as String? ?? 'Attending Doctor',
      clinicName: map['clinicName'] as String? ?? 'Dental Clinic',
      doctorQualification: map['doctorQualification'] as String?,
      registrationNumber: map['registrationNumber'] as String?,
      clinicContact: map['clinicContact'] as String?,
      chiefComplaint: map['chiefComplaint'] as String? ?? '',
      complaintDuration: map['complaintDuration'] as String?,
      complaintLocation: map['complaintLocation'] as String?,
      medicalHistory: (map['medicalHistory'] as List?)?.map((e) => e.toString()).toList() ?? [],
      medicalNotes: map['medicalNotes'] as String?,
      dentalHistory: (map['dentalHistory'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dentalNotes: map['dentalNotes'] as String?,
      allergies: (map['allergies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      habits: (map['habits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      treatmentPlan: map['treatmentPlan'] as String? ?? '',
      clinicalDiagnosis: map['clinicalDiagnosis'] as String?,
      estimatedTimeline: map['estimatedTimeline'] as String?,
      toothProcedures: (map['toothProcedures'] as List?)
              ?.map((e) => ToothProcedure.fromMap(Map<dynamic, dynamic>.from(e as Map)))
              .toList() ??
          [],
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      insuranceCovered: (map['insuranceCovered'] as num?)?.toDouble() ?? 0.0,
      advancePaid: (map['advancePaid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (map['balanceDue'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] as String?,
      prescriptions: (map['prescriptions'] as List?)
              ?.map((e) => PrescriptionItem.fromMap(Map<dynamic, dynamic>.from(e as Map)))
              .toList() ??
          [],
      imagePath: map['imagePath'] as String?,
      rawOcrText: map['rawOcrText'] as String?,
      ocrConfidence: (map['ocrConfidence'] as num?)?.toDouble() ?? 0.95,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PatientRecordAdapter extends TypeAdapter<PatientRecord> {
  @override
  final int typeId = 0;

  @override
  PatientRecord read(BinaryReader reader) {
    final map = reader.readMap();
    return PatientRecord.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, PatientRecord obj) {
    writer.writeMap(obj.toMap());
  }
}
