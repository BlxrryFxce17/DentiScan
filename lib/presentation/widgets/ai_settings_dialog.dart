import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/hive_storage_service.dart';
import '../../services/gemini_vision_service.dart';

class AiSettingsDialog extends StatefulWidget {
  const AiSettingsDialog({super.key});

  @override
  State<AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends State<AiSettingsDialog> {
  late TextEditingController _apiKeyController;
  late String _engineMode;
  bool _testingKey = false;
  String? _testResult;
  bool _testSuccess = false;
  bool _hasExistingKey = false;

  @override
  void initState() {
    super.initState();
    _hasExistingKey = HiveStorageService.hasGeminiApiKey();
    // Keep input empty so raw key is never visible on screen
    _apiKeyController = TextEditingController();
    _engineMode = HiveStorageService.getOcrEngineMode();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final keyToTest = _apiKeyController.text.trim().isNotEmpty
        ? _apiKeyController.text.trim()
        : HiveStorageService.getGeminiApiKey();

    if (keyToTest.isEmpty) {
      setState(() {
        _testResult = 'No API key configured. Enter a key first.';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _testingKey = true;
      _testResult = null;
    });

    final success = await GeminiVisionService.testApiKey(keyToTest);

    if (mounted) {
      setState(() {
        _testingKey = false;
        _testSuccess = success;
        _testResult = success
            ? '✓ Connected! Gemini Vision AI is ready.'
            : '✗ Key validation failed. Please check the key.';
      });
    }
  }

  Future<void> _saveSettings() async {
    final newKey = _apiKeyController.text.trim();
    if (newKey.isNotEmpty) {
      await HiveStorageService.saveGeminiApiKey(newKey);
    }
    await HiveStorageService.saveOcrEngineMode(_engineMode);
    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI OCR settings updated securely.'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
    }
  }

  Future<void> _clearKey() async {
    await HiveStorageService.saveGeminiApiKey('');
    setState(() {
      _hasExistingKey = false;
      _apiKeyController.clear();
      _testResult = 'Key cleared.';
      _testSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
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
                    child: const Icon(Icons.psychology_rounded, color: AppTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Scanning & OCR Engines',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                        ),
                        Text(
                          'Configure multimodal & on-device engines',
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
                'PRIMARY SCANNING ENGINE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              _buildEngineRadio(
                title: 'Auto (Recommended)',
                subtitle: 'Uses Gemini Vision for handwriting; falls back to on-device ML Kit if offline.',
                value: 'auto',
                icon: Icons.auto_awesome_rounded,
                badge: 'SMART',
              ),
              const SizedBox(height: 8),
              _buildEngineRadio(
                title: 'Google Gemini Vision AI',
                subtitle: 'Multimodal cloud AI for deciphering complex doctor handwriting & clinical abbreviations.',
                value: 'gemini',
                icon: Icons.cloud_done_rounded,
                badge: 'CLOUD',
              ),
              const SizedBox(height: 8),
              _buildEngineRadio(
                title: 'Google ML Kit (On-Device)',
                subtitle: '100% offline, zero internet needed. Fast text detection directly on your phone.',
                value: 'mlkit',
                icon: Icons.phonelink_setup_rounded,
                badge: 'OFFLINE',
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GEMINI VISION API KEY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 0.5),
                  ),
                  if (_hasExistingKey)
                    Container(
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
                    ),
                ],
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _apiKeyController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: _hasExistingKey ? '•••••••••••••••• (Type to replace)' : 'Paste Gemini API Key here...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: _hasExistingKey ? AppTheme.slate600 : AppTheme.slate400,
                    fontWeight: _hasExistingKey ? FontWeight.w600 : FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: AppTheme.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.key_rounded, size: 18, color: AppTheme.slate400),
                  suffixIcon: _hasExistingKey
                      ? IconButton(
                          tooltip: 'Clear stored key',
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.slate400),
                          onPressed: _clearKey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _testingKey ? null : _testConnection,
                    icon: _testingKey
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.speed_rounded, size: 16),
                    label: Text(_testingKey ? 'Testing...' : 'Test Connection', style: const TextStyle(fontSize: 12)),
                  ),
                  const Text(
                    'Free tier at aistudio.google.com',
                    style: TextStyle(fontSize: 11, color: AppTheme.slate400),
                  ),
                ],
              ),

              if (_testResult != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _testSuccess ? AppTheme.accentEmerald.withValues(alpha: 0.1) : AppTheme.accentCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _testResult!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _testSuccess ? AppTheme.accentEmerald : AppTheme.accentCoral,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

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
    );
  }

  Widget _buildEngineRadio({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required String badge,
  }) {
    final isSelected = _engineMode == value;

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
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.slate400,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : AppTheme.slate200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppTheme.primaryTeal : AppTheme.slate600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.slate600, height: 1.3),
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
