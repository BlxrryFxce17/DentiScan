import 'package:hive/hive.dart';

class PrescriptionItem {
  final String medicineName;
  final String dosage;
  final String duration;
  final String? instructions;

  PrescriptionItem({
    required this.medicineName,
    required this.dosage,
    required this.duration,
    this.instructions,
  });

  PrescriptionItem copyWith({
    String? medicineName,
    String? dosage,
    String? duration,
    String? instructions,
  }) {
    return PrescriptionItem(
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory PrescriptionItem.fromMap(Map<dynamic, dynamic> map) {
    return PrescriptionItem(
      medicineName: map['medicineName'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      instructions: map['instructions'] as String?,
    );
  }
}

class PrescriptionItemAdapter extends TypeAdapter<PrescriptionItem> {
  @override
  final int typeId = 2;

  @override
  PrescriptionItem read(BinaryReader reader) {
    final map = reader.readMap();
    return PrescriptionItem.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, PrescriptionItem obj) {
    writer.writeMap(obj.toMap());
  }
}
