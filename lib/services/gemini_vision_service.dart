import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiVisionService {
  static const String _defaultModel = 'gemini-1.5-flash';

  /// Sends the document image bytes to Google Gemini Vision API to decipher handwriting and structure medical data
  static Future<String> extractClinicalText({
    required Uint8List imageBytes,
    required String apiKey,
    String? customModel,
  }) async {
    final model = customModel ?? _defaultModel;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are an expert clinical dental transcription assistant. Analyze this dental document (prescription, chart, examination note, or bill).
Even if the doctor's handwriting is messy or in cursive, carefully transcribe and decipher all text, dental abbreviations, and symbols.

Format your output clearly with the following standard clinical headers:
Clinic: [Clinic Name and address if visible]
Doctor: [Doctor Name, Degree e.g. BDS/MDS, Registration number]
Patient Name: [Full Name]
Age: [Age in years]
Gender: [Male/Female/Other]
Date: [YYYY-MM-DD or as written]
Phone: [Contact number if any]

Chief Complaint: [Symptoms and teeth affected]
Medical History: [Systemic conditions e.g. Hypertension, Diabetes, Pregnancy]
Dental History: [Past restorations, extractions, braces]
Allergies: [Drug allergies e.g. Penicillin, Latex, NSAIDs or NKDA]
Habits: [Smoking, tobacco, bruxism if mentioned]

Clinical Findings: [Exam findings e.g. deep caries, periapical abscess, calculus]

Treatment Plan / Procedures:
Tooth #[Tooth number FDI e.g. 46, 23, 11] [Procedure Name e.g. Root Canal Therapy, Composite Restoration, Scaling, Extraction] [Surface e.g. MOD, Occlusal, Cervical] - Cost: ₹[Amount in INR]

Rx / Medications:
1. [Drug name e.g. Amoxicillin, Ibuprofen] [Dosage e.g. 500mg] [Frequency e.g. 1-0-1, TDS] x [Duration e.g. 5 days]

Financial Summary:
Total Cost: ₹[Amount]
Advance Paid: ₹[Amount]
Insurance Covered: ₹[Amount]
Balance Due: ₹[Amount]

Notes / Instructions: [Post-op care, recall date, signature]

Transcribe strictly what is present or clinically deduced from the document. Do not hallucinate fictitious details.
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 2048,
      }
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return text;
          }
        }
      }
      throw Exception('Empty response from Gemini Vision API.');
    } else {
      final errorBody = response.body;
      throw Exception('Gemini API Error (HTTP ${response.statusCode}): $errorBody');
    }
  }

  /// Quick validation to verify if the API key is active
  static Future<bool> testApiKey(String apiKey) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$apiKey',
      );
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'ping'}
                  ]
                }
              ]
            }),
          )
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
