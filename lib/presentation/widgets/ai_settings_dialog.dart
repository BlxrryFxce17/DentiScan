import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/hive_storage_service.dart';
import '../../services/gemini_vision_service.dart';
import '../../services/mistral_vision_service.dart';

class AiSettingsDialog extends StatefulWidget {
  const AiSettingsDialog({super.key});

  @override
  State<AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends State<AiSettingsDialog> {
  late TextEditingController _geminiApiKeyController;
  late TextEditingController _mistralApiKeyController;
  late String _engineMode;

  bool _testingGeminiKey = false;
  String? _geminiTestResult;
  bool _geminiTestSuccess = false;
  bool _hasExistingGeminiKey = false;

  bool _testingMistralKey = false;
  String? _mistralTestResult;
  bool _mistralTestSuccess = false;
  bool _hasExistingMistralKey = false;

  @override
  void initState() {
    super.initState();
    _hasExistingGeminiKey = HiveStorageService.hasGeminiApiKey();
    _hasExistingMistralKey = HiveStorageService.hasMistralApiKey();

    _geminiApiKeyController = TextEditingController();
    _mistralApiKeyController = TextEditingController();
    _engineMode = HiveStorageService.getOcrEngineMode();
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    _mistralApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testGeminiConnection() async {
    final keyToTest = _geminiApiKeyController.text.trim().isNotEmpty
        ? _geminiApiKeyController.text.trim()
        : HiveStorageService.getGeminiApiKey();

    if (keyToTest.isEmpty) {
      setState(() {
        _geminiTestResult = 'No Gemini key configured.';
        _geminiTestSuccess = false;
      });
      return;
    }

    setState(() {
      _testingGeminiKey = true;
      _geminiTestResult = null;
    });

    final success = await GeminiVisionService.testApiKey(keyToTest);

    if (mounted) {
      setState(() {
        _testingGeminiKey = false;
        _geminiTestSuccess = success;
        _geminiTestResult = success
            ? '✓ Connection successful! Google Reader is ready.'
            : '✗ Key verification failed. Please check key or internet.';
      });
    }
  }

  Future<void> _testMistralConnection() async {
    final keyToTest = _mistralApiKeyController.text.trim().isNotEmpty
        ? _mistralApiKeyController.text.trim()
        : HiveStorageService.getMistralApiKey();

    if (keyToTest.isEmpty) {
      setState(() {
        _mistralTestResult = 'No Mistral key configured.';
        _mistralTestSuccess = false;
      });
      return;
    }

    setState(() {
      _testingMistralKey = true;
      _mistralTestResult = null;
    });

    final success = await MistralVisionService.testApiKey(keyToTest);

    if (mounted) {
      setState(() {
        _testingMistralKey = false;
        _mistralTestSuccess = success;
        _mistralTestResult = success
            ? '✓ Connection successful! Mistral Reader is ready.'
            : '✗ Key verification failed. Please check key or internet.';
      });
    }
  }

  Future<void> _saveSettings() async {
    final newGeminiKey = _geminiApiKeyController.text.trim();
    if (newGeminiKey.isNotEmpty) {
      await HiveStorageService.saveGeminiApiKey(newGeminiKey);
    }
    final newMistralKey = _mistralApiKeyController.text.trim();
    if (newMistralKey.isNotEmpty) {
      await HiveStorageService.saveMistralApiKey(newMistralKey);
    }
    await HiveStorageService.saveOcrEngineMode(_engineMode);
    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanner settings updated successfully.'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
    }
  }

  Future<void> _clearGeminiKey() async {
    await HiveStorageService.saveGeminiApiKey('');
    setState(() {
      _hasExistingGeminiKey = false;
      _geminiApiKeyController.clear();
      _geminiTestResult = 'Google key removed.';
      _geminiTestSuccess = false;
    });
  }

  Future<void> _clearMistralKey() async {
    await HiveStorageService.saveMistralApiKey('');
    setState(() {
      _hasExistingMistralKey = false;
      _mistralApiKeyController.clear();
      _mistralTestResult = 'Mistral key removed.';
      _mistralTestSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppTheme.primaryTeal, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scanner & Reading Settings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                          ),
                          Text(
                            'Choose how prescriptions and dental records are read',
                            style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // OCR Engine Selection
                const Text(
                  'HOW TO READ PRESCRIPTIONS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),

                _buildEngineRadio(
                  title: 'Smart Auto (Recommended)',
                  subtitle: 'Fastest and most reliable. Automatically switches to backup reader if connection is busy.',
                  value: 'auto',
                  icon: Icons.auto_awesome_rounded,
                  badge: 'RECOMMENDED',
                  badgeColor: AppTheme.accentEmerald,
                ),
                const SizedBox(height: 8),
                _buildEngineRadio(
                  title: 'Double-Check Mode (Highest Accuracy)',
                  subtitle: 'Two AI readers cross-check the document together. Best for challenging doctor handwriting.',
                  value: 'consensus',
                  icon: Icons.fact_check_rounded,
                  badge: 'MOST ACCURATE',
                  badgeColor: AppTheme.accentAmber,
                ),
                const SizedBox(height: 8),
                _buildEngineRadio(
                  title: 'Google Cloud Reader',
                  subtitle: 'Direct high-speed reading for printed clinical charts and clear prescription notes.',
                  value: 'gemini',
                  icon: Icons.cloud_done_rounded,
                  badge: 'FAST',
                  badgeColor: AppTheme.accentCyan,
                ),
                const SizedBox(height: 8),
                _buildEngineRadio(
                  title: 'Mistral Cloud Reader',
                  subtitle: 'Reliable alternative reader for clinical bills, treatments, and prescriptions.',
                  value: 'mistral',
                  icon: Icons.cloud_outlined,
                  badge: 'BACKUP',
                  badgeColor: AppTheme.slate600,
                ),
                const SizedBox(height: 8),
                _buildEngineRadio(
                  title: 'Offline Mode (No Internet)',
                  subtitle: 'Reads directly on this device without sending data online. Best for clear printed text.',
                  value: 'mlkit',
                  icon: Icons.wifi_off_rounded,
                  badge: 'OFFLINE',
                  badgeColor: AppTheme.slate600,
                ),

                const SizedBox(height: 22),

                // OPTIONAL SERVICE KEYS SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CUSTOM ACCESS KEYS (OPTIONAL)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                    ),
                    if (_hasExistingGeminiKey || _hasExistingMistralKey)
                      _buildSecureBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Built-in access is active. Custom keys are optional and saved securely on your device only.',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.slate600),
                        ),
                      ),
                    ],
                  ),
                ),

                // GOOGLE KEY
                const Text(
                  'Google AI Key (Primary)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.slate800),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _geminiApiKeyController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: _hasExistingGeminiKey ? '•••••••••••••••• (Saved on device - type to replace)' : 'Optional: Enter custom Google key...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: _hasExistingGeminiKey ? AppTheme.slate600 : AppTheme.slate400,
                      fontWeight: _hasExistingGeminiKey ? FontWeight.w600 : FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: AppTheme.slate50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppTheme.slate400),
                    suffixIcon: _hasExistingGeminiKey
                        ? IconButton(
                            tooltip: 'Clear stored key',
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.slate400),
                            onPressed: _clearGeminiKey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _testingGeminiKey ? null : _testGeminiConnection,
                      icon: _testingGeminiKey
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.wifi_protected_setup_rounded, size: 16),
                      label: Text(_testingGeminiKey ? 'Checking...' : 'Test Connection', style: const TextStyle(fontSize: 12)),
                    ),
                    const Text('Free key: aistudio.google.com', style: TextStyle(fontSize: 11, color: AppTheme.slate400)),
                  ],
                ),
                if (_geminiTestResult != null) ...[
                  _buildResultBox(_geminiTestResult!, _geminiTestSuccess),
                ],

                const SizedBox(height: 14),

                // MISTRAL KEY
                const Text(
                  'Mistral AI Key (Backup)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.slate800),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _mistralApiKeyController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: _hasExistingMistralKey ? '•••••••••••••••• (Saved on device - type to replace)' : 'Optional: Enter custom Mistral key...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: _hasExistingMistralKey ? AppTheme.slate600 : AppTheme.slate400,
                      fontWeight: _hasExistingMistralKey ? FontWeight.w600 : FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: AppTheme.slate50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.slate200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: AppTheme.slate400),
                    suffixIcon: _hasExistingMistralKey
                        ? IconButton(
                            tooltip: 'Clear stored key',
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.slate400),
                            onPressed: _clearMistralKey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _testingMistralKey ? null : _testMistralConnection,
                      icon: _testingMistralKey
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.wifi_protected_setup_rounded, size: 16),
                      label: Text(_testingMistralKey ? 'Checking...' : 'Test Connection', style: const TextStyle(fontSize: 12)),
                    ),
                    const Text('Free key: console.mistral.ai', style: TextStyle(fontSize: 11, color: AppTheme.slate400)),
                  ],
                ),
                if (_mistralTestResult != null) ...[
                  _buildResultBox(_mistralTestResult!, _mistralTestSuccess),
                ],

                const SizedBox(height: 22),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: AppTheme.slate700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Save & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildSecureBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentEmerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 10, color: AppTheme.accentEmerald),
          SizedBox(width: 4),
          Text(
            'SECURELY STORED',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.accentEmerald),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(String text, bool success) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: success ? AppTheme.accentEmerald.withValues(alpha: 0.1) : AppTheme.accentCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: success ? AppTheme.accentEmerald : AppTheme.accentCoral,
        ),
      ),
    );
  }

  Widget _buildEngineRadio({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required String badge,
    Color? badgeColor,
  }) {
    final isSelected = _engineMode == value;
    final effectiveBadgeColor = badgeColor ?? (isSelected ? AppTheme.primaryTeal : AppTheme.slate600);

    return InkWell(
      onTap: () => setState(() => _engineMode = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.05) : AppTheme.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.slate200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.slate400,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 10, top: 1),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : AppTheme.slate200.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.slate600,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.primaryTeal : AppTheme.slate900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: effectiveBadgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: effectiveBadgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.slate600, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
