import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LitaAiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  GenerativeModel? _model;
  ChatSession? _chatSession;
  
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _currentLanguage = 'en';

  LitaAiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-3.5-flash', 
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'You are LITA (Live Intelligent Travel Assistant), a warm, Lovable, friendly, and helpful travel companion for someone exploring Sri Lanka. '
          'Keep your responses short, conversational, and natural — like a friend talking in the passenger seat. '
          'Do not use lists, markdown, or long paragraphs because your response will be spoken out loud via text-to-speech. '
          'The user might have just told you their name. If so, greet them by their name, ask them where they are going today, and start a sweet conversation. '
          'If the user provides their speed or location, incorporate that into your sweet conversation naturally.'
        )
      );
      _chatSession = _model?.startChat();
    }
    _initSpeech();
    _updateLanguageAndTts();
  }
  
  Future<void> _updateLanguageAndTts() async {
    final prefs = await SharedPreferences.getInstance();
    final newLang = prefs.getString('language') ?? 'en';
    if (_currentLanguage != newLang || true) {
      _currentLanguage = newLang;
      await _initTts(newLang);
    }
  }
  
  String _getTtsLocale(String langCode) {
    switch (langCode) {
      case 'si': return 'si-LK';
      case 'ta': return 'ta-IN';
      case 'hi': return 'hi-IN';
      case 'fr': return 'fr-FR';
      case 'de': return 'de-DE';
      case 'zh': return 'zh-CN';
      case 'ja': return 'ja-JP';
      case 'ru': return 'ru-RU';
      default: return 'en-US';
    }
  }

  Future<void> _initTts(String langCode) async {
    final locale = _getTtsLocale(langCode);
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(0.5);  // Adjusted to be slower based on user feedback
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.5);       // Slightly lower pitch = clearer female voice
    await _flutterTts.awaitSpeakCompletion(true); // REQUIRED for real-time continuous conversation loop
    
    // Try to explicitly select a female voice
    try {
      final voices = await _flutterTts.getVoices as List?;
      if (voices != null) {
        // Look for a female English voice
        Map? femaleVoice;
        
        for (final v in voices) {
          final name = (v['name'] ?? '').toString().toLowerCase();
          final locale = (v['locale'] ?? '').toString().toLowerCase();
          if (locale.startsWith('en') && (name.contains('female') || name.contains('woman') || name.contains('zira') || name.contains('susan') || name.contains('victoria') || name.contains('karen') || name.contains('google uk english female'))) {
            femaleVoice = v as Map?;
            break;
          }
        }
        
        // Fallback: pick any en-US or en-GB voice
        if (femaleVoice == null) {
          for (final v in voices) {
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            if (locale == 'en-us' || locale == 'en-gb') {
              femaleVoice = v as Map?;
              break;
            }
          }
        }
        
        if (femaleVoice != null) {
          await _flutterTts.setVoice({
            "name": femaleVoice['name'].toString(),
            "locale": femaleVoice['locale'].toString(),
          });
        }
      }
    } catch (e) {
      debugPrint('Voice selection error: $e');
      // Pitch alone will still make it sound more feminine
    }
  }
  
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (_) {
      _speechEnabled = false;
    }
  }
  
  Future<void> startListening(Function(String) onResult, {Function(String)? onFinalResult}) async {
    if (_speechEnabled) {
      await _flutterTts.stop();
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          // When user stops speaking, trigger auto-send
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            onFinalResult?.call(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  bool get isListening => _speechToText.isListening;

  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  Future<void> speak(String text) async {
    isSpeaking.value = true;
    
    _flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });
    
    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
    
    _flutterTts.setCancelHandler(() {
      isSpeaking.value = false;
    });

    await _flutterTts.speak(text);
  }
  
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    isSpeaking.value = false;
  }

  Future<String> sendMessage(String message, {double? speedKmH, String? destination}) async {
    // Update language from preferences before sending
    await _updateLanguageAndTts();

    if (_chatSession == null || _model == null) {
      const offlineMsg = "Hello! I'm LITA. Configure the Gemini API key in dart_defines.json to chat live with AI.";
      await speak(offlineMsg);
      return offlineMsg;
    }

    // Try up to 2 times
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        String contextMsg = '[Context: Speak to the user in $_currentLanguage language] $message';
        if (speedKmH != null && destination != null) {
          contextMsg = '[Context: Speak to the user in $_currentLanguage language, going to $destination at ${speedKmH.toStringAsFixed(0)} km/h] $message';
        }

        final response = await _chatSession!.sendMessage(Content.text(contextMsg))
            .timeout(const Duration(seconds: 15));
        final reply = response.text ?? 'I am right here with you!';

        await speak(reply);
        return reply;
      } catch (e) {
        debugPrint('LITA attempt ${attempt + 1} error: $e');
        // Reset the chat session so next attempt starts fresh
        _chatSession = _model?.startChat();
        if (attempt == 1) {
          // Both attempts failed — give a friendly voice reply
          const errorMsg = 'I am here! Just having a tiny network glitch. Try again!';
          await speak(errorMsg);
          return errorMsg;
        }
        // Small pause before retry
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return '';
  }
}
