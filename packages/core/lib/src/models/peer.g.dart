// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeerImpl _$$PeerImplFromJson(Map<String, dynamic> json) => _$PeerImpl(
      id: json['id'] as String,
      publicKey: json['publicKey'] as String,
      displayName: json['displayName'] as String?,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      status: $enumDecodeNullable(_$ConnectionStatusEnumMap, json['status']) ??
          ConnectionStatus.offline,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$PeerImplToJson(_$PeerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicKey': instance.publicKey,
      'displayName': instance.displayName,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'status': _$ConnectionStatusEnumMap[instance.status]!,
      'avatarUrl': instance.avatarUrl,
    };

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.offline: 'offline',
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.online: 'online',
  ConnectionStatus.away: 'away',
};
