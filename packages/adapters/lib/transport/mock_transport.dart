import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Mock Transport Adapter - For testing without real network
class MockTransportAdapter implements ITransportPort {
  final _messageController = StreamController<EncryptedMessage>.broadcast();
  TransportStatus _status = TransportStatus.disconnected;
  String? _currentPeerId;
  final List<EncryptedMessage> _messageQueue = [];

  /// Get currently connected peer ID
  String? get currentPeerId => _currentPeerId;

  @override
  Future<void> connect(String peerId) async {
    _status = TransportStatus.connecting;
    await Future.delayed(const Duration(milliseconds: 100));
    _currentPeerId = peerId;
    _status = TransportStatus.connected;
  }

  @override
  Future<void> send(EncryptedMessage message) async {
    if (_status != TransportStatus.connected) {
      throw StateError('Not connected');
    }
    // In real implementation, this would send over network
    // For mock, we just queue it
    _messageQueue.add(message);
  }

  @override
  void onMessage(void Function(EncryptedMessage msg) callback) {
    _messageController.stream.listen(callback);
  }

  @override
  Future<void> disconnect() async {
    _status = TransportStatus.disconnected;
    _currentPeerId = null;
    _messageQueue.clear();
  }

  @override
  TransportStatus get status => _status;

  // Helper method for testing - simulate receiving a message
  void simulateIncomingMessage(EncryptedMessage message) {
    _messageController.add(message);
  }

  // Helper to get queued messages
  List<EncryptedMessage> get queuedMessages => List.unmodifiable(_messageQueue);
}
