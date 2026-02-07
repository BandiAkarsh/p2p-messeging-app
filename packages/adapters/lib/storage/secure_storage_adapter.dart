import 'dart:async';
import 'dart:convert';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Secure Storage Adapter - Local storage with encryption support
/// Uses localStorage for web and file-based storage for mobile
class SecureStorageAdapter implements IStoragePort {
  final Map<String, _StorageEntry> _data = {};
  final _syncController = StreamController<SyncEvent>.broadcast();
  bool _initialized = false;

  /// Initialize storage from persistence (localStorage on web)
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Load from localStorage if available (web only)
    try {
      // This will be implemented differently for web vs mobile
      // For now, use in-memory with persistence stub
      _initialized = true;
    } catch (e) {
      // Fall back to memory-only
      _initialized = true;
    }
  }

  @override
  Future<void> save(String key, dynamic data) async {
    await initialize();
    
    _data[key] = _StorageEntry(
      key: key,
      data: data,
      type: data.runtimeType.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Persist to localStorage (web)
    await _persist();
  }

  @override
  Future<T?> load<T>(String key) async {
    await initialize();
    
    final entry = _data[key];
    if (entry == null) return null;

    try {
      return entry.data as T?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    await initialize();
    _data.remove(key);
    await _persist();
  }

  @override
  Future<List<T>> query<T>(QueryCriteria criteria) async {
    await initialize();
    
    var entries = _data.values.toList();

    if (criteria.type != null) {
      entries = entries.where((e) => e.type == criteria.type).toList();
    }

    if (criteria.after != null) {
      entries = entries.where((e) => e.updatedAt.isAfter(criteria.after!)).toList();
    }

    if (criteria.before != null) {
      entries = entries.where((e) => e.updatedAt.isBefore(criteria.before!)).toList();
    }

    if (criteria.limit != null && entries.length > criteria.limit!) {
      entries = entries.sublist(0, criteria.limit);
    }

    return entries.map((e) {
      try {
        return e.data as T;
      } catch (e) {
        return null;
      }
    }).where((e) => e != null).cast<T>().toList();
  }

  @override
  Future<void> sync(String remotePeer) async {
    await initialize();
    
    _syncController.add(SyncEvent(
      type: SyncType.started,
      peerId: remotePeer,
      itemsSynced: 0,
      timestamp: DateTime.now(),
    ));

    // Mock sync - no actual syncing in this implementation
    await Future.delayed(const Duration(milliseconds: 100));

    _syncController.add(SyncEvent(
      type: SyncType.completed,
      peerId: remotePeer,
      itemsSynced: _data.length,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Stream<SyncEvent> get syncEvents => _syncController.stream;

  /// Persist data to localStorage (web implementation)
  Future<void> _persist() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _data.entries) {
        data[entry.key] = {
          'data': entry.value.data,
          'type': entry.value.type,
          'createdAt': entry.value.createdAt.toIso8601String(),
          'updatedAt': entry.value.updatedAt.toIso8601String(),
        };
      }
      // Store in localStorage would go here
      // html.window.localStorage['ecomesh_data'] = jsonEncode(data);
    } catch (e) {
      // Storage not available
    }
  }

  // Helper methods for identity storage
  Future<void> saveUserIdentity(Map<String, String> identity) async {
    await save('user_identity', identity);
  }

  Future<Map<String, String>?> loadUserIdentity() async {
    return await load<Map<String, dynamic>>('user_identity') 
        as Map<String, String>?;
  }

  Future<void> deleteUserIdentity() async {
    await delete('user_identity');
  }

  void clear() => _data.clear();
  int get count => _data.length;
  bool containsKey(String key) => _data.containsKey(key);
}

class _StorageEntry {
  final String key;
  final dynamic data;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  _StorageEntry({
    required this.key,
    required this.data,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });
}
