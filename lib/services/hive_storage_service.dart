import 'package:hive_flutter/hive_flutter.dart';
import '../models/patient_record.dart';
import '../models/tooth_procedure.dart';
import '../models/prescription_item.dart';

class HiveStorageService {
  static const String recordsBoxName = 'dental_patient_records';
  static const String settingsBoxName = 'dental_app_settings';

  static Box<PatientRecord>? _box;
  static Box? _settingsBox;

  /// Initializes Hive and registers custom type adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PatientRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ToothProcedureAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PrescriptionItemAdapter());
    }

    _box = await Hive.openBox<PatientRecord>(recordsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Box<PatientRecord> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('HiveStorageService has not been initialized. Call init() first.');
    }
    return _box!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw StateError('HiveStorageService settingsBox has not been initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  /// Get configured Gemini API Key (from local Hive storage or compile-time environment)
  static String getGeminiApiKey() {
    final stored = settingsBox.get('gemini_api_key') as String?;
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  }

  /// Returns true if an API key is configured
  static bool hasGeminiApiKey() {
    return getGeminiApiKey().isNotEmpty;
  }

  /// Save Gemini API Key
  static Future<void> saveGeminiApiKey(String key) async {
    await settingsBox.put('gemini_api_key', key.trim());
  }

  /// Get preferred OCR mode: 'auto', 'gemini', 'mlkit'
  static String getOcrEngineMode() {
    return settingsBox.get('ocr_engine_mode', defaultValue: 'auto') as String;
  }

  /// Save preferred OCR mode
  static Future<void> saveOcrEngineMode(String mode) async {
    await settingsBox.put('ocr_engine_mode', mode);
  }

  /// Get all patient records sorted by record date descending
  static List<PatientRecord> getAllRecords() {
    final list = box.values.toList();
    list.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    return list;
  }

  /// Save or update a patient record
  static Future<void> saveRecord(PatientRecord record) async {
    await box.put(record.id, record);
  }

  /// Delete a patient record by ID
  static Future<void> deleteRecord(String id) async {
    await box.delete(id);
  }

  /// Check for potential duplicate records
  /// Returns existing records that share the same patient name or phone number
  static List<PatientRecord> findDuplicates(PatientRecord newRecord) {
    final all = getAllRecords();
    return all.where((existing) {
      if (existing.id == newRecord.id) return false;
      final sameName = existing.patientName.trim().toLowerCase() == newRecord.patientName.trim().toLowerCase();
      final samePhone = existing.phone != null &&
          newRecord.phone != null &&
          existing.phone!.replaceAll(RegExp(r'\D'), '') == newRecord.phone!.replaceAll(RegExp(r'\D'), '') &&
          existing.phone!.trim().isNotEmpty;
      return sameName || samePhone;
    }).toList();
  }

  /// Search records across patient name, doctor name, clinic, tooth number, or chief complaint
  static List<PatientRecord> searchRecords(String query) {
    if (query.trim().isEmpty) return getAllRecords();
    final q = query.trim().toLowerCase();
    return getAllRecords().where((record) {
      final matchesPatient = record.patientName.toLowerCase().contains(q);
      final matchesDoctor = record.doctorName.toLowerCase().contains(q);
      final matchesClinic = record.clinicName.toLowerCase().contains(q);
      final matchesComplaint = record.chiefComplaint.toLowerCase().contains(q);
      final matchesTooth = record.toothProcedures.any(
        (tp) => tp.toothNumber.contains(q) || tp.procedureName.toLowerCase().contains(q),
      );
      return matchesPatient || matchesDoctor || matchesClinic || matchesComplaint || matchesTooth;
    }).toList();
  }

  /// Clear all records (useful for test resets)
  static Future<void> clearAll() async {
    await box.clear();
  }
}
