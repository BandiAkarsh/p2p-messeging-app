import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// AI Service - Orchestrates AI features for the app
class AIService {
  final IAIPort _ai;
  final _suggestionController = StreamController<List<String>>.broadcast();

  AIService({required IAIPort ai}) : _ai = ai;

  /// Check if AI service is available
  Future<bool> get isAvailable => _ai.isAvailable();

  /// Generate smart reply suggestions
  Future<String> generateReply(MessageContext context) async {
    if (!await isAvailable) {
      throw Exception('AI service not available');
    }
    return _ai.generateReply(context);
  }

  /// Generate multiple reply suggestions
  Future<List<String>> generateReplySuggestions(
    String incomingMessage, {
    List<String> recentHistory = const [],
    String tone = 'friendly',
  }) async {
    if (!await isAvailable) {
      return _getFallbackSuggestions();
    }

    try {
      final context = MessageContext(
        incomingMessage: incomingMessage,
        recentHistory: recentHistory,
        preferredTone: tone,
      );

      // Generate 3 suggestions by calling the AI multiple times
      final suggestions = <String>[];
      for (int i = 0; i < 3; i++) {
        try {
          final suggestion = await _ai.generateReply(context);
          if (!suggestions.contains(suggestion)) {
            suggestions.add(suggestion);
          }
        } catch (e) {
          // Continue to next suggestion
        }
      }

      if (suggestions.isEmpty) {
        return _getFallbackSuggestions();
      }

      _suggestionController.add(suggestions);
      return suggestions;
    } catch (e) {
      return _getFallbackSuggestions();
    }
  }

  /// Summarize a conversation
  Future<String> summarizeConversation(List<String> messages) async {
    if (!await isAvailable) {
      return 'AI unavailable - cannot generate summary';
    }

    if (messages.isEmpty) {
      return 'No messages to summarize';
    }

    try {
      return await _ai.summarize(messages);
    } catch (e) {
      return 'Failed to generate summary: ${e.toString()}';
    }
  }

  /// Translate text to target language
  Future<String> translate(String text, String targetLanguage) async {
    if (!await isAvailable) {
      return text; // Return original if AI unavailable
    }

    try {
      return await _ai.translate(text, targetLanguage);
    } catch (e) {
      return text; // Return original on error
    }
  }

  /// Detect the language of text
  Future<String> detectLanguage(String text) async {
    if (!await isAvailable) {
      return 'en'; // Default to English
    }

    try {
      return await _ai.detectLanguage(text);
    } catch (e) {
      return 'en'; // Default on error
    }
  }

  /// Get smart reply suggestions for UI
  Stream<List<String>> get suggestionStream => _suggestionController.stream;

  /// Predefined fallback suggestions when AI is unavailable
  List<String> _getFallbackSuggestions() {
    return [
      '👍 That sounds great!',
      'I\'ll get back to you soon',
      'Thanks for letting me know',
      'Can we talk about this later?',
      'I agree with you',
    ];
  }

  void dispose() {
    _suggestionController.close();
  }
}
