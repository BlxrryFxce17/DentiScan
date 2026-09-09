import 'package:flutter/foundation.dart';
import '../models/patient_record.dart';
import '../core/utils/image_processor.dart';
import 'clinical_parser.dart';
import 'ml_kit_ocr_service.dart';
import 'gemini_vision_service.dart';
import 'mistral_vision_service.dart';
import 'clinical_consensus_engine.dart';
import 'hive_storage_service.dart';

class OcrProgressUpdate {
  final double progress; // 0.0 to 1.0
  final String statusMessage;

  OcrProgressUpdate(this.progress, this.statusMessage);
}

class OcrEngine {
  /// Processes a dental document image with real-time progress callbacks and dual-engine fallback
  static Future<PatientRecord> processDentalDocument({
    required Uint8List imageBytes,
    String? filePath,
    Function(OcrProgressUpdate)? onProgress,
  }) async {
    // Step 1: Document boundary analysis & deskew
    onProgress?.call(OcrProgressUpdate(0.15, 'Preparing image...'));
    await Future.delayed(const Duration(milliseconds: 200));

    final preprocessed = await ImageProcessor.preprocessDocument(imageBytes);

    // Step 2: Determine engine mode & execute OCR
    final engineMode = HiveStorageService.getOcrEngineMode(); // 'auto', 'consensus', 'gemini', 'mistral', 'mlkit'
    final geminiKey = HiveStorageService.getGeminiApiKey();
    final mistralKey = HiveStorageService.getMistralApiKey();

    String extractedText = '';
    double confidence = 0.95;

    // Check if this is a built-in pre-loaded sample image
    final sampleText = _checkSampleMatch(preprocessed.bytes, filePath);
    if (sampleText != null) {
      onProgress?.call(OcrProgressUpdate(0.60, 'Loading sample...'));
      extractedText = sampleText;
    } else {
      String? lastFailureReason;

      // 1. DUAL-AI DEBATE & CONSENSUS MODE (Runs Gemini & Mistral in Parallel)
      if (engineMode == 'consensus' && (geminiKey.isNotEmpty || mistralKey.isNotEmpty)) {
        onProgress?.call(OcrProgressUpdate(0.35, 'Debating document with Gemini & Mistral in parallel...'));

        final futures = <Future<String?>>[];
        if (geminiKey.isNotEmpty) {
          futures.add(
            GeminiVisionService.extractClinicalText(imageBytes: preprocessed.bytes, apiKey: geminiKey)
                .then<String?>((t) => t)
                .catchError((e) {
              debugPrint('Consensus - Gemini error: $e');
              return null;
            }),
          );
        } else {
          futures.add(Future.value(null));
        }

        if (mistralKey.isNotEmpty) {
          futures.add(
            MistralVisionService.extractClinicalText(imageBytes: preprocessed.bytes, apiKey: mistralKey)
                .then<String?>((t) => t)
                .catchError((e) {
              debugPrint('Consensus - Mistral error: $e');
              return null;
            }),
          );
        } else {
          futures.add(Future.value(null));
        }

        final results = await Future.wait(futures);
        final geminiText = results[0];
        final mistralText = results[1];

        // If BOTH models succeeded, debate and reconcile them!
        if (geminiText != null && geminiText.trim().isNotEmpty && mistralText != null && mistralText.trim().isNotEmpty) {
          onProgress?.call(OcrProgressUpdate(0.70, 'Reconciling clinical debate & cross-verifying findings...'));
          await Future.delayed(const Duration(milliseconds: 150));

          final recGemini = ClinicalParser.parseTextToRecord(
            rawText: geminiText,
            imagePath: filePath,
            ocrConfidence: 0.98,
          );
          final recMistral = ClinicalParser.parseTextToRecord(
            rawText: mistralText,
            imagePath: filePath,
            ocrConfidence: 0.98,
          );

          final consensusReport = ClinicalConsensusEngine.reconcile(
            geminiRecord: recGemini,
            mistralRecord: recMistral,
          );

          onProgress?.call(OcrProgressUpdate(1.0, 'Opening verified consensus record...'));
          return consensusReport.record;
        } else if (geminiText != null && geminiText.trim().isNotEmpty) {
          extractedText = geminiText;
          confidence = 0.98;
        } else if (mistralText != null && mistralText.trim().isNotEmpty) {
          extractedText = mistralText;
          confidence = 0.98;
        } else {
          lastFailureReason = 'Both Gemini and Mistral consensus requests failed.';
        }
      }

      // 2. Direct Mistral mode
      if (extractedText.trim().isEmpty && engineMode == 'mistral' && mistralKey.isNotEmpty) {
        try {
          onProgress?.call(OcrProgressUpdate(0.40, 'Processing with Mistral Pixtral...'));
          extractedText = await MistralVisionService.extractClinicalText(
            imageBytes: preprocessed.bytes,
            apiKey: mistralKey,
          );
          confidence = 0.98;
          onProgress?.call(OcrProgressUpdate(0.75, 'Categorizing clinical data...'));
        } catch (mistralError) {
          debugPrint('Mistral Vision error: $mistralError');
          lastFailureReason = mistralError.toString();
          extractedText = '';
        }
      }

      // 3. Gemini mode or Auto mode (Gemini first)
      if (extractedText.trim().isEmpty && (engineMode == 'auto' || engineMode == 'gemini') && geminiKey.isNotEmpty) {
        try {
          onProgress?.call(OcrProgressUpdate(0.40, 'Processing with Gemini Vision...'));
          extractedText = await GeminiVisionService.extractClinicalText(
            imageBytes: preprocessed.bytes,
            apiKey: geminiKey,
          );
          confidence = 0.98;
          onProgress?.call(OcrProgressUpdate(0.75, 'Categorizing clinical data...'));
        } catch (geminiError) {
          debugPrint('Gemini Vision error: $geminiError');
          lastFailureReason = geminiError.toString();
          extractedText = '';
        }
      }

      // 4. Auto fallback to Mistral Pixtral if Gemini encountered an issue or rate limit
      if (extractedText.trim().isEmpty && engineMode == 'auto' && mistralKey.isNotEmpty) {
        try {
          onProgress?.call(OcrProgressUpdate(0.55, 'Switching to Mistral Pixtral fallback...'));
          extractedText = await MistralVisionService.extractClinicalText(
            imageBytes: preprocessed.bytes,
            apiKey: mistralKey,
          );
          confidence = 0.98;
          onProgress?.call(OcrProgressUpdate(0.75, 'Categorizing clinical data...'));
        } catch (mistralError) {
          debugPrint('Mistral Fallback error: $mistralError');
          lastFailureReason = 'Gemini: $lastFailureReason | Mistral: $mistralError';
          extractedText = '';
        }
      }

      // 5. On-device Google ML Kit (on mobile/desktop native platforms)
      if (extractedText.trim().isEmpty && !kIsWeb) {
        try {
          onProgress?.call(OcrProgressUpdate(0.65, 'Reading text with on-device ML Kit...'));
          extractedText = await MlKitOcrService.extractText(
            imageBytes: preprocessed.bytes,
            filePath: filePath,
          );
          confidence = 0.92;
        } catch (mlKitError) {
          debugPrint('ML Kit OCR error: $mlKitError');
        }
      }

      // If text is still completely blank
      if (extractedText.trim().isEmpty) {
        if (kIsWeb && geminiKey.isEmpty && mistralKey.isEmpty) {
          throw Exception(
            'On Web, an API key is required to scan custom uploaded files. '
            'Please tap the Settings icon to enter your Gemini or Mistral key.',
          );
        } else if (lastFailureReason != null) {
          if (lastFailureReason.contains('503')) {
            throw Exception('AI Cloud Service is temporarily experiencing high demand (HTTP 503). Please tap "Rescan" in a few moments.');
          } else if (lastFailureReason.contains('429')) {
            throw Exception('AI Cloud quota rate limit reached (HTTP 429). Please wait a moment or check your AI Settings.');
          } else {
            throw Exception('AI scanning failed: $lastFailureReason');
          }
        } else {
          throw Exception('No readable text could be found. Please ensure the photo is clear and in focus.');
        }
      }
    }

    // Step 3: Clinical Semantic Categorization
    onProgress?.call(OcrProgressUpdate(0.85, 'Reading details...'));
    await Future.delayed(const Duration(milliseconds: 200));

    final record = ClinicalParser.parseTextToRecord(
      rawText: extractedText,
      imagePath: filePath,
      ocrConfidence: confidence,
    );

    onProgress?.call(OcrProgressUpdate(1.0, 'Opening record...'));
    return record;
  }

  static String? _checkSampleMatch(Uint8List bytes, String? path) {
    if (path == null) return null;
    final p = path.toLowerCase();
    if (p.contains('sample_1_handwritten_rx') || p.endsWith('sample_1.jpg')) {
      return _sample1Text;
    } else if (p.contains('sample_2_printed_chart') || p.endsWith('sample_2.jpg')) {
      return _sample2Text;
    } else if (p.contains('sample_3_skewed_record') || p.endsWith('sample_3.jpg')) {
      return _sample3Text;
    }
    return null;
  }

  static const String _sample1Text = '''
SmileCraft Dental Clinic
123 Oral Health Ave, Dental City
Patient Name: David Miller
Age: 38    Gender: Male    Date: Sept 08 2026
Doctor: Dr. Arthur Pendelton
Qualification: MDS Endodontics    Reg #: DEN-88219

Chief Complaint: Severe throbbing pain in lower right molar tooth #46, aggravated by cold and chewing for 4 days.
Medical History: Well-controlled hypertension on Amlodipine 5mg.
Dental History: Previous silver amalgam filling on #36.
Allergies: Penicillin allergy, non-smoker.
Clinical Findings: Deep occlusal caries on tooth #46, tender to percussion.
Treatment Plan: Endodontic Root Canal Therapy (RCT) on #46 followed by Zirconia Crown.

Rx:
1. Cefuroxime 500mg BD x 5 days
2. Ibuprofen 400mg TDS

Estimated Cost: ₹650
Advance Paid: ₹200
Balance: ₹450
Dr. Arthur Pendelton (Reg #DEN-88219)
''';

  static const String _sample2Text = '''
Apex Dental Specialties & Implantology
Phone: (555) 342-9910
DENTAL EXAMINATION & TREATMENT PLAN

Doctor: Dr. Evelyn Reed, DDS (License #10943)
Patient: Sophia Martinez    Age: 29    Gender: Female    DOB: 11/14/1996
Date: 2026-09-07    Phone: (555) 342-9910

Chief Complaint: Bleeding and inflamed gums around upper left canine (#23)
Medical History: None reported, Diabetes Negative
Dental History: Orthodontic braces completed 4 years ago
Allergies / Habits: Latex allergy (significant), non-smoker

Procedures / Tooth Details:
Tooth #23 Subgingival scaling and curettage (D4342)
Tooth #14 Composite resin restoration (Class II DO, D2392)

Treatment Plan: Periodontal deep cleaning (full mouth), followed by restoration of #14 next appointment.

Financial Summary:
Total Cost: ₹480.00
Insurance Covered: ₹200.00 (Star Health Dental)
Patient Copay Paid: ₹150.00 (UPI / GPay, 9/7/26)
Balance Due: ₹130.00

Notes: Patient educated on gum health and home care; follow-up 2 weeks
Signature: Dr. Evelyn Reed, 09/07/26
''';

  static const String _sample3Text = '''
Dr. Michael Chang, DDS - Family Dentistry
Patient: Liam Johnson, 45 M. Date: 09/05/2026

Chief complaint: Broken tooth upper front central incisor #11 after sports trauma.
Dental history: Good oral hygiene.
Allergies: NKDA (No Known Drug Allergies).

Treatment: Composite bonding and build-up on tooth #11, shade A2.

Estimated cost: ₹280
Paid: ₹280
Balance: ₹0.
''';
}
