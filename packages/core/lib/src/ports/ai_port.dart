/// AI Port Interface - Abstracts AI service (cloud or local)
abstract class IAIPort {                                              // AI service interface
  Future<String> generateReply(MessageContext context);               // Generate smart reply
  Future<String> summarize(List<String> messages);                    // Summarize conversation
  Future<String> translate(String text, String targetLang);           // Translate text
  Future<String> detectLanguage(String text);                         // Detect language
  Future<bool> isAvailable();                                         // Check service availability
}

class MessageContext {                                                // Context for AI reply
  final String incomingMessage;                                       // Message to reply to
  final List<String> recentHistory;                                   // Recent conversation
  final String? preferredTone;                                        // Reply tone preference
  final String? userLanguage;                                         // User's language

  MessageContext({                                                    // Constructor
    required this.incomingMessage,                                    // Required message
    this.recentHistory = const [],                                    // Optional history
    this.preferredTone,                                               // Optional tone
    this.userLanguage,                                                // Optional language
  });
}

class AIResponse {                                                    // AI service response
  final String text;                                                  // Response text
  final String modelUsed;                                             // Model identifier
  final int latencyMs;                                                // Response time
  final double? confidence;                                           // Optional confidence

  AIResponse({                                                        // Constructor
    required this.text,                                               // Required text
    required this.modelUsed,                                          // Required model
    required this.latencyMs,                                          // Required latency
    this.confidence,                                                  // Optional confidence
  });
}
