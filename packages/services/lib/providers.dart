import 'package:ecomesh_core/ecomesh_core.dart';
import 'package:ecomesh_adapters/ecomesh_adapters.dart';
import 'package:ecomesh_services/messaging_service.dart';
import 'package:ecomesh_services/discovery_service.dart';
import 'package:ecomesh_services/contact_service.dart';
import 'package:ecomesh_services/ai_service.dart';
import 'package:ecomesh_services/identity_service.dart';
import 'package:riverpod/riverpod.dart';

// Transport Provider - Swappable transport implementation
final transportProvider = Provider<ITransportPort>((ref) {
  return WebRTCAdapter(
    signalingUrl: 'wss://signaling.ecomesh.workers.dev',
  );
});

// Storage Provider - Secure local database
final storageProvider = Provider<IStoragePort>((ref) {
  return SecureStorageAdapter();
});

// Crypto Provider - Encryption
final cryptoProvider = Provider<ICryptoPort>((ref) {
  return SignalCryptoAdapter();
});

// AI Provider - Cloudflare AI
final aiProvider = Provider<IAIPort>((ref) {
  return CloudflareAIAdapter(
    baseUrl: 'https://ai.ecomesh.workers.dev',
  );
});

// Identity Service Provider
final identityServiceProvider = Provider<IdentityService>((ref) {
  return IdentityService();
});

// Current User Provider - Reactive user state
final currentUserProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.watch(storageProvider));
});

// Auth State Provider
final authStateProvider = Provider<AuthState>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return AuthState.unauthenticated;
  return AuthState.authenticated;
});

// Messaging Service Provider - Business logic
final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(
    transport: ref.watch(transportProvider),
    crypto: ref.watch(cryptoProvider),
    storage: ref.watch(storageProvider),
  );
});

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(ai: ref.watch(aiProvider));
});

// Messages Stream Provider - Reactive message stream
final messagesStreamProvider = StreamProvider<List<Message>>((ref) {
  final service = ref.watch(messagingServiceProvider);
  return service.incomingMessages
      .map((msg) => [msg])
      .asyncExpand((msg) async* {
        final history = await service.getConversation(msg.first.recipientId);
        yield history;
      });
});

// Conversation Provider - For specific peer
final conversationProvider = FutureProvider.family<List<Message>, String>((ref, peerId) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getConversation(peerId);
});

// Contacts Provider
final contactsProvider = Provider<ContactService>((ref) {
  return ContactService(storage: ref.watch(storageProvider));
});

// Discovery Provider
final discoveryProvider = Provider<DiscoveryService>((ref) {
  return DiscoveryService(
    transport: ref.watch(transportProvider),
    storage: ref.watch(storageProvider),
  );
});

/// Auth State Enum
enum AuthState {
  unauthenticated,
  authenticated,
}

/// User Notifier - Manages user state
class UserNotifier extends StateNotifier<User?> {
  final IStoragePort _storage;

  UserNotifier(this._storage) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final identity = await _storage.load<Map<String, dynamic>>('user_identity');
    if (identity != null) {
      final userId = identity['userId'] as String;
      state = User(
        id: userId,
        username: 'user_${userId.substring(0, 8)}',
        displayName: 'Anonymous User',
        publicKey: identity['publicKey'] as String,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> setUser(User user) async {
    state = user;
  }

  Future<void> clearUser() async {
    state = null;
  }
}
