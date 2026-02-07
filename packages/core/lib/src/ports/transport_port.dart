import 'dart:typed_data';                                            // For binary data types

/// Transport Port Interface - Abstracts P2P communication layer
abstract class ITransportPort {                                       // Interface for all transport adapters
  Future<void> connect(String peerId);                                // Establish connection to peer
  Future<void> send(EncryptedMessage message);                        // Send encrypted message
  void onMessage(void Function(EncryptedMessage msg) callback);       // Register message handler
  Future<void> disconnect();                                          // Close connection
  TransportStatus get status;                                         // Current connection status
}

enum TransportStatus {                                                // Connection state enum
  disconnected,                                                       // Not connected
  connecting,                                                         // In progress
  connected,                                                          // Active connection
  error                                                               // Error state
}

class EncryptedMessage {                                              // Encrypted message structure
  final String id;                                                    // Unique message ID
  final String senderId;                                              // Sender peer ID
  final String recipientId;                                           // Recipient peer ID
  final Uint8List encryptedPayload;                                   // Encrypted content
  final DateTime timestamp;                                           // Creation time
  final String? replyToId;                                            // Optional reply reference

  EncryptedMessage({                                                  // Constructor with named params
    required this.id,                                                 // Required ID
    required this.senderId,                                           // Required sender
    required this.recipientId,                                        // Required recipient
    required this.encryptedPayload,                                   // Required encrypted data
    required this.timestamp,                                          // Required timestamp
    this.replyToId,                                                   // Optional reply reference
  });
}
