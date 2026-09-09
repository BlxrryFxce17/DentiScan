import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_record.dart';
import '../../models/tooth_procedure.dart';
import '../../models/prescription_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/dental_constants.dart';
import '../providers/dental_records_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/odontogram_widget.dart';
import 'patient_detail_screen.dart';

class ReviewEditScreen extends StatefulWidget {
  final PatientRecord initialRecord;
  final Uint8List? documentImageBytes;

  const ReviewEditScreen({
    super.key,
    required this.initialRecord,
    this.documentImageBytes,
  });

  @override
  State<ReviewEditScreen> createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  late PatientRecord _record;

  // Controllers for Patient
  late TextEditingController _patientNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _phoneController;

  // Controllers for Doctor
  late TextEditingController _doctorNameController;
  late TextEditingController _clinicNameController;
  late TextEditingController _qualificationController;
  late TextEditingController _regNumController;

  // Controllers for Chief Complaint
  late TextEditingController _chiefComplaintController;

  // Controllers for Treatment Plan
  late TextEditingController _treatmentPlanController;
  late TextEditingController _diagnosisController;

  // Controllers for Financials
  late TextEditingController _estimatedCostController;
  late TextEditingController _insuranceController;
  late TextEditingController _advancePaidController;
  late TextEditingController _balanceDueController;

  // New item controllers for chips
  final TextEditingController _newMedicalHistoryController = TextEditingController();
  final TextEditingController _newDentalHistoryController = TextEditingController();
  final TextEditingController _newAllergyController = TextEditingController();
  final TextEditingController _newHabitController = TextEditingController();

  String? _selectedToothOnOdontogram;
  bool _showDocumentPreview = false;
  String _selectedPaymentMethod = 'UPI / QR (GPay, PhonePe)';

  @override
  void initState() {
    super.initState();
    _record = widget.initialRecord;
    _selectedPaymentMethod = _record.paymentMethod ?? 'UPI / QR (GPay, PhonePe)';

    _patientNameController = TextEditingController(text: _record.patientName);
    _ageController = TextEditingController(text: _record.age != null ? _record.age.toString() : '');
    _genderController = TextEditingController(text: _record.gender ?? '');
    _phoneController = TextEditingController(text: _record.phone ?? '');

    _doctorNameController = TextEditingController(text: _record.doctorName);
    _clinicNameController = TextEditingController(text: _record.clinicName);
    _qualificationController = TextEditingController(text: _record.doctorQualification ?? '');
    _regNumController = TextEditingController(text: _record.registrationNumber ?? '');

    _chiefComplaintController = TextEditingController(text: _record.chiefComplaint);
    _treatmentPlanController = TextEditingController(text: _record.treatmentPlan);
    _diagnosisController = TextEditingController(text: _record.clinicalDiagnosis ?? '');

    _estimatedCostController = TextEditingController(text: _record.estimatedCost > 0 ? _record.estimatedCost.toStringAsFixed(2) : '');
    _insuranceController = TextEditingController(text: _record.insuranceCovered > 0 ? _record.insuranceCovered.toStringAsFixed(2) : '');
    _advancePaidController = TextEditingController(text: _record.advancePaid > 0 ? _record.advancePaid.toStringAsFixed(2) : '');
    _balanceDueController = TextEditingController(text: _record.balanceDue > 0 ? _record.balanceDue.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();

    _doctorNameController.dispose();
    _clinicNameController.dispose();
    _qualificationController.dispose();
    _regNumController.dispose();

    _chiefComplaintController.dispose();
    _treatmentPlanController.dispose();
    _diagnosisController.dispose();

    _estimatedCostController.dispose();
    _insuranceController.dispose();
    _advancePaidController.dispose();
    _balanceDueController.dispose();

    _newMedicalHistoryController.dispose();
    _newDentalHistoryController.dispose();
    _newAllergyController.dispose();
    _newHabitController.dispose();
    super.dispose();
  }

  void _recalculateBalance() {
    final est = double.tryParse(_estimatedCostController.text) ?? 0.0;
    final ins = double.tryParse(_insuranceController.text) ?? 0.0;
    final adv = double.tryParse(_advancePaidController.text) ?? 0.0;
    final bal = est - ins - adv;
    _balanceDueController.text = bal > 0 ? bal.toStringAsFixed(2) : '0.00';
  }

  void _syncTotalBillFromProcedures() {
    final sum = _record.toothProcedures.fold<double>(
      0.0,
      (total, p) => total + (p.estimatedCost ?? 0.0),
    );
    if (sum > 0) {
      _estimatedCostController.text = sum.toStringAsFixed(2);
      _recalculateBalance();
    }
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDeletablePill({
    required String text,
    required VoidCallback onDeleted,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    final bg = backgroundColor ?? AppTheme.slate100;
    final fg = textColor ?? AppTheme.slate800;
    final border = borderColor ?? AppTheme.slate200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDeleted,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 13, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  void _addPrescriptionDialog() {
    DentalPrescriptionOption selectedRx = DentalConstants.prescriptionCatalog.first;
    bool isCustom = false;
    final nameCtrl = TextEditingController();
    String selectedDosage = selectedRx.defaultDosage;
    String selectedDuration = selectedRx.defaultDuration;
    final instrCtrl = TextEditingController(text: selectedRx.defaultInstructions);

    final dosageOptions = ['TDS (3 times/day)', 'BD (2 times/day)', 'OD (Once daily)', 'SOS (As needed)'];
    final durationOptions = ['3 Days', '5 Days', '7 Days', '10 Days', '14 Days'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medication_rounded, color: AppTheme.primaryTeal, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Add Medication (Rx)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MEDICATION / DRUG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: selectedRx.medicineName,
                    items: DentalConstants.prescriptionCatalog.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.medicineName,
                        child: Text(p.medicineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = DentalConstants.prescriptionCatalog.firstWhere((p) => p.medicineName == val);
                        setDialogState(() {
                          selectedRx = found;
                          isCustom = found.medicineName == 'Custom / Other Medicine';
                          selectedDosage = found.defaultDosage;
                          selectedDuration = found.defaultDuration;
                          instrCtrl.text = found.defaultInstructions;
                        });
                      }
                    },
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Custom Medicine Name',
                        hintText: 'e.g. Cefixime 200mg',
                        filled: true,
                        fillColor: AppTheme.slate50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  const Text('DOSAGE FREQUENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: dosageOptions.map((d) {
                      final isSel = selectedDosage == d;
                      return ChoiceChip(
                        label: Text(d),
                        selected: isSel,
                        selectedColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.slate700, fontWeight: FontWeight.w600, fontSize: 11.5),
                        backgroundColor: AppTheme.slate100,
                        side: BorderSide(color: isSel ? AppTheme.primaryTeal : AppTheme.slate200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        showCheckmark: false,
                        onSelected: (sel) {
                          if (sel) setDialogState(() => selectedDosage = d);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  const Text('DURATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: durationOptions.map((dur) {
                      final isSel = selectedDuration == dur;
                      return ChoiceChip(
                        label: Text(dur),
                        selected: isSel,
                        selectedColor: AppTheme.accentCyan,
                        labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.slate700, fontWeight: FontWeight.w600, fontSize: 11.5),
                        backgroundColor: AppTheme.slate100,
                        side: BorderSide(color: isSel ? AppTheme.accentCyan : AppTheme.slate200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        showCheckmark: false,
                        onSelected: (sel) {
                          if (sel) setDialogState(() => selectedDuration = dur);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  const Text('INSTRUCTIONS / ADVICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: instrCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.slate600)),
              ),
              ElevatedButton(
                onPressed: () {
                  final finalName = isCustom && nameCtrl.text.trim().isNotEmpty
                      ? nameCtrl.text.trim()
                      : selectedRx.medicineName;
                  final newItem = PrescriptionItem(
                    medicineName: finalName,
                    dosage: selectedDosage,
                    duration: selectedDuration,
                    instructions: instrCtrl.text.trim().isNotEmpty ? instrCtrl.text.trim() : null,
                  );
                  final updatedList = List<PrescriptionItem>.from(_record.prescriptions)..add(newItem);
                  setState(() {
                    _record = _record.copyWith(prescriptions: updatedList);
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('Add Medication', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addToothProcedureDialog([String? defaultTooth]) {
    String selectedTooth = defaultTooth ?? '46';
    if (!DentalConstants.teeth.containsKey(selectedTooth)) {
      selectedTooth = '46';
    }

    DentalTreatmentOption selectedTreatment = DentalConstants.treatmentCatalog.first;
    String selectedSurface = selectedTreatment.defaultSurface;
    final customProcCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: selectedTreatment.defaultCost.toStringAsFixed(0));
    bool isCustomProc = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_task_rounded, color: AppTheme.primaryTeal, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Add Tooth Procedure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tooth Dropdown
                  const Text(
                    'TOOTH NUMBER (FDI)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: selectedTooth,
                    items: DentalConstants.teeth.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          '#${e.key} — ${e.value.name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedTooth = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Treatment Procedure Dropdown
                  const Text(
                    'SELECT TREATMENT / PROCEDURE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: selectedTreatment.name,
                    items: DentalConstants.treatmentCatalog.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.name,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (t.name != 'Custom / Other Procedure')
                              Text(
                                '₹${t.defaultCost.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = DentalConstants.treatmentCatalog.firstWhere((t) => t.name == val);
                        setDialogState(() {
                          selectedTreatment = found;
                          isCustomProc = found.name == 'Custom / Other Procedure';
                          selectedSurface = found.defaultSurface;
                          costCtrl.text = found.defaultCost.toStringAsFixed(0);
                        });
                      }
                    },
                  ),

                  if (isCustomProc) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customProcCtrl,
                      decoration: InputDecoration(
                        labelText: 'Custom Procedure Description',
                        hintText: 'Enter clinical procedure name...',
                        filled: true,
                        fillColor: AppTheme.slate50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 3. Tooth Surface Dropdown
                  const Text(
                    'TREATED SURFACE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: DentalConstants.surfaces.contains(selectedSurface) ? selectedSurface : DentalConstants.surfaces.first,
                    items: DentalConstants.surfaces.map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.slate900)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedSurface = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Estimated Cost Input
                  const Text(
                    'ESTIMATED PROCEDURE FEE (₹)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                      filled: true,
                      fillColor: AppTheme.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.slate600)),
              ),
              ElevatedButton(
                onPressed: () {
                  final procName = isCustomProc && customProcCtrl.text.trim().isNotEmpty
                      ? customProcCtrl.text.trim()
                      : selectedTreatment.name;

                  final newProc = ToothProcedure(
                    toothNumber: selectedTooth,
                    toothName: DentalConstants.getToothDescription(selectedTooth),
                    procedureName: procName,
                    surface: selectedSurface,
                    estimatedCost: double.tryParse(costCtrl.text.trim()) ?? selectedTreatment.defaultCost,
                  );
                  setState(() {
                    _record = _record.copyWith(
                      toothProcedures: [..._record.toothProcedures, newProc],
                    );
                    _syncTotalBillFromProcedures();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('Add Procedure', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editToothProcedureDialog(ToothProcedure proc, int index) {
    String selectedTooth = proc.toothNumber;
    if (!DentalConstants.teeth.containsKey(selectedTooth)) {
      selectedTooth = '46';
    }

    // Match with catalog or default to custom
    final matchingTreatment = DentalConstants.treatmentCatalog.firstWhere(
      (t) => t.name.toLowerCase() == proc.procedureName.toLowerCase(),
      orElse: () => DentalConstants.treatmentCatalog.last, // Custom
    );

    String selectedTreatmentName = matchingTreatment.name;
    bool isCustomProc = matchingTreatment.name == 'Custom / Other Procedure' || !DentalConstants.treatmentCatalog.any((t) => t.name == proc.procedureName);
    final customProcCtrl = TextEditingController(text: isCustomProc ? proc.procedureName : '');
    String selectedSurface = proc.surface ?? DentalConstants.surfaces.first;
    final costCtrl = TextEditingController(text: proc.estimatedCost?.toStringAsFixed(0) ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: AppTheme.accentCyan, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Edit Procedure #${proc.toothNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tooth Dropdown
                  const Text(
                    'TOOTH NUMBER (FDI)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: selectedTooth,
                    items: DentalConstants.teeth.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          '#${e.key} — ${e.value.name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedTooth = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Treatment Dropdown
                  const Text(
                    'SELECT TREATMENT / PROCEDURE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: isCustomProc ? 'Custom / Other Procedure' : selectedTreatmentName,
                    items: DentalConstants.treatmentCatalog.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.name,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (t.name != 'Custom / Other Procedure')
                              Text(
                                '₹${t.defaultCost.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = DentalConstants.treatmentCatalog.firstWhere((t) => t.name == val);
                        setDialogState(() {
                          selectedTreatmentName = found.name;
                          isCustomProc = found.name == 'Custom / Other Procedure';
                          if (!isCustomProc) {
                            selectedSurface = found.defaultSurface;
                            costCtrl.text = found.defaultCost.toStringAsFixed(0);
                          }
                        });
                      }
                    },
                  ),

                  if (isCustomProc) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customProcCtrl,
                      decoration: InputDecoration(
                        labelText: 'Custom Procedure Description',
                        hintText: 'Enter clinical procedure name...',
                        filled: true,
                        fillColor: AppTheme.slate50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 3. Tooth Surface Dropdown
                  const Text(
                    'TREATED SURFACE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  _buildDropdownField<String>(
                    value: DentalConstants.surfaces.contains(selectedSurface) ? selectedSurface : DentalConstants.surfaces.first,
                    items: DentalConstants.surfaces.map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.slate900)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedSurface = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Estimated Cost Input
                  const Text(
                    'ESTIMATED PROCEDURE FEE (₹)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                      filled: true,
                      fillColor: AppTheme.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.slate600)),
              ),
              ElevatedButton(
                onPressed: () {
                  final procName = isCustomProc && customProcCtrl.text.trim().isNotEmpty
                      ? customProcCtrl.text.trim()
                      : selectedTreatmentName;

                  final updated = ToothProcedure(
                    toothNumber: selectedTooth,
                    toothName: DentalConstants.getToothDescription(selectedTooth),
                    procedureName: procName,
                    surface: selectedSurface,
                    estimatedCost: double.tryParse(costCtrl.text.trim()) ?? 0.0,
                    status: proc.status,
                  );
                  final list = List<ToothProcedure>.from(_record.toothProcedures);
                  list[index] = updated;
                  setState(() {
                    _record = _record.copyWith(toothProcedures: list);
                    _syncTotalBillFromProcedures();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (_patientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient name is required'), backgroundColor: AppTheme.accentCoral),
      );
      return;
    }

    final updated = _record.copyWith(
      patientName: _patientNameController.text.trim(),
      age: int.tryParse(_ageController.text),
      gender: _genderController.text.trim().isNotEmpty ? _genderController.text.trim() : null,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      doctorName: _doctorNameController.text.trim(),
      clinicName: _clinicNameController.text.trim(),
      doctorQualification: _qualificationController.text.trim(),
      registrationNumber: _regNumController.text.trim(),
      chiefComplaint: _chiefComplaintController.text.trim(),
      treatmentPlan: _treatmentPlanController.text.trim(),
      clinicalDiagnosis: _diagnosisController.text.trim(),
      estimatedCost: double.tryParse(_estimatedCostController.text) ?? 0.0,
      insuranceCovered: double.tryParse(_insuranceController.text) ?? 0.0,
      advancePaid: double.tryParse(_advancePaidController.text) ?? 0.0,
      balanceDue: double.tryParse(_balanceDueController.text) ?? 0.0,
      paymentMethod: _selectedPaymentMethod,
    );

    final provider = context.read<DentalRecordsProvider>();
    await provider.saveRecord(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record successfully stored in Hive!'), backgroundColor: AppTheme.accentEmerald),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(record: updated),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentalRecordsProvider>();
    final duplicates = provider.detectedDuplicates;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        title: const Text('Verify Extracted Record'),
        actions: [
          if (widget.documentImageBytes != null)
            TextButton.icon(
              icon: Icon(_showDocumentPreview ? Icons.visibility_off : Icons.image_outlined, color: AppTheme.primaryTeal),
              label: Text(_showDocumentPreview ? 'Hide Scan' : 'View Scan', style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              onPressed: () => setState(() => _showDocumentPreview = !_showDocumentPreview),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Optional collapsible document image viewer for side-by-side verification
          if (_showDocumentPreview && widget.documentImageBytes != null)
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.memory(widget.documentImageBytes!, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Original Scan • Pinch to Zoom', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),

          // Main Verification Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Duplicate Alert Banner if existing patient found
                if (duplicates.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentAmber, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.copy_rounded, color: AppTheme.accentAmber, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Potential Duplicate Record Detected',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.slate900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Patient "${_record.patientName}" already has ${duplicates.length} previous visit(s) in Hive. Saving will associate this new clinical note to their history.',
                                style: const TextStyle(fontSize: 12, color: AppTheme.slate700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Confidence Banner
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 18, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OCR extraction confidence: ${(_record.ocrConfidence * 100).toInt()}% • Verify fields before saving to Hive',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // 1. Patient Details
                CategoryCard(
                  title: '1. Patient Details',
                  subtitle: 'Demographics & identification',
                  icon: Icons.person_rounded,
                  child: Column(
                    children: [
                      TextField(
                        controller: _patientNameController,
                        decoration: const InputDecoration(labelText: 'Patient Full Name *'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 85,
                            child: TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Age'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'GENDER',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 6),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: ['Male', 'Female', 'Other'].map((g) {
                                      final isSelected = _genderController.text.trim().toLowerCase() == g.toLowerCase();
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: ChoiceChip(
                                          label: Text(g),
                                          selected: isSelected,
                                          selectedColor: AppTheme.primaryTeal,
                                          labelStyle: TextStyle(
                                            color: isSelected ? Colors.white : AppTheme.slate700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          backgroundColor: AppTheme.slate100,
                                          side: BorderSide(color: isSelected ? AppTheme.primaryTeal : AppTheme.slate200),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          showCheckmark: false,
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() => _genderController.text = g);
                                            }
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ),
                ),

                // 2. Doctor Details
                CategoryCard(
                  title: '2. Doctor Details',
                  subtitle: 'Practitioner & clinic registration',
                  icon: Icons.badge_rounded,
                  child: Column(
                    children: [
                      TextField(
                        controller: _doctorNameController,
                        decoration: const InputDecoration(labelText: 'Attending Doctor Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _clinicNameController,
                        decoration: const InputDecoration(labelText: 'Clinic / Hospital Name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _qualificationController,
                              decoration: const InputDecoration(labelText: 'Qualification'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _regNumController,
                              decoration: const InputDecoration(labelText: 'Reg / License #'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Chief Complaint
                CategoryCard(
                  title: '3. Chief Complaint',
                  subtitle: 'Patient reported symptoms & location',
                  icon: Icons.report_problem_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _chiefComplaintController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Symptoms & Duration',
                          hintText: 'e.g. Severe throbbing pain in tooth #46 for 4 days',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          'Severe Toothache',
                          'Bleeding Gums',
                          'Sensitivity to Hot/Cold',
                          'Cavity / Food Lodging',
                          'Swelling / Pus',
                          'Routine Checkup',
                        ].map((preset) {
                          return ActionChip(
                            avatar: const Icon(Icons.add_rounded, size: 13, color: AppTheme.primaryTeal),
                            label: Text(preset),
                            labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                            backgroundColor: AppTheme.slate50,
                            side: const BorderSide(color: AppTheme.slate200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setState(() {
                                if (_chiefComplaintController.text.trim().isEmpty) {
                                  _chiefComplaintController.text = preset;
                                } else if (!_chiefComplaintController.text.contains(preset)) {
                                  _chiefComplaintController.text = '${_chiefComplaintController.text.trim()}, $preset';
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 4. Medical History
                CategoryCard(
                  title: '4. Medical History',
                  subtitle: 'Systemic diseases & ongoing medication',
                  icon: Icons.monitor_heart_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _record.medicalHistory.map((item) {
                          return _buildDeletablePill(
                            text: item,
                            onDeleted: () {
                              setState(() {
                                final updated = List<String>.from(_record.medicalHistory)..remove(item);
                                _record = _record.copyWith(medicalHistory: updated);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newMedicalHistoryController,
                              decoration: const InputDecoration(
                                hintText: 'Add condition (e.g. Hypertension)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                            onPressed: () {
                              if (_newMedicalHistoryController.text.trim().isNotEmpty) {
                                setState(() {
                                  final updated = List<String>.from(_record.medicalHistory)..add(_newMedicalHistoryController.text.trim());
                                  _record = _record.copyWith(medicalHistory: updated);
                                  _newMedicalHistoryController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. Dental History
                CategoryCard(
                  title: '5. Dental History',
                  subtitle: 'Prior restorations & procedures',
                  icon: Icons.history_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _record.dentalHistory.map((item) {
                          return _buildDeletablePill(
                            text: item,
                            onDeleted: () {
                              setState(() {
                                final updated = List<String>.from(_record.dentalHistory)..remove(item);
                                _record = _record.copyWith(dentalHistory: updated);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newDentalHistoryController,
                              decoration: const InputDecoration(
                                hintText: 'Add history (e.g. Amalgam filling #36)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                            onPressed: () {
                              if (_newDentalHistoryController.text.trim().isNotEmpty) {
                                setState(() {
                                  final updated = List<String>.from(_record.dentalHistory)..add(_newDentalHistoryController.text.trim());
                                  _record = _record.copyWith(dentalHistory: updated);
                                  _newDentalHistoryController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 6. Allergies & Habits
                CategoryCard(
                  title: '6. Allergies & Habits',
                  subtitle: 'Critical drug reactions & lifestyle',
                  icon: Icons.warning_rounded,
                  accentColor: _record.allergies.isNotEmpty ? AppTheme.accentCoral : AppTheme.primaryTeal,
                  hasWarning: _record.allergies.isNotEmpty,
                  warningMessage: 'Critical Allergies Present',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DRUG / MATERIAL ALLERGIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentCoral)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _record.allergies.map((item) {
                          return _buildDeletablePill(
                            text: item,
                            backgroundColor: AppTheme.accentCoral.withValues(alpha: 0.12),
                            textColor: AppTheme.accentCoral,
                            borderColor: AppTheme.accentCoral.withValues(alpha: 0.3),
                            onDeleted: () {
                              setState(() {
                                final updated = List<String>.from(_record.allergies)..remove(item);
                                _record = _record.copyWith(allergies: updated);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newAllergyController,
                              decoration: const InputDecoration(
                                hintText: 'Add allergy (e.g. Penicillin, Latex)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.accentCoral),
                            onPressed: () {
                              if (_newAllergyController.text.trim().isNotEmpty) {
                                setState(() {
                                  final updated = List<String>.from(_record.allergies)..add(_newAllergyController.text.trim());
                                  _record = _record.copyWith(allergies: updated);
                                  _newAllergyController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('HABITS & LIFESTYLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _record.habits.map((item) {
                          return _buildDeletablePill(
                            text: item,
                            onDeleted: () {
                              setState(() {
                                final updated = List<String>.from(_record.habits)..remove(item);
                                _record = _record.copyWith(habits: updated);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newHabitController,
                              decoration: const InputDecoration(
                                hintText: 'Add habit (e.g. Non-smoker, Bruxism)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                            onPressed: () {
                              if (_newHabitController.text.trim().isNotEmpty) {
                                setState(() {
                                  final updated = List<String>.from(_record.habits)..add(_newHabitController.text.trim());
                                  _record = _record.copyWith(habits: updated);
                                  _newHabitController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 7. Treatment Plan
                CategoryCard(
                  title: '7. Treatment Plan',
                  subtitle: 'Clinical diagnosis & procedure roadmap',
                  icon: Icons.assignment_rounded,
                  child: Column(
                    children: [
                      TextField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(labelText: 'Clinical Diagnosis / Findings'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _treatmentPlanController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Recommended Treatment Plan'),
                      ),
                    ],
                  ),
                ),

                // 8. Procedures / Tooth Details (Interactive Odontogram)
                CategoryCard(
                  title: '8. Procedures / Tooth Details',
                  subtitle: 'Odontogram mapping & specific teeth procedures',
                  icon: Icons.view_compact_rounded,
                  trailing: TextButton.icon(
                    onPressed: () => _addToothProcedureDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Tooth'),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OdontogramWidget(
                        procedures: _record.toothProcedures,
                        selectedToothNumber: _selectedToothOnOdontogram,
                        onToothSelected: (toothNum) {
                          setState(() => _selectedToothOnOdontogram = toothNum);
                          final existingIndex = _record.toothProcedures.indexWhere((p) => p.toothNumber == toothNum);
                          if (existingIndex != -1) {
                            _editToothProcedureDialog(_record.toothProcedures[existingIndex], existingIndex);
                          } else {
                            _addToothProcedureDialog(toothNum);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('SPECIFIED TOOTH PROCEDURES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate600)),
                      const SizedBox(height: 8),
                      ..._record.toothProcedures.asMap().entries.map((entry) {
                        final index = entry.key;
                        final proc = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.slate100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.slate200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${proc.toothNumber}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(proc.procedureName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      '${proc.toothName ?? ""} • Surface: ${proc.surface ?? "General"}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.slate600),
                                    ),
                                  ],
                                ),
                              ),
                              if (proc.estimatedCost != null)
                                Text(
                                  '₹${proc.estimatedCost!.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.slate900),
                                ),
                              IconButton(
                                tooltip: 'Edit Procedure & Amount',
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                                onPressed: () => _editToothProcedureDialog(proc, index),
                              ),
                              IconButton(
                                tooltip: 'Delete Procedure',
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.accentCoral),
                                onPressed: () {
                                  final removed = proc;
                                  final removedIndex = index;
                                  setState(() {
                                    final updated = List.of(_record.toothProcedures)..removeAt(removedIndex);
                                    _record = _record.copyWith(toothProcedures: updated);
                                    _syncTotalBillFromProcedures();
                                  });
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Removed #${removed.toothNumber} ${removed.procedureName}'),
                                      duration: const Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: AppTheme.accentCyan,
                                        onPressed: () {
                                          setState(() {
                                            final restored = List.of(_record.toothProcedures);
                                            if (removedIndex <= restored.length) {
                                              restored.insert(removedIndex, removed);
                                            } else {
                                              restored.add(removed);
                                            }
                                            _record = _record.copyWith(toothProcedures: restored);
                                            _syncTotalBillFromProcedures();
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // 9. Payment / Financial Details
                CategoryCard(
                  title: '9. Payment & Prescriptions',
                  subtitle: 'Billing summary, insurance & medication',
                  icon: Icons.payments_rounded,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        ),
                        onPressed: () => _addPrescriptionDialog(),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Rx', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.slate600,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        ),
                        onPressed: _syncTotalBillFromProcedures,
                        icon: const Icon(Icons.calculate_outlined, size: 16),
                        label: const Text('Sync Bill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Dynamic Live Billing Summary Breakdown
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryTeal.withValues(alpha: 0.08), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Procedures Itemized Sum:', style: TextStyle(fontSize: 12, color: AppTheme.slate600, fontWeight: FontWeight.w500)),
                                Text(
                                  '₹${_record.toothProcedures.fold<double>(0.0, (sum, p) => sum + (p.estimatedCost ?? 0.0)).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Less Insurance Coverage:', style: TextStyle(fontSize: 12, color: AppTheme.slate600, fontWeight: FontWeight.w500)),
                                Text(
                                  '-₹${(double.tryParse(_insuranceController.text) ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0891B2)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Less Advance / Copay Paid:', style: TextStyle(fontSize: 12, color: AppTheme.slate600, fontWeight: FontWeight.w500)),
                                Text(
                                  '-₹${(double.tryParse(_advancePaidController.text) ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.accentEmerald),
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(height: 1, color: AppTheme.slate200)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Calculated Balance Due:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.slate900)),
                                Text(
                                  '₹${(double.tryParse(_balanceDueController.text) ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _estimatedCostController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _recalculateBalance(),
                              decoration: const InputDecoration(labelText: 'Total Cost (₹)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _insuranceController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _recalculateBalance(),
                              decoration: const InputDecoration(labelText: 'Insurance (₹)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _advancePaidController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _recalculateBalance(),
                              decoration: const InputDecoration(labelText: 'Paid / Copay (₹)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _balanceDueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Balance Due (₹)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quick Billing Actions
                      Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accentEmerald),
                            label: const Text('Paid in Full (₹0 Due)'),
                            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentEmerald),
                            backgroundColor: AppTheme.accentEmerald.withValues(alpha: 0.1),
                            side: BorderSide(color: AppTheme.accentEmerald.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              final total = double.tryParse(_estimatedCostController.text) ?? 0.0;
                              final ins = double.tryParse(_insuranceController.text) ?? 0.0;
                              final net = (total - ins).clamp(0.0, double.infinity);
                              setState(() {
                                _advancePaidController.text = net.toStringAsFixed(2);
                                _recalculateBalance();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.percent_rounded, size: 13, color: AppTheme.accentAmber),
                            label: const Text('-10% Discount'),
                            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentAmber),
                            backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.1),
                            side: BorderSide(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              final total = double.tryParse(_estimatedCostController.text) ?? 0.0;
                              if (total > 0) {
                                final discounted = (total * 0.90);
                                setState(() {
                                  _estimatedCostController.text = discounted.toStringAsFixed(2);
                                  _recalculateBalance();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Payment Method Selector
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PAYMENT METHOD',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'UPI / QR (GPay, PhonePe)',
                            'Cash',
                            'Credit / Debit Card',
                            'Insurance Claim',
                          ].map((method) {
                            final isSel = _selectedPaymentMethod == method;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(method),
                                selected: isSel,
                                selectedColor: AppTheme.primaryTeal,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppTheme.slate700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppTheme.slate100,
                                side: BorderSide(color: isSel ? AppTheme.primaryTeal : AppTheme.slate200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                showCheckmark: false,
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedPaymentMethod = method);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PRESCRIPTION MEDICATIONS (Rx)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate600)),
                          Text(
                            '${_record.prescriptions.length} item(s)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slate400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_record.prescriptions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.slate50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.slate200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.slate400),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'No medications added yet. Tap "+ Add Rx" above to prescribe dental medications.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._record.prescriptions.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final rx = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.slate50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.slate200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.medication_rounded, size: 18, color: AppTheme.primaryTeal),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rx.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.slate900)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${rx.dosage} • ${rx.duration}${rx.instructions != null && rx.instructions!.isNotEmpty ? " (${rx.instructions})" : ""}',
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.slate600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove Medication',
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.accentCoral),
                                  onPressed: () {
                                    setState(() {
                                      final updatedList = List<PrescriptionItem>.from(_record.prescriptions)..removeAt(idx);
                                      _record = _record.copyWith(prescriptions: updatedList);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _saveRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Save Record to Hive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
