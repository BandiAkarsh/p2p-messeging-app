import 'package:freezed_annotation/freezed_annotation.dart';          // Freezed code generation

part 'peer.freezed.dart';                                              // Generated code part
part 'peer.g.dart';                                                    // JSON serialization part

@freezed                                                              // Immutable class annotation
class Peer with _$Peer {                                               // Peer model class
  const factory Peer({                                                 // Factory constructor
    required String id,                                                // Unique peer ID
    required String publicKey,                                         // Encryption public key
    String? displayName,                                               // Optional display name
    DateTime? lastSeen,                                                // Last activity timestamp
    @Default(ConnectionStatus.offline) ConnectionStatus status,       // Connection state
    String? avatarUrl,                                                 // Optional avatar URL
  }) = _Peer;                                                          // Private constructor

  factory Peer.fromJson(Map<String, dynamic> json) =>                  // JSON deserialization
      _$PeerFromJson(json);                                            // Generated fromJson
}

enum ConnectionStatus {                                               // Peer connection states
  offline,                                                            // Not connected
  connecting,                                                         // Connection in progress
  online,                                                             // Connected
  away                                                                // Inactive but connected
}
