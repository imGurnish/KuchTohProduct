import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../data/whisper_service.dart';
import '../widgets/recording_button.dart';
import '../widgets/transcription_display.dart';

/// Page for testing on-device Whisper speech-to-text
class WhisperTestPage extends StatefulWidget {
  const WhisperTestPage({super.key});

  @override
  State<WhisperTestPage> createState() => _WhisperTestPageState();
}

class _WhisperTestPageState extends State<WhisperTestPage> {
  final WhisperService _whisperService = WhisperService();
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<WhisperStatus>? _statusSubscription;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  String _transcriptionText = '';
  Duration? _lastProcessingTime;
  WhisperStatus _whisperStatus = WhisperStatus.idle;

  // Settings
  WhisperModelType _selectedModel = WhisperModelType.tiny;
  String _selectedLanguage = 'en';

  // Available languages
  static const Map<String, String> _languages = {
    'auto': 'Auto-detect',
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ru': 'Russian',
    'ar': 'Arabic',
  };

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _whisperService.setModel(_selectedModel);
    _whisperService.setLanguage(_selectedLanguage);

    // Listen to whisper status changes
    _statusSubscription = _whisperService.statusStream.listen((status) {
      setState(() {
        _whisperStatus = status;
        _isProcessing =
            status == WhisperStatus.transcribing ||
            status == WhisperStatus.downloadingModel ||
            status == WhisperStatus.initializingModel;
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _whisperService.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status.isGranted;
    });

    if (!status.isGranted) {
      _showError('Microphone permission is required for speech recognition');
    }
  }

  Future<void> _initializeModel() async {
    try {
      await _whisperService.initialize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedModel.name.toUpperCase()} model ready!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to initialize model: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check if we can record
      if (!await _recorder.hasPermission()) {
        _showError('Microphone permission denied');
        return;
      }

      // Get temp directory for recording
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/whisper_recording_$timestamp.wav';

      // Start recording in WAV format (required by Whisper)
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000, // Whisper prefers 16kHz
          numChannels: 1, // Mono
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        await _transcribeAudio(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    try {
      final result = await _whisperService.transcribe(audioPath);

      if (result != null && result.text.isNotEmpty) {
        setState(() {
          if (_transcriptionText.isNotEmpty) {
            _transcriptionText += ' ${result.text}';
          } else {
            _transcriptionText = result.text;
          }
          _lastProcessingTime = result.processingTime;
        });
      }
    } catch (e) {
      _showError('Transcription failed: $e');
    } finally {
      // Clean up the audio file
      try {
        await File(audioPath).delete();
      } catch (_) {}
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearTranscription() {
    setState(() {
      _transcriptionText = '';
      _lastProcessingTime = null;
    });
  }

  void _onModelChanged(WhisperModelType? model) {
    if (model != null) {
      setState(() {
        _selectedModel = model;
      });
      _whisperService.setModel(model);
    }
  }

  void _onLanguageChanged(String? lang) {
    if (lang != null) {
      setState(() {
        _selectedLanguage = lang;
      });
      _whisperService.setLanguage(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper Test'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Settings row
              _buildSettingsRow(theme, colorScheme),
              const SizedBox(height: 16),

              // Model status / Initialize button
              _buildModelStatus(theme, colorScheme),
              const SizedBox(height: 16),

              // Status indicator
              _buildStatusIndicator(theme, colorScheme),
              const SizedBox(height: 16),

              // Transcription display
              Expanded(
                child: TranscriptionDisplay(
                  text: _transcriptionText,
                  isProcessing: _isProcessing,
                  lastProcessingTime: _lastProcessingTime,
                  onClear: _clearTranscription,
                ),
              ),
              const SizedBox(height: 24),

              // Recording button
              Center(
                child: RecordingButton(
                  isRecording: _isRecording,
                  isProcessing: _isProcessing,
                  onPressed: _toggleRecording,
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                _isRecording
                    ? 'Recording... Tap to stop'
                    : 'Tap to start recording',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelStatus(ThemeData theme, ColorScheme colorScheme) {
    final isModelReady = _whisperService.isReady;
    final isDownloading = _whisperStatus == WhisperStatus.downloadingModel;
    final isInitializing = _whisperStatus == WhisperStatus.initializingModel;
    final isLoading = isDownloading || isInitializing;

    if (isModelReady) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 18, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              '${_selectedModel.name.toUpperCase()} model ready',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _initializeModel,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.download_rounded),
        label: Text(
          isDownloading
              ? 'Downloading ${_selectedModel.name.toUpperCase()} model...'
              : isInitializing
              ? 'Initializing model...'
              : 'Download ${_selectedModel.name.toUpperCase()} Model',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Model selector
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WhisperModelType>(
                    value: _selectedModel,
                    isExpanded: true,
                    items: WhisperModelType.values.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(
                          model.name.toUpperCase(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: _isRecording || _isProcessing
                        ? null
                        : _onModelChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Language selector
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: _isRecording || _isProcessing
                        ? null
                        : _onLanguageChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, ColorScheme colorScheme) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_whisperStatus == WhisperStatus.downloadingModel) {
      statusText = 'Downloading model...';
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.cloud_download_rounded;
    } else if (_whisperStatus == WhisperStatus.initializingModel) {
      statusText = 'Initializing model...';
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.memory_rounded;
    } else if (_whisperStatus == WhisperStatus.transcribing) {
      statusText = 'Transcribing audio...';
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.hourglass_top_rounded;
    } else if (_isRecording) {
      statusText = 'Recording...';
      statusColor = colorScheme.error;
      statusIcon = Icons.fiber_manual_record_rounded;
    } else if (!_hasPermission) {
      statusText = 'Microphone permission required';
      statusColor = colorScheme.error;
      statusIcon = Icons.mic_off_rounded;
    } else if (!_whisperService.isReady) {
      statusText = 'Download model to start';
      statusColor = colorScheme.outline;
      statusIcon = Icons.download_rounded;
    } else {
      statusText = 'Ready to record';
      statusColor = colorScheme.primary;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded),
            SizedBox(width: 8),
            Text('About Whisper'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This feature uses OpenAI\'s Whisper model running '
                'entirely on your device for speech-to-text transcription.',
              ),
              SizedBox(height: 16),
              Text('Models:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Tiny (~75MB): Fastest, good for quick tests'),
              Text('• Base (~150MB): Balanced speed/accuracy'),
              Text('• Small (~500MB): Best accuracy, slower'),
              SizedBox(height: 16),
              Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Select a model and tap "Download"'),
              Text('2. Wait for model to download & initialize'),
              Text('3. Tap the mic button to record'),
              Text('4. Tap again to stop and see transcription'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Release mode is 5x faster than debug'),
              Text('• Speak clearly for best results'),
              Text('• Short recordings process faster'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
