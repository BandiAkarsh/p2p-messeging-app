import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Contact Service - Manages contacts and peer information
class ContactService {
  final IStoragePort _storage;
  final _contactsController = StreamController<List<Peer>>.broadcast();

  ContactService({required IStoragePort storage}) : _storage = storage;

  /// Add a new contact
  Future<Peer> addContact({
    required String id,
    required String publicKey,
    String? displayName,
    String? avatarUrl,
  }) async {
    final peer = Peer(
      id: id,
      publicKey: publicKey,
      displayName: displayName,
      avatarUrl: avatarUrl,
      status: ConnectionStatus.offline,
    );

    await _storage.save('peer_$id', peer.toJson());
    await _notifyContactsChanged();

    return peer;
  }

  /// Remove a contact
  Future<void> removeContact(String peerId) async {
    await _storage.delete('peer_$peerId');
    await _notifyContactsChanged();
  }

  /// Update contact information
  Future<Peer> updateContact(String peerId, {
    String? displayName,
    String? avatarUrl,
    ConnectionStatus? status,
  }) async {
    final existingData = await _storage.load<Map<String, dynamic>>('peer_$peerId');
    if (existingData == null) {
      throw Exception('Contact not found: $peerId');
    }

    final existing = Peer.fromJson(existingData);
    final updated = existing.copyWith(
      displayName: displayName ?? existing.displayName,
      avatarUrl: avatarUrl ?? existing.avatarUrl,
      status: status ?? existing.status,
      lastSeen: status == ConnectionStatus.online ? DateTime.now() : existing.lastSeen,
    );

    await _storage.save('peer_$peerId', updated.toJson());
    await _notifyContactsChanged();

    return updated;
  }

  /// Get a single contact
  Future<Peer?> getContact(String peerId) async {
    final data = await _storage.load<Map<String, dynamic>>('peer_$peerId');
    if (data == null) return null;
    return Peer.fromJson(data);
  }

  /// Get all contacts
  Future<List<Peer>> getAllContacts() async {
    final allData = await _storage.query<Map<String, dynamic>>(
      QueryCriteria(),
    );

    return allData
        .where((data) => data.containsKey('id'))
        .map((data) => Peer.fromJson(data))
        .toList();
  }

  /// Search contacts by name
  Future<List<Peer>> searchContacts(String query) async {
    final allContacts = await getAllContacts();
    final lowerQuery = query.toLowerCase();

    return allContacts.where((peer) {
      final displayName = peer.displayName?.toLowerCase() ?? '';
      final id = peer.id.toLowerCase();
      return displayName.contains(lowerQuery) || id.contains(lowerQuery);
    }).toList();
  }

  /// Block a peer
  Future<void> blockPeer(String peerId) async {
    final contact = await getContact(peerId);
    if (contact == null) return;

    // Update with blocked status
    await updateContact(peerId, status: ConnectionStatus.offline);
    
    // Add to blocked list in user preferences
    // This would require access to current user - simplified here
  }

  /// Unblock a peer
  Future<void> unblockPeer(String peerId) async {
    // Remove from blocked list
    // Implementation depends on how blocked list is stored
  }

  /// Get stream of contacts changes
  Stream<List<Peer>> get contactsStream => _contactsController.stream;

  /// Update peer online status
  Future<void> updatePeerStatus(String peerId, ConnectionStatus status) async {
    await updateContact(peerId, status: status);
  }

  Future<void> _notifyContactsChanged() async {
    final contacts = await getAllContacts();
    _contactsController.add(contacts);
  }

  void dispose() {
    _contactsController.close();
  }
}
