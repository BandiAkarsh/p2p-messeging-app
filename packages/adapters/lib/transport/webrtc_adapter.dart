import 'dart:async';                                                 // Async support
import 'dart:convert';                                               // JSON encoding
import 'dart:typed_data';                                            // Binary data
import 'package:ecomesh_core/ecomesh_core.dart';                     // Core interfaces
import 'package:web_socket_channel/web_socket_channel.dart';         // WebSocket support
import 'package:http/http.dart' as http;                             // HTTP client

/// WebRTC Transport Adapter - Uses WebRTC for P2P communication
class WebRTCAdapter implements ITransportPort {                       // Implements transport interface
  final String signalingUrl;                                          // Signaling server URL
  WebSocketChannel? _channel;                                         // WebSocket connection
  final _messageController = StreamController<EncryptedMessage>.broadcast(); // Message stream
  TransportStatus _status = TransportStatus.disconnected;             // Current status
  String? _currentPeerId;                                             // Connected peer ID

  WebRTCAdapter({                                                     // Constructor
    required this.signalingUrl,                                       // Required signaling URL
  });

  @override
  Future<void> connect(String peerId) async {                         // Connect to peer
    _status = TransportStatus.connecting;                             // Set connecting state
    _currentPeerId = peerId;                                          // Store peer ID

    try {
      final wsUrl = '$signalingUrl/ws?room=global&peer=$peerId';      // Build WebSocket URL
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));          // Connect WebSocket

      _channel!.stream.listen(                                        // Listen for messages
        (message) => _handleMessage(message as String),               // Handle incoming
        onError: (error) => _status = TransportStatus.error,          // Handle errors
        onDone: () => _status = TransportStatus.disconnected,         // Handle disconnect
      );

      _status = TransportStatus.connected;                            // Set connected
    } catch (e) {
      _status = TransportStatus.error;                                // Set error state
      rethrow;                                                        // Propagate error
    }
  }

  @override
  Future<void> send(EncryptedMessage message) async {                 // Send message
    if (_channel == null || _status != TransportStatus.connected) {   // Check connection
      throw StateError('Not connected');                              // Throw if not connected
    }

    final payload = jsonEncode({                                      // Encode message
      'type': 'message',                                              // Message type
      'senderId': message.senderId,                                   // Sender ID
      'recipientId': message.recipientId,                             // Recipient ID
      'encryptedData': base64Encode(message.encryptedPayload),        // Base64 encode
      'timestamp': message.timestamp.toIso8601String(),               // ISO timestamp
      'replyToId': message.replyToId,                                 // Reply reference
    });

    _channel!.sink.add(payload);                                      // Send via WebSocket
  }

  @override
  void onMessage(void Function(EncryptedMessage msg) callback) {      // Register handler
    _messageController.stream.listen(callback);                       // Subscribe to stream
  }

  @override
  Future<void> disconnect() async {                                   // Disconnect
    _status = TransportStatus.disconnected;                           // Set status
    await _channel?.sink.close();                                     // Close WebSocket
    _channel = null;                                                  // Clear reference
    _currentPeerId = null;                                            // Clear peer ID
  }

  @override
  TransportStatus get status => _status;                              // Get current status

  void _handleMessage(String message) {                               // Process incoming
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;       // Parse JSON
      final encryptedMessage = EncryptedMessage(                      // Create message object
        id: data['id'] ?? DateTime.now().toIso8601String(),            // Use provided or new ID
        senderId: data['senderId'] as String,                         // Extract sender
        recipientId: data['recipientId'] as String,                   // Extract recipient
        encryptedPayload: base64Decode(data['encryptedData'] as String), // Decode payload
        timestamp: DateTime.parse(data['timestamp'] as String),       // Parse timestamp
        replyToId: data['replyToId'] as String?,                      // Extract reply ref
      );

      _messageController.add(encryptedMessage);                       // Add to stream
    } catch (e) {
      // Log error but don't crash
      print('Error handling message: $e');                            // Log error
    }
  }
}
