import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';

/// Memory Storage Adapter - In-memory storage for testing
class MemoryAdapter implements IStoragePort {
  final Map<String, _StorageEntry> _data = {};
  final _syncController = StreamController<SyncEvent>.broadcast();

  @override
  Future<void> save(String key, dynamic data) async {
    _data[key] = _StorageEntry(
      key: key,
      data: data,
      type: data.runtimeType.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<T?> load<T>(String key) async {
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
    _data.remove(key);
  }

  @override
  Future<List<T>> query<T>(QueryCriteria criteria) async {
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
    _syncController.add(SyncEvent(
      type: SyncType.started,
      peerId: remotePeer,
      itemsSynced: 0,
      timestamp: DateTime.now(),
    ));

    // Mock sync - no actual syncing in memory
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

  // Helper methods for testing
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
