import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class MlKitOcrService {
  static TextRecognizer? _recognizer;

  static TextRecognizer get _instance {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  /// Extracts raw text from an image using Google ML Kit on-device neural model
  static Future<String> extractText({
    required Uint8List imageBytes,
    String? filePath,
  }) async {
    InputImage inputImage;
    File? tempFile;

    try {
      if (filePath != null && filePath.isNotEmpty && await File(filePath).exists()) {
        inputImage = InputImage.fromFilePath(filePath);
      } else {
        final tempDir = await getTemporaryDirectory();
        tempFile = File('${tempDir.path}/temp_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(imageBytes);
        inputImage = InputImage.fromFile(tempFile);
      }

      final RecognizedText recognizedText = await _instance.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('ML Kit OCR execution error: $e');
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Closes the native text recognizer engine when no longer needed
  static void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
