/// Storage Port Interface - Abstracts local data persistence
abstract class IStoragePort {                                         // Interface for storage adapters
  Future<void> save(String key, dynamic data);                        // Save data by key
  Future<T?> load<T>(String key);                                     // Load data with type safety
  Future<void> delete(String key);                                    // Remove data by key
  Future<List<T>> query<T>(QueryCriteria criteria);                   // Query with filters
  Future<void> sync(String remotePeer);                               // Sync with remote peer
  Stream<SyncEvent> get syncEvents;                                   // Stream of sync events
}

class QueryCriteria {                                                 // Query parameters
  final String? type;                                                 // Data type filter
  final DateTime? after;                                              // Time filter (newer than)
  final DateTime? before;                                             // Time filter (older than)
  final int? limit;                                                   // Max results
  final Map<String, dynamic>? filters;                                // Additional filters

  QueryCriteria({                                                     // Constructor
    this.type,                                                        // Optional type
    this.after,                                                       // Optional after time
    this.before,                                                      // Optional before time
    this.limit,                                                       // Optional limit
    this.filters,                                                     // Optional filters
  });
}

class SyncEvent {                                                     // Synchronization event
  final SyncType type;                                                // Event type
  final String peerId;                                                // Involved peer
  final int itemsSynced;                                              // Count synced
  final DateTime timestamp;                                           // Event time

  SyncEvent({                                                         // Constructor
    required this.type,                                               // Required type
    required this.peerId,                                             // Required peer
    required this.itemsSynced,                                        // Required count
    required this.timestamp,                                          // Required time
  });
}

enum SyncType {                                                       // Sync event types
  started,                                                            // Sync began
  completed,                                                          // Sync finished
  failed,                                                             // Sync error
  deltaReceived,                                                      // Got remote changes
}
