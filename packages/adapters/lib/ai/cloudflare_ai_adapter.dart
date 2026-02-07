import 'dart:convert';                                               // JSON encoding
import 'package:ecomesh_core/ecomesh_core.dart';                     // Core interfaces
import 'package:http/http.dart' as http;                             // HTTP client

/// Cloudflare AI Adapter - Uses Cloudflare Workers AI for all AI features
class CloudflareAIAdapter implements IAIPort {                        // Implements AI interface
  final String baseUrl;                                               // AI worker base URL
  final http.Client _client;                                          // HTTP client instance

  CloudflareAIAdapter({                                               // Constructor
    required this.baseUrl,                                            // Required base URL
    http.Client? client,                                              // Optional client
  }) : _client = client ?? http.Client();                             // Use provided or create new

  @override
  Future<bool> isAvailable() async {                                  // Check service availability
    try {
      final response = await _client.get(                              // Make health check request
        Uri.parse('$baseUrl/health'),                                  // Health endpoint
      );
      return response.statusCode == 200;                               // Return true if healthy
    } catch (e) {
      return false;                                                    // Return false on error
    }
  }

  @override
  Future<String> generateReply(MessageContext context) async {        // Generate smart reply
    final response = await _client.post(                               // POST to AI endpoint
      Uri.parse('$baseUrl/smart-reply'),                               // Smart reply endpoint
      headers: {'Content-Type': 'application/json'},                   // JSON content type
      body: jsonEncode({                                               // Request body
        'message': context.incomingMessage,                            // Message to reply to
        'context': context.recentHistory.join('\n'),                   // Recent conversation
        'tone': context.preferredTone ?? 'friendly',                   // Tone preference
      }),
    );

    if (response.statusCode != 200) {                                  // Check for errors
      throw Exception('AI service error: ${response.statusCode}');     // Throw on failure
    }

    final data = jsonDecode(response.body);                            // Parse response
    final suggestions = data['suggestions'] as List<dynamic>;          // Extract suggestions
    
    if (suggestions.isEmpty) {                                         // Check if empty
      return '👍';                                                    // Return thumbs up fallback
    }

    return suggestions.first as String;                                // Return first suggestion
  }

  @override
  Future<String> summarize(List<String> messages) async {             // Summarize conversation
    final response = await _client.post(                               // POST request
      Uri.parse('$baseUrl/summarize'),                                 // Summarize endpoint
      headers: {'Content-Type': 'application/json'},                   // JSON content
      body: jsonEncode({                                               // Request body
        'text': messages.join('\n'),                                  // Join all messages
        'maxLength': 100,                                              // Max words in summary
      }),
    );

    if (response.statusCode != 200) {                                  // Error check
      throw Exception('AI service error: ${response.statusCode}');     // Throw on error
    }

    final data = jsonDecode(response.body);                            // Parse JSON
    return data['summary'] as String;                                  // Return summary text
  }

  @override
  Future<String> translate(String text, String targetLang) async {     // Translate text
    final response = await _client.post(                               // POST request
      Uri.parse('$baseUrl/translate'),                                 // Translate endpoint
      headers: {'Content-Type': 'application/json'},                   // JSON content
      body: jsonEncode({                                               // Request body
        'text': text,                                                  // Text to translate
        'targetLang': targetLang,                                      // Target language code
      }),
    );

    if (response.statusCode != 200) {                                  // Error check
      throw Exception('AI service error: ${response.statusCode}');     // Throw error
    }

    final data = jsonDecode(response.body);                            // Parse response
    return data['translation'] as String;                              // Return translation
  }

  @override
  Future<String> detectLanguage(String text) async {                  // Detect language
    final response = await _client.post(                               // POST request
      Uri.parse('$baseUrl/detect-language'),                           // Detect endpoint
      headers: {'Content-Type': 'application/json'},                   // JSON content
      body: jsonEncode({'text': text}),                                // Request body
    );

    if (response.statusCode != 200) {                                  // Error check
      return 'en';                                                    // Default to English on error
    }

    final data = jsonDecode(response.body);                            // Parse response
    return data['language'] as String? ?? 'en';                        // Return detected or default
  }
}
