import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart'; // Core interfaces

/// Messaging Service - Core business logic for P2P messaging
class MessagingService {
  // Messaging business logic
  final ITransportPort _transport; // Transport adapter
  final ICryptoPort _crypto; // Encryption adapter
  final IStoragePort _storage; // Storage adapter

  MessagingService({
    // Constructor with DI
    required ITransportPort transport, // Required transport
    required ICryptoPort crypto, // Required crypto
    required IStoragePort storage, // Required storage
  })  : _transport = transport, // Assign transport
        _crypto = crypto, // Assign crypto
        _storage = storage; // Assign storage

  /// Send a message to a peer
  Future<Message> sendMessage({
    // Send message method
    required String recipientId, // Target peer ID
    required String content, // Message text
    String? replyToId, // Optional reply reference
  }) async {
    final messageId =
        DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique ID
    final timestamp = DateTime.now(); // Current time

    // Encrypt the message content
    final recipientKey =
        await _getRecipientKey(recipientId); // Get recipient public key
    final encryptedBytes =
        await _crypto.encrypt(content, recipientKey); // Encrypt content

    // Create encrypted message for transport
    final encryptedMessage = EncryptedMessage(
      // Create transport message
      id: messageId, // Set ID
      senderId: await _getCurrentUserId(), // Set sender
      recipientId: recipientId, // Set recipient
      encryptedPayload: encryptedBytes, // Set encrypted data
      timestamp: timestamp, // Set timestamp
      replyToId: replyToId, // Set reply reference
    );

    // Send via transport
    await _transport.send(encryptedMessage); // Send to network

    // Store locally
    final message = Message(
      // Create local message
      id: messageId, // Set ID
      senderId: await _getCurrentUserId(), // Set sender
      recipientId: recipientId, // Set recipient
      content: content, // Set plaintext content
      timestamp: timestamp, // Set time
      status: MessageStatus.sent, // Set status
      replyToId: replyToId, // Set reply reference
    );

    await _storage.save('msg_$messageId', message.toJson());

    return message; // Return created message
  }

  /// Listen for incoming messages
  Stream<Message> get incomingMessages {
    // Incoming message stream
    final controller =
        StreamController<Message>.broadcast(); // Create broadcast stream

    _transport.onMessage((encrypted) async {
      // Register transport handler
      try {
        // Decrypt message
        final privateKey = await _getCurrentUserPrivateKey(); // Get private key
        final content = await _crypto.decrypt(
          // Decrypt payload
          encrypted.encryptedPayload,
          privateKey,
        );

        // Create message object
        final message = Message(
          // Create message
          id: encrypted.id, // Use transport ID
          senderId: encrypted.senderId, // Set sender
          recipientId: encrypted.recipientId, // Set recipient
          content: content, // Set decrypted content
          timestamp: encrypted.timestamp, // Set time
          status: MessageStatus.delivered, // Set delivered status
          replyToId: encrypted.replyToId, // Set reply reference
        );

        // Store locally
        await _storage.save(
            'msg_${message.id}', message.toJson()); // Persist message

        controller.add(message); // Add to stream
      } catch (e) {
        // ignore: avoid_print
        print('Error decrypting message: $e'); // Log error
      }
    });

    return controller.stream; // Return stream
  }

  /// Get conversation history with a peer
  Future<List<Message>> getConversation(String peerId) async {
    // Get message history
    final allMessages = await _storage.query<Map<String, dynamic>>(
      // Query storage
      QueryCriteria(type: 'message'), // Filter by type
    );

    return allMessages // Filter and map
        .map((json) => Message.fromJson(json))
        .where((msg) => // Filter peer messages
            msg.senderId == peerId ||
            msg.recipientId == peerId) // Either direction
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by time
  }

  // Helper methods
  Future<String> _getCurrentUserId() async {
    // Get current user ID
    final user =
        await _storage.load<Map<String, dynamic>>('current_user'); // Load user
    return user?['id'] ?? 'unknown'; // Return ID or default
  }

  Future<String> _getCurrentUserPrivateKey() async {
    // Get private key
    final user = await _storage.load<Map<String, dynamic>>('current_user');
    return user?['privateKey'] ?? ''; // Return key or empty
  }

  Future<String> _getRecipientKey(String peerId) async {
    // Get recipient public key
    final peer =
        await _storage.load<Map<String, dynamic>>('peer_$peerId'); // Load peer
    return peer?['publicKey'] ?? ''; // Return key or empty
  }
}

// Note: Message.toJson() and Message.fromJson() are auto-generated by Freezed
// Do not add manual extensions as they conflict with generated code
