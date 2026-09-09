import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../providers/dental_records_provider.dart';
import '../../core/constants/dental_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/patient_record.dart';
import '../widgets/sample_picker_sheet.dart';
import 'scan_upload_screen.dart';
import 'patient_detail_screen.dart';
import 'pdf_preview_screen.dart';
import 'review_edit_screen.dart';
import '../widgets/ai_settings_dialog.dart';
import '../../core/utils/document_scanner_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = Visits/Records, 1 = Patients Directory

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DentalRecordsProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSamplePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SamplePickerSheet(
        onSelectAsset: (assetPath) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(preselectedAssetPath: assetPath),
            ),
          );
        },
        onCaptureCamera: _captureCamera,
        onPickGallery: _pickGallery,
      ),
    );
  }

  Future<void> _captureCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                customBytes: bytes,
                customFileName: 'Camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera capture error: $e'),
            backgroundColor: AppTheme.accentCoral,
          ),
        );
      }
    }
  }

  Future<void> _pickGallery() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanUploadScreen(
                customBytes: bytes,
                customFileName: photo.name,
              ),
            ),
          );
        }
      }
    } catch (e) {
      _pickCustomFile();
    }
  }

  Future<void> _pickCustomFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanUploadScreen(
              customBytes: bytes,
              customFileName: file.name,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentalRecordsProvider>();
    final records = provider.filteredRecords;
    final patientGroups = provider.filteredPatientGroups;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DentiScan AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slate900, letterSpacing: -0.3),
                ),
                Text(
                  'Clinical OCR & Practice Management',
                  style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AI Scanning Settings',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology_rounded, color: AppTheme.accentCyan, size: 20),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AiSettingsDialog(),
              );
            },
          ),
          IconButton(
            tooltip: 'Load Benchmark Samples',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryTeal, size: 20),
            ),
            onPressed: _openSamplePicker,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedTab == 0
          ? _buildVisitsTab(provider, records)
          : _buildPatientsTab(provider, patientGroups),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.slate200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) => setState(() => _selectedTab = index),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.assignment_outlined, color: AppTheme.slate600),
              selectedIcon: const Icon(Icons.assignment_rounded, color: AppTheme.primaryTeal),
              label: 'Visits (${records.length})',
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded, color: AppTheme.slate600),
              selectedIcon: const Icon(Icons.people_rounded, color: AppTheme.primaryTeal),
              label: 'Patients (${patientGroups.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSamplePicker,
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan Record', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      ),
    );
  }

  // TAB 0: Clinical Visits View
  Widget _buildVisitsTab(DentalRecordsProvider provider, List<PatientRecord> records) {
    return RefreshIndicator(
      color: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await provider.loadRecords();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildQuickActionBar(),
                  const SizedBox(height: 16),
                  _buildStatsRow(provider.records),
                  const SizedBox(height: 16),
                  _buildSearchBar(provider),
                ],
              ),
            ),
          ),

          // Visits List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CLINICAL VISITS (${records.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppTheme.slate600,
                            ),
                          ),
                        ],
                      ),
                      if (provider.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                          child: const Text('Clear Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                        ),
                    ],
                  ),
                  if (records.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.swipe_rounded, size: 12, color: AppTheme.slate400),
                        SizedBox(width: 4),
                        Text(
                          'Swipe right for PDF, left to delete • Long-press for shortcuts',
                          style: TextStyle(fontSize: 10.5, color: AppTheme.slate400, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Visits List
          if (records.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(provider),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = records[index];
                    return _buildRecordCard(record);
                  },
                  childCount: records.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // TAB 1: Patients Directory View (Clinician's Patient Folder View)
  Widget _buildPatientsTab(DentalRecordsProvider provider, List<PatientGroup> groups) {
    return RefreshIndicator(
      color: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await provider.loadRecords();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(provider),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PATIENT PROFILES (${groups.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (groups.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(provider),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final group = groups[index];
                  return _buildPatientGroupCard(group);
                },
                childCount: groups.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
      ),
    );
  }

  Widget _buildPatientGroupCard(PatientGroup group) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final hasBalance = group.totalBalanceDue > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              group.patientName.isNotEmpty ? group.patientName[0].toUpperCase() : 'P',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.patientName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slate900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${group.visits.length} Visit${group.visits.length > 1 ? "s" : ""}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                '${group.age != null ? "${group.age} yrs" : "Age N/A"} • ${group.gender ?? "N/A"} • ${group.phone ?? "No phone"}',
                style: const TextStyle(fontSize: 12, color: AppTheme.slate600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Lifetime: ${DentalConstants.currencySymbol}${group.totalBilled.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.slate800),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasBalance ? AppTheme.accentAmber.withValues(alpha: 0.12) : AppTheme.accentEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hasBalance ? '${DentalConstants.currencySymbol}${group.totalBalanceDue.toStringAsFixed(0)} due' : 'Settled',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: hasBalance ? const Color(0xFFD97706) : AppTheme.accentEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              if (group.allAllergies.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.accentCoral),
                      const SizedBox(width: 4),
                      Text(
                        'Allergies: ${group.allAllergies.join(", ")}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.accentCoral),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(color: AppTheme.slate100, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CHRONOLOGICAL VISIT TIMELINE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                ),
                Text(
                  'Last visit: ${dateFormat.format(group.latestVisitDate)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.slate600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...group.visits.map((visit) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medical_information_outlined, size: 18, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(visit.recordDate),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                          ),
                          Text(
                            visit.chiefComplaint,
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.slate600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (visit.toothProcedures.isNotEmpty)
                            Text(
                              visit.toothProcedures.map((p) => '#${p.toothNumber} ${p.procedureName}').join(', '),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${DentalConstants.currencySymbol}${visit.estimatedCost.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDetailScreen(record: visit),
                              ),
                            );
                          },
                          child: const Text('Open Chart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBar() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt_rounded, size: 14, color: Colors.amberAccent),
                    SizedBox(width: 4),
                    Text(
                      'AI OCR Engine Active',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Text(
                '9 Categories',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Scan & Structure Dental Record',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Extracts handwritten charts, FDI odontogram, medications & bills in INR',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _openSamplePicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Start', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<PatientRecord> records) {
    int totalProcedures = 0;
    double totalRevenue = 0.0;
    for (final r in records) {
      totalProcedures += r.toothProcedures.length;
      totalRevenue += r.estimatedCost;
    }

    return Row(
      children: [
        Expanded(child: _metricCard('Patients', '${records.length}', Icons.people_alt_outlined, AppTheme.primaryTeal)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('Procedures', '$totalProcedures', Icons.medical_services_outlined, AppTheme.accentCyan)),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            'Est. Value',
            '${DentalConstants.currencySymbol}${totalRevenue.toStringAsFixed(0)}',
            Icons.currency_rupee_rounded,
            AppTheme.accentEmerald,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slate400, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.slate900)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DentalRecordsProvider provider) {
    return TextField(
      controller: _searchController,
      onChanged: provider.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search patient, doctor, tooth #, symptoms...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryTeal, size: 20),
        suffixIcon: provider.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppTheme.slate400),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildRecordCard(PatientRecord record) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final hasBalance = record.balanceDue > 0;

    return Dismissible(
      key: ValueKey('record_${record.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: const [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Open PDF',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.accentCoral,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Delete Visit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfPreviewScreen(record: record),
            ),
          );
          return false;
        } else {
          HapticFeedback.heavyImpact();
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Clinical Visit?'),
              content: Text('Delete record for "${record.patientName}"? This action cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            await context.read<DentalRecordsProvider>().deleteRecord(record.id);
            return true;
          }
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailScreen(record: record),
              ),
            );
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showRecordQuickActions(record);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Header & Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        record.patientName.isNotEmpty ? record.patientName[0].toUpperCase() : 'P',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.patientName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slate900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.age != null ? "${record.age} yrs" : "Age N/A"} • ${record.gender ?? "N/A"} • ${record.phone ?? "No phone"}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.slate400, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.slate100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dateFormat.format(record.recordDate),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slate600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasBalance
                                ? AppTheme.accentAmber.withValues(alpha: 0.12)
                                : AppTheme.accentEmerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasBalance
                                ? '${DentalConstants.currencySymbol}${record.balanceDue.toStringAsFixed(0)} due'
                                : 'Paid',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: hasBalance ? const Color(0xFFD97706) : AppTheme.accentEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: AppTheme.slate100, height: 1),
                const SizedBox(height: 10),

                // Chief Complaint & Diagnosis
                if (record.chiefComplaint.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppTheme.primaryTeal),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          record.chiefComplaint,
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.slate700, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Procedures Badges
                if (record.toothProcedures.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: record.toothProcedures.take(3).map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '#${p.toothNumber} ${p.procedureName}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                        ),
                      );
                    }).toList(),
                  ),
                  if (record.toothProcedures.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+${record.toothProcedures.length - 3} more procedures',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate400, fontWeight: FontWeight.w500),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],

                // Footer with Financials, Prescriptions & Quick Tap
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (record.prescriptions.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.slate100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medication_outlined, size: 13, color: AppTheme.slate600),
                                const SizedBox(width: 4),
                                Text(
                                  '${record.prescriptions.length} Rx',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slate600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'Total: ${DentalConstants.currencySymbol}${record.estimatedCost.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate900),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Export PDF Report',
                          icon: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: AppTheme.accentCoral),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfPreviewScreen(record: record),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.slate400),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecordQuickActions(PatientRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final dateFormat = DateFormat('MMMM dd, yyyy');
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      record.patientName.isNotEmpty ? record.patientName[0].toUpperCase() : 'P',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.patientName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                        ),
                        Text(
                          '${dateFormat.format(record.recordDate)} • ${record.clinicName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.slate400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.slate100, height: 1),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_information_outlined, color: AppTheme.primaryTeal, size: 20),
                ),
                title: const Text('Open Clinical Chart', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('View diagnoses, tooth odontogram & Rx', style: TextStyle(fontSize: 11.5, color: AppTheme.slate400)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(record: record),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 20),
                ),
                title: const Text('Preview & Share PDF Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Official dental report ready for export', style: TextStyle(fontSize: 11.5, color: AppTheme.slate400)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewScreen(record: record),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: AppTheme.accentCyan, size: 20),
                ),
                title: const Text('Rescan & Overwrite Visit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Capture or upload new image to update this visit', style: TextStyle(fontSize: 11.5, color: AppTheme.slate400)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentScannerHelper.openScannerModal(
                    context,
                    existingRecord: record,
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Colors.amber, size: 20),
                ),
                title: const Text('Edit Extracted Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Edit patient demographics, procedures, or bill', style: TextStyle(fontSize: 11.5, color: AppTheme.slate400)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewEditScreen(initialRecord: record),
                    ),
                  );
                },
              ),
              const Divider(color: AppTheme.slate100, height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentCoral, size: 20),
                ),
                title: const Text('Delete Record', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.accentCoral)),
                subtitle: const Text('Remove record permanently from Hive', style: TextStyle(fontSize: 11.5, color: AppTheme.slate400)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Delete Record?'),
                      content: Text('Are you sure you want to delete the clinical record for "${record.patientName}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
                          onPressed: () => Navigator.pop(dCtx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await context.read<DentalRecordsProvider>().deleteRecord(record.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(DentalRecordsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.primaryTeal),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Dental Records Found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.slate900),
            ),
            const SizedBox(height: 6),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'No records match "${provider.searchQuery}". Try a different keyword.'
                  : 'Get started by scanning or uploading a dental record document.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.slate400),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openSamplePicker,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Scan / Load Sample Record'),
            ),
          ],
        ),
      ),
    );
  }
}
