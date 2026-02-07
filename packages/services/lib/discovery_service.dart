import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Discovery Service - Manages peer discovery and connection
class DiscoveryService {
  final ITransportPort _transport;
  final IStoragePort _storage;
  final _peerController = StreamController<List<Peer>>.broadcast();
  final Set<Peer> _discoveredPeers = {};
  bool _isScanning = false;

  DiscoveryService({
    required ITransportPort transport,
    required IStoragePort storage,
  })  : _transport = transport,
        _storage = storage;

  /// Start scanning for nearby peers
  Future<void> startDiscovery() async {
    if (_isScanning) return;
    
    _isScanning = true;
    
    // Listen for transport connection events
    _transport.onMessage((message) {
      // When we receive a message, we know the peer is online
      _updatePeerStatus(message.senderId, ConnectionStatus.online);
    });

    // Broadcast discovery message
    // In real implementation, this would use mDNS, Bluetooth, or signaling server
    
    _peerController.add(List.unmodifiable(_discoveredPeers));
  }

  /// Stop scanning for peers
  Future<void> stopDiscovery() async {
    _isScanning = false;
  }

  /// Connect to a specific peer
  Future<void> connectToPeer(String peerId) async {
    try {
      await _transport.connect(peerId);
      
      // Update peer status
      final existingPeer = _discoveredPeers.where((p) => p.id == peerId).firstOrNull;
      if (existingPeer != null) {
        _discoveredPeers.remove(existingPeer);
        _discoveredPeers.add(existingPeer.copyWith(status: ConnectionStatus.online));
      }
      
      _peerController.add(List.unmodifiable(_discoveredPeers));
    } catch (e) {
      // Update to error status
      final existingPeer = _discoveredPeers.where((p) => p.id == peerId).firstOrNull;
      if (existingPeer != null) {
        _discoveredPeers.remove(existingPeer);
        _discoveredPeers.add(existingPeer.copyWith(status: ConnectionStatus.offline));
      }
      _peerController.add(List.unmodifiable(_discoveredPeers));
      rethrow;
    }
  }

  /// Disconnect from a peer
  Future<void> disconnectFromPeer(String peerId) async {
    await _transport.disconnect();
    
    final existingPeer = _discoveredPeers.where((p) => p.id == peerId).firstOrNull;
    if (existingPeer != null) {
      _discoveredPeers.remove(existingPeer);
      _discoveredPeers.add(existingPeer.copyWith(status: ConnectionStatus.offline));
    }
    
    _peerController.add(List.unmodifiable(_discoveredPeers));
  }

  /// Get stream of discovered peers
  Stream<List<Peer>> get discoveredPeers => _peerController.stream;

  /// Get current connection status
  TransportStatus get connectionStatus => _transport.status;

  /// Check if currently scanning
  bool get isScanning => _isScanning;

  /// Get all known peers from storage
  Future<List<Peer>> getKnownPeers() async {
    final peersData = await _storage.query<Map<String, dynamic>>(
      QueryCriteria(type: 'peer'),
    );
    
    return peersData.map((data) => Peer.fromJson(data)).toList();
  }

  void _updatePeerStatus(String peerId, ConnectionStatus status) {
    final existingPeer = _discoveredPeers.where((p) => p.id == peerId).firstOrNull;
    
    if (existingPeer != null) {
      _discoveredPeers.remove(existingPeer);
      _discoveredPeers.add(existingPeer.copyWith(
        status: status,
        lastSeen: DateTime.now(),
      ));
    } else {
      _discoveredPeers.add(Peer(
        id: peerId,
        publicKey: '',
        status: status,
        lastSeen: DateTime.now(),
      ));
    }
    
    _peerController.add(List.unmodifiable(_discoveredPeers));
  }

  void dispose() {
    _peerController.close();
  }
}
