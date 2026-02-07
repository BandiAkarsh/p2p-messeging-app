import 'package:freezed_annotation/freezed_annotation.dart';          // Freezed code generation

part 'message.freezed.dart';                                           // Generated code part
part 'message.g.dart';                                                 // JSON serialization part

@freezed                                                              // Annotation for immutable class
class Message with _$Message {                                         // Message model class
  const factory Message({                                              // Factory constructor
    required String id,                                                // Unique message ID
    required String senderId,                                          // Sender peer ID
    required String recipientId,                                       // Recipient peer ID
    required String content,                                           // Message text content
    required DateTime timestamp,                                       // Creation timestamp
    @Default(MessageStatus.pending) MessageStatus status,              // Delivery status
    String? replyToId,                                                 // Reply reference ID
    String? threadId,                                                  // Thread group ID
  }) = _Message;                                                       // Private constructor

  factory Message.fromJson(Map<String, dynamic> json) =>               // JSON deserialization
      _$MessageFromJson(json);                                         // Generated fromJson
}

enum MessageStatus {                                                  // Message delivery states
  pending,                                                            // Not yet sent
  sent,                                                               // Sent but not delivered
  delivered,                                                          // Delivered to recipient
  read,                                                               // Read by recipient
  failed                                                              // Failed to send
}
