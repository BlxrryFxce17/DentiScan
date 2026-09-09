import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/patient_record.dart';
import '../../services/hive_storage_service.dart';
import '../../services/ocr_engine.dart';

class DentalRecordsProvider extends ChangeNotifier {
  List<PatientRecord> _records = [];
  String _searchQuery = '';

  // Active OCR / Scanning draft state
  PatientRecord? _draftRecord;
  Uint8List? _activeImageBytes;
  String? _activeImagePath;
  bool _isProcessingOcr = false;
  double _ocrProgress = 0.0;
  String _ocrStatusMessage = '';
  List<PatientRecord> _detectedDuplicates = [];

  List<PatientRecord> get records => _records;
  String get searchQuery => _searchQuery;
  PatientRecord? get draftRecord => _draftRecord;
  Uint8List? get activeImageBytes => _activeImageBytes;
  String? get activeImagePath => _activeImagePath;
  bool get isProcessingOcr => _isProcessingOcr;
  double get ocrProgress => _ocrProgress;
  String get ocrStatusMessage => _ocrStatusMessage;
  List<PatientRecord> get detectedDuplicates => _detectedDuplicates;

  List<PatientRecord> get filteredRecords {
    if (_searchQuery.trim().isEmpty) return _records;
    final q = _searchQuery.trim().toLowerCase();
    return _records.where((r) {
      return r.patientName.toLowerCase().contains(q) ||
          r.doctorName.toLowerCase().contains(q) ||
          r.clinicName.toLowerCase().contains(q) ||
          r.chiefComplaint.toLowerCase().contains(q) ||
          (r.phone != null && r.phone!.contains(q)) ||
          r.toothProcedures.any((tp) => tp.toothNumber.contains(q) || tp.procedureName.toLowerCase().contains(q));
    }).toList();
  }

  /// Groups all clinical records into distinct Patient Profiles
  List<PatientGroup> get patientGroups {
    final map = <String, List<PatientRecord>>{};
    for (final r in _records) {
      final key = r.patientName.trim().toLowerCase();
      map.putIfAbsent(key, () => []).add(r);
    }

    final groups = map.values.map((recordsList) {
      recordsList.sort((a, b) => b.recordDate.compareTo(a.recordDate));
      final first = recordsList.first;
      return PatientGroup(
        patientName: first.patientName,
        age: first.age,
        gender: first.gender,
        phone: first.phone,
        visits: recordsList,
      );
    }).toList();

    groups.sort((a, b) => b.latestVisitDate.compareTo(a.latestVisitDate));
    return groups;
  }

  /// Filtered patient groups matching the search query
  List<PatientGroup> get filteredPatientGroups {
    final groups = patientGroups;
    if (_searchQuery.trim().isEmpty) return groups;
    final q = _searchQuery.trim().toLowerCase();
    return groups.where((g) {
      return g.patientName.toLowerCase().contains(q) ||
          (g.phone != null && g.phone!.contains(q)) ||
          g.allProcedures.any((p) => p.toLowerCase().contains(q)) ||
          g.allAllergies.any((a) => a.toLowerCase().contains(q));
    }).toList();
  }

  /// Load records from Hive
  Future<void> loadRecords() async {
    _records = HiveStorageService.getAllRecords();

    // If database is completely empty on first launch, load realistic sample records!
    if (_records.isEmpty) {
      await _seedInitialDemoData();
      _records = HiveStorageService.getAllRecords();
    }
    notifyListeners();
  }

  /// Process an uploaded/scanned image through the OCR & categorization pipeline
  Future<PatientRecord?> processDocumentImage(Uint8List bytes, {String? filePath}) async {
    _isProcessingOcr = true;
    _ocrProgress = 0.0;
    _ocrStatusMessage = 'Initiating Optical Character Recognition...';
    _activeImageBytes = bytes;
    _activeImagePath = filePath;
    _detectedDuplicates = [];
    notifyListeners();

    try {
      final parsedRecord = await OcrEngine.processDentalDocument(
        imageBytes: bytes,
        filePath: filePath,
        onProgress: (update) {
          _ocrProgress = update.progress;
          _ocrStatusMessage = update.statusMessage;
          notifyListeners();
        },
      );

      _draftRecord = parsedRecord;
      _detectedDuplicates = HiveStorageService.findDuplicates(parsedRecord);
      _isProcessingOcr = false;
      notifyListeners();
      return parsedRecord;
    } catch (e) {
      _isProcessingOcr = false;
      _ocrStatusMessage = 'OCR processing encountered an issue: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update the draft record fields during verification
  void updateDraftRecord(PatientRecord updated) {
    _draftRecord = updated;
    _detectedDuplicates = HiveStorageService.findDuplicates(updated);
    notifyListeners();
  }

  /// Save the verified draft record to Hive
  Future<void> saveDraftRecord() async {
    if (_draftRecord == null) return;
    await HiveStorageService.saveRecord(_draftRecord!);
    _records = HiveStorageService.getAllRecords();
    _draftRecord = null;
    _activeImageBytes = null;
    _activeImagePath = null;
    _detectedDuplicates = [];
    notifyListeners();
  }

  /// Save an existing or updated record directly
  Future<void> saveRecord(PatientRecord record) async {
    await HiveStorageService.saveRecord(record);
    _records = HiveStorageService.getAllRecords();
    notifyListeners();
  }

  /// Delete a record
  Future<void> deleteRecord(String id) async {
    await HiveStorageService.deleteRecord(id);
    _records = HiveStorageService.getAllRecords();
    notifyListeners();
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Preload asset sample for testing
  Future<void> loadSampleAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    await processDocumentImage(bytes, filePath: assetPath);
  }

  Future<void> _seedInitialDemoData() async {
    // Seed Sample 1
    try {
      final s1Data = await rootBundle.load('assets/samples/sample_1_handwritten_rx.jpg');
      final s1 = await OcrEngine.processDentalDocument(
        imageBytes: s1Data.buffer.asUint8List(),
        filePath: 'assets/samples/sample_1_handwritten_rx.jpg',
      );
      await HiveStorageService.saveRecord(s1);

      final s2Data = await rootBundle.load('assets/samples/sample_2_printed_chart.jpg');
      final s2 = await OcrEngine.processDentalDocument(
        imageBytes: s2Data.buffer.asUint8List(),
        filePath: 'assets/samples/sample_2_printed_chart.jpg',
      );
      await HiveStorageService.saveRecord(s2);
    } catch (_) {
      // Ignore if assets not loaded in background
    }
  }
}

class PatientGroup {
  final String patientName;
  final int? age;
  final String? gender;
  final String? phone;
  final List<PatientRecord> visits;

  PatientGroup({
    required this.patientName,
    this.age,
    this.gender,
    this.phone,
    required this.visits,
  });

  double get totalBilled => visits.fold(0.0, (sum, v) => sum + v.estimatedCost);
  double get totalBalanceDue => visits.fold(0.0, (sum, v) => sum + v.balanceDue);
  List<String> get allAllergies => visits.expand((v) => v.allergies).toSet().toList();
  List<String> get allProcedures => visits.expand((v) => v.toothProcedures.map((p) => '#${p.toothNumber} ${p.procedureName}')).toSet().toList();
  DateTime get latestVisitDate => visits.map((v) => v.recordDate).reduce((a, b) => a.isAfter(b) ? a : b);
}
