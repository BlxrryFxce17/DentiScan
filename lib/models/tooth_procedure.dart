import 'package:hive/hive.dart';

class ToothProcedure {
  final String toothNumber; // e.g. "46", "23", "14"
  final String? toothName;   // e.g. "Lower Right First Molar"
  final String? surface;     // e.g. "MOD", "Occlusal", "DO"
  final String procedureName;// e.g. "Root Canal Therapy", "Composite Filling"
  final String status;       // "Planned", "In-Progress", "Completed"
  final double? estimatedCost;

  ToothProcedure({
    required this.toothNumber,
    this.toothName,
    this.surface,
    required this.procedureName,
    this.status = 'Planned',
    this.estimatedCost,
  });

  ToothProcedure copyWith({
    String? toothNumber,
    String? toothName,
    String? surface,
    String? procedureName,
    String? status,
    double? estimatedCost,
  }) {
    return ToothProcedure(
      toothNumber: toothNumber ?? this.toothNumber,
      toothName: toothName ?? this.toothName,
      surface: surface ?? this.surface,
      procedureName: procedureName ?? this.procedureName,
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'toothName': toothName,
      'surface': surface,
      'procedureName': procedureName,
      'status': status,
      'estimatedCost': estimatedCost,
    };
  }

  factory ToothProcedure.fromMap(Map<dynamic, dynamic> map) {
    return ToothProcedure(
      toothNumber: map['toothNumber'] as String? ?? '',
      toothName: map['toothName'] as String?,
      surface: map['surface'] as String?,
      procedureName: map['procedureName'] as String? ?? 'Procedure',
      status: map['status'] as String? ?? 'Planned',
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
    );
  }
}

class ToothProcedureAdapter extends TypeAdapter<ToothProcedure> {
  @override
  final int typeId = 1;

  @override
  ToothProcedure read(BinaryReader reader) {
    final map = reader.readMap();
    return ToothProcedure.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, ToothProcedure obj) {
    writer.writeMap(obj.toMap());
  }
}
