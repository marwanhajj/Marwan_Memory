import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SpeechProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;
  
  SpeechProvider() {
    _initSpeech();
    _initTts();
  }
  
  // Initialize speech recognition
  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          _isListening = false;
          notifyListeners();
        },
      );
      
      if (!available) {
        // Handle unavailable speech recognition
        debugPrint('Speech recognition not available');
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
    }
  }
  
  // Initialize text-to-speech
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('ar-SA');
      await _flutterTts.setSpeechRate(0.9);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }
  
  // Start listening for speech
  Future<void> startListening() async {
    _lastWords = '';
    
    if (!_speech.isAvailable) {
      await _initSpeech();
    }
    
    try {
      if (await _speech.initialize()) {
        _isListening = true;
        notifyListeners();
        
        await _speech.listen(
          onResult: (result) {
            _lastWords = result.recognizedWords;
            
            if (result.finalResult && _lastWords.isNotEmpty) {
              _isListening = false;
              notifyListeners();
              
              // Send the recognized speech to chat
              ChatProvider chatProvider = ChatProvider();
              chatProvider.sendMessage(_lastWords, isVoiceMessage: true);
            }
          },
          localeId: 'ar_SA',
        );
      }
    } catch (e) {
      _isListening = false;
      notifyListeners();
      debugPrint('Error listening: $e');
    }
  }
  
  // Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }
  
  // Speak text
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }
    
    try {
      _isSpeaking = true;
      notifyListeners();
      
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
      debugPrint('Error speaking: $e');
    }
  }
  
  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }
  
  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
