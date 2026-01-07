import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

/// Enum representing available OCR engines
enum OcrEngine { googleMlKit, tesseract }

/// Extension to get display names for OCR engines
extension OcrEngineExtension on OcrEngine {
  String get displayName {
    switch (this) {
      case OcrEngine.googleMlKit:
        return 'Google ML Kit';
      case OcrEngine.tesseract:
        return 'Tesseract OCR';
    }
  }
}

/// Abstract OCR service interface
abstract class OcrService {
  Future<String> extractText(String imagePath);
  void dispose();
}

/// Google ML Kit OCR implementation
class GoogleMlKitOcrService implements OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Google ML Kit OCR failed: $e');
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

/// Tesseract OCR implementation (Android/iOS only)
class TesseractOcrService implements OcrService {
  @override
  Future<String> extractText(String imagePath) async {
    // Tesseract only works on Android and iOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Tesseract OCR is only supported on Android and iOS. '
        'Please use Google ML Kit for desktop platforms.',
      );
    }

    try {
      final text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'eng',
      );
      return text;
    } catch (e) {
      throw Exception('Tesseract OCR failed: $e');
    }
  }

  @override
  void dispose() {
    // Tesseract doesn't require explicit disposal
  }
}

/// Factory class to create OCR services based on engine type
class OcrServiceFactory {
  static OcrService create(OcrEngine engine) {
    switch (engine) {
      case OcrEngine.googleMlKit:
        return GoogleMlKitOcrService();
      case OcrEngine.tesseract:
        return TesseractOcrService();
    }
  }

  /// Check if an engine is supported on the current platform
  static bool isSupported(OcrEngine engine) {
    switch (engine) {
      case OcrEngine.googleMlKit:
        // ML Kit works on Android and iOS
        return Platform.isAndroid || Platform.isIOS;
      case OcrEngine.tesseract:
        // Tesseract works on Android and iOS
        return Platform.isAndroid || Platform.isIOS;
    }
  }

  /// Get platform support message for an engine
  static String? getPlatformWarning(OcrEngine engine) {
    if (isSupported(engine)) return null;

    switch (engine) {
      case OcrEngine.googleMlKit:
        return 'Google ML Kit is only supported on Android and iOS';
      case OcrEngine.tesseract:
        return 'Tesseract OCR is only supported on Android and iOS';
    }
  }
}
