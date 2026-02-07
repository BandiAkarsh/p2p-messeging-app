import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Mock AI Adapter - For testing without AI service
class MockAIAdapter implements IAIPort {
  final bool _shouldFail;
  final Duration _delay;

  MockAIAdapter({bool shouldFail = false, Duration? delay})
      : _shouldFail = shouldFail,
        _delay = delay ?? const Duration(milliseconds: 100);

  @override
  Future<bool> isAvailable() async => !_shouldFail;

  @override
  Future<String> generateReply(MessageContext context) async {
    await Future.delayed(_delay);
    if (_shouldFail) throw Exception('Mock AI failure');
    
    final responses = [
      'That sounds great! 👍',
      'I agree with you.',
      'Let me think about it...',
      'Thanks for sharing!',
      'Interesting point!',
    ];
    return responses[context.incomingMessage.length % responses.length];
  }

  @override
  Future<String> summarize(List<String> messages) async {
    await Future.delayed(_delay);
    if (_shouldFail) throw Exception('Mock AI failure');
    
    if (messages.isEmpty) return 'No messages to summarize.';
    return 'Summary of ${messages.length} messages: ${messages.first.substring(0, messages.first.length > 50 ? 50 : messages.first.length)}...';
  }

  @override
  Future<String> translate(String text, String targetLang) async {
    await Future.delayed(_delay);
    if (_shouldFail) throw Exception('Mock AI failure');
    
    return '[$targetLang] $text';
  }

  @override
  Future<String> detectLanguage(String text) async {
    await Future.delayed(_delay);
    if (_shouldFail) return 'en';
    
    // Simple heuristic
    if (text.contains('hello') || text.contains('the')) return 'en';
    if (text.contains('hola') || text.contains('el')) return 'es';
    if (text.contains('bonjour') || text.contains('le')) return 'fr';
    return 'en';
  }
}
