import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

/// Available Whisper models with their trade-offs
enum WhisperModelType {
  tiny('Tiny (~75MB) - Fastest, lower accuracy'),
  base('Base (~150MB) - Balanced'),
  small('Small (~500MB) - Best accuracy');

  final String description;
  const WhisperModelType(this.description);

  WhisperModel get model {
    switch (this) {
      case WhisperModelType.tiny:
        return WhisperModel.tiny;
      case WhisperModelType.base:
        return WhisperModel.base;
      case WhisperModelType.small:
        return WhisperModel.small;
    }
  }
}

/// Status of the Whisper transcription service
enum WhisperStatus {
  idle,
  downloadingModel,
  initializingModel,
  ready,
  transcribing,
  error,
}

/// Result of a transcription operation
class TranscriptionResult {
  final String text;
  final Duration processingTime;

  TranscriptionResult({required this.text, required this.processingTime});
}

/// Service that wraps WhisperController for speech-to-text transcription
class WhisperService {
  WhisperController? _controller;
  WhisperModelType _currentModel = WhisperModelType.tiny;
  String _language = 'en';
  WhisperStatus _status = WhisperStatus.idle;
  bool _modelInitialized = false;
  String? _modelPath;

  final _statusController = StreamController<WhisperStatus>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  /// Stream of status updates
  Stream<WhisperStatus> get statusStream => _statusController.stream;

  /// Stream of download progress (0.0 to 1.0)
  Stream<double> get progressStream => _progressController.stream;

  /// Current status
  WhisperStatus get status => _status;

  /// Current model
  WhisperModelType get currentModel => _currentModel;

  /// Current language
  String get language => _language;

  /// Whether the model is ready for transcription
  bool get isReady => _modelInitialized && _status == WhisperStatus.ready;

  void _updateStatus(WhisperStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  /// Set the Whisper model to use
  void setModel(WhisperModelType model) {
    if (_currentModel != model) {
      _currentModel = model;
      _modelInitialized = false;
      _modelPath = null;
      _updateStatus(WhisperStatus.idle);
    }
  }

  /// Set the language for transcription
  /// Use 'auto' for auto-detection, or language codes like 'en', 'hi', 'es', etc.
  void setLanguage(String lang) {
    _language = lang;
  }

  /// Initialize the Whisper controller and download model if needed
  Future<void> initialize() async {
    if (_modelInitialized && _controller != null) {
      _updateStatus(WhisperStatus.ready);
      return;
    }

    _controller ??= WhisperController();

    try {
      // Download the model (this will skip if already downloaded)
      _updateStatus(WhisperStatus.downloadingModel);

      _modelPath = await _controller!.downloadModel(_currentModel.model);
      debugPrint('WhisperService: Model path: $_modelPath');

      // Initialize the model
      _updateStatus(WhisperStatus.initializingModel);
      await _controller!.initModel(_currentModel.model);
      debugPrint('WhisperService: Model initialized');

      _modelInitialized = true;
      _updateStatus(WhisperStatus.ready);
    } catch (e) {
      debugPrint('WhisperService: Error initializing: $e');
      _updateStatus(WhisperStatus.error);
      rethrow;
    }
  }

  /// Transcribe audio from a WAV file path
  ///
  /// Returns the transcription result with text and processing time.
  /// The audio file must be in WAV format (16kHz mono recommended).
  Future<TranscriptionResult?> transcribe(String audioPath) async {
    // Make sure the model is initialized
    if (!_modelInitialized) {
      await initialize();
    }

    _updateStatus(WhisperStatus.transcribing);
    debugPrint('WhisperService: Starting transcription of: $audioPath');

    final stopwatch = Stopwatch()..start();

    try {
      final result = await _controller!.transcribe(
        model: _currentModel.model,
        audioPath: audioPath,
        lang: _language,
      );

      stopwatch.stop();
      debugPrint(
        'WhisperService: Transcription completed in ${stopwatch.elapsed}',
      );
      debugPrint('WhisperService: Result: ${result?.transcription.text}');

      final transcriptionResult = TranscriptionResult(
        text: result?.transcription.text ?? '',
        processingTime: stopwatch.elapsed,
      );

      _updateStatus(WhisperStatus.ready);
      return transcriptionResult;
    } catch (e) {
      stopwatch.stop();
      debugPrint('WhisperService: Transcription error: $e');
      _updateStatus(WhisperStatus.error);
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
    _progressController.close();
    _controller = null;
    _modelInitialized = false;
  }
}
