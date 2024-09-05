import 'dart:math';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _hasSpeech = false;
  bool _logEvents = false;
  double _level = 0.0;
  double _minSoundLevel = 50000;
  double _maxSoundLevel = -50000;
  String _lastWords = '';
  String _lastError = '';
  String _lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];

  Future<bool> initialize({bool debugLogging = false}) async {
    _logEvent('Initialize');
    _hasSpeech = await _speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
      debugLogging: debugLogging,
      finalTimeout: Duration(milliseconds: 0),
    );
    if (_hasSpeech) {
      _localeNames = await _speech.locales();
      var systemLocale = await _speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }
    return _hasSpeech;
  }

  void startListening() {
    _logEvent('start listening');
    _lastWords = '';
    _lastError = '';
    _speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  void stopListening() {
    _speech.stop();
  }

  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
      'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}',
    );
    _lastWords = result.recognizedWords;
  }

  void soundLevelListener(double level) {
    _minSoundLevel = min(_minSoundLevel, level);
    _maxSoundLevel = max(_maxSoundLevel, level);
    _level = level;
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
      'Received error status: ${error.errorMsg} - Permanent: ${error.permanent}',
    );
    _lastError = '${error.errorMsg} - ${error.permanent}';
  }

  void statusListener(String status) {
    _logEvent('Received listener status: $status');
    _lastStatus = status;
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  // Getters for accessing the results and status
  String get lastWords => _lastWords;
  String get lastError => _lastError;
  String get lastStatus => _lastStatus;
  double get level => _level;
  bool get hasSpeech => _hasSpeech;
  String get currentLocaleId => _currentLocaleId;
  List<LocaleName> get localeNames => _localeNames;

  set logEvents(bool value) {
    _logEvents = value;
  }
}
