import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MistralVisionService {
  static const String endpoint = 'https://api.mistral.ai/v1/chat/completions';
  static const String defaultModel = 'pixtral-12b-2409';

  /// Sends the document image bytes to Mistral Pixtral Vision API to transcribe and structure dental records
  static Future<String> extractClinicalText({
    required Uint8List imageBytes,
    required String apiKey,
    String? customModel,
  }) async {
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are an expert clinical dental intelligence and transcription specialist. Analyze this dental document (handwritten prescription, clinical chart, examination note, or dental bill).
Even if the doctor's handwriting is cursive or abbreviated, accurately transcribe, decode, and clinically interpret all details.

CRITICAL CLINICAL INTELLIGENCE RULES:
1. DENTAL TOOTH NOTATION & MULTI-TOOTH QUADRANTS:
   - Palmer Notation:
     - Upper Left ( _| or UL ): 1 to 8 -> FDI teeth 21 to 28 (e.g. _|4 = Tooth 24, _|5 = Tooth 25, _|6 = Tooth 26)
     - Upper Right ( |_ or UR ): 1 to 8 -> FDI teeth 11 to 18 (e.g. 4|_ = Tooth 14, 5|_ = Tooth 15, 6|_ = Tooth 16)
     - Lower Left ( ^| or LL ): 1 to 8 -> FDI teeth 31 to 38 (e.g. ^|4 = Tooth 34, ^|5 = Tooth 35, ^|6 = Tooth 36)
     - Lower Right ( |^ or LR ): 1 to 8 -> FDI teeth 41 to 48 (e.g. 4|^ = Tooth 44, 5|^ = Tooth 45, 6|^ = Tooth 46)
   - MULTI-TOOTH GROUPINGS:
     - Dentists frequently group adjacent teeth in a single quadrant symbol!
     - e.g. "Pocket _|4 5" or "_|4,5" or "_|4 5 IOPA taken" means BOTH Tooth #24 (UL4) and Tooth #25 (UL5)!
     - e.g. "4 5|_" means Tooth #14 and Tooth #15!
     - e.g. "^|6 7" means Tooth #36 and Tooth #37!
     - Always split grouped teeth into individual FDI entries: Tooth #24, Tooth #25, etc.
   - ALWAYS output tooth numbers in standard two-digit FDI format: Tooth #24, Tooth #46, etc.

2. ABSOLUTE BAN ON META-DISCLAIMERS & APOLOGETIC TEXT:
   - NEVER output meta-commentary, apologies, or parenthetical disclaimers such as "(Specific tooth number not specified in the document)", "(Tooth not specified)", "(Unknown tooth)", or "(Not recorded)".
   - If a condition is localized, identify the tooth or quadrant.
   - If a condition or infection is generalized across the mouth or unlocalized (e.g. general dental abscess, severe toothache, gingivitis), write definitive professional clinical terms like "Acute Odontogenic / Periodontal Abscess" or "Generalized Dental Abscess" — NEVER output apologetic disclaimers.

3. CLINICAL REASONING FOR TREATMENT PLAN:
   - For every finding, diagnosis, or symptom (e.g. "Pocket _|4 5", "Adv. -> IOPA", "Tooth abscess", "carious exposure"), generate definitive procedures under Treatment Plan / Procedures:
     Tooth #24: Periodontal Debridement / Deep Pocket Scaling - Status: Planned
     Tooth #25: Periodontal Debridement / Deep Pocket Scaling - Status: Planned
     Tooth #24: Intraoral Periapical Radiograph (IOPA) Evaluation - Status: Completed
     Tooth #25: Intraoral Periapical Radiograph (IOPA) Evaluation - Status: Completed
   - If medications (antibiotics, anti-inflammatory drugs) are prescribed for infection or abscess, ensure the therapeutic regimen is captured under Treatment Plan / Procedures:
     Tooth #24: Pharmacotherapeutic Anti-Infective Regimen - Status: Active
   - If truly generalized with no individual tooth specified, formulate:
     Generalized: Periodontal Debridement & Anti-Infective Therapy - Status: Active
     Generalized: Diagnostic Radiographic Evaluation (IOPA / OPG) - Status: Advised

4. CURSIVE HANDWRITING & PRESCRIPTION SYMBOLS:
   - "Adv. ----> IOPA" = Advised Intraoral Periapical Radiograph.
   - "= (10)" or "= (12)" = Total quantity of tablets dispensed/prescribed.
   - Curly brackets grouping medications = Shared instructions, e.g. "} after food".
   - "H/S mouthwash" = Hot / Warm saline mouth rinses.
   - Common dental drugs: Zostum-O, Megaflexon, Dox-L / Doxycycline, Acemiz-S / Aceclofenac, Rexidine M Forte Gel (LCA - Local Application), Augmentin, Amoxicillin, Metrogyl, Zerodol-SP, Ketorol-DT, Pan-D.

5. ATTENDING DOCTOR:
   - On letterheads with multiple consultants, check the signature or stamp at the bottom to identify who attended and signed the record.

6. BILLING INVOICES & ITEMIZED TREATMENTS:
   - For dental bills, invoices, or receipts, extract every billed procedure under "Treatment Plan / Procedures:" with its ACTUAL billed monetary amount, for example:
     Consultation - Cost: ₹500.00
     Scaling & Polishing - Cost: ₹2,500.00
     Laser assisted RCT - Cost: ₹7,000.00
   - Also check the top right or bottom corner for written consultation charges e.g. "300/-".
   - NEVER confuse list item numbers (1., 2., 3., etc.) or quantities (Qty: 1) with the price rate!

Standard Output Format:
Clinic: [Clinic Name and address]
Doctor: [Attending Doctor Name, Degree e.g. BDS/MDS, Specialty]
Patient Name: [Full Name]
Age: [Age in years]
Gender: [Male/Female/Other]
Date: [YYYY-MM-DD or as written]
Phone: [Contact number if any]
Address: [Patient address if any]

Vitals: [e.g. Temp, BP, SpO2 if recorded]
Diagnostics: [e.g. IOPA taken for Tooth #24, #25]

Chief Complaint: [Symptoms, complaint, or primary concern]
Medical History: [Systemic conditions e.g. Hypertension, Diabetes, NAD]
Dental History: [Past restorations, extractions, NAD]
Allergies: [Drug allergies or NKDA]
Habits: [Smoking, tobacco, bruxism if mentioned]

Clinical Findings:
Tooth #[FDI number]: [Findings e.g. Deep periodontal pocket (4-5mm), IOPA taken]

Treatment Plan / Procedures:
Tooth #[FDI number]: [Procedure Name e.g. Periodontal Debridement, Endodontic Assessment / RCT, Composite Restoration] [Surface e.g. Distal, MOD, Occlusal, Full Tooth] - Status: [Planned / Completed / Active] - Cost: ₹[Amount if billed]

Rx / Medications:
1. [Drug name e.g. Tab. Dox-L-100, Tab. Acemiz-S] [Dosage e.g. 1 tablet BD] [Duration e.g. x 3 days] ([Instructions e.g. After food])
2. [Mouthwash or topical gel e.g. Rexidine M Forte Gel - Local application (LCA)]

Advice / Instructions: [Post-op care, warm saline rinses, maintain oral hygiene]
Next Appointment: [Follow up / recall date or timeframe]

Financial Summary:
Total Cost: ₹[Amount]
Advance Paid: ₹[Amount]
Balance Due: ₹[Amount]

Notes / Instructions: [Receipt/Invoice numbers, registration, signatures]

Important: For fields with no information, write "None" or omit the line. Do NOT output bracketed placeholders like "[Not recorded]".
''';

    final model = customModel ?? defaultModel;
    final url = Uri.parse(endpoint);

    final requestBody = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_tokens': 2048,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: requestBody,
    ).timeout(
      const Duration(seconds: 40),
      onTimeout: () => throw Exception('Mistral AI connection timed out after 40 seconds.'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final choices = json['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices.first['message'];
        if (message != null && message['content'] != null) {
          final content = message['content'] as String;
          if (content.trim().isNotEmpty) {
            return content;
          }
        }
      }
      throw Exception('Mistral returned an empty response.');
    } else {
      throw Exception('Mistral HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Verifies connectivity with Mistral API using the user's API key
  static Future<bool> testApiKey(String apiKey) async {
    try {
      final url = Uri.parse(endpoint);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': defaultModel,
          'messages': [
            {'role': 'user', 'content': 'Ping. Reply OK.'}
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 12));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Mistral key test error: $e');
      return false;
    }
  }
}
