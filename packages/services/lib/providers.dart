import 'package:ecomesh_core/ecomesh_core.dart';                     
import 'package:ecomesh_adapters/ecomesh_adapters.dart';             
import 'package:ecomesh_services/messaging_service.dart';
import 'package:ecomesh_services/discovery_service.dart';
import 'package:ecomesh_services/contact_service.dart';
import 'package:ecomesh_services/ai_service.dart';
import 'package:riverpod/riverpod.dart';

// Transport Provider - Swappable transport implementation
final transportProvider = Provider<ITransportPort>((ref) {            # Transport adapter provider
  return WebRTCAdapter(                                               # Return WebRTC adapter
    signalingUrl: 'wss://signaling.ecomesh.workers.dev',              # Cloudflare signaling URL
  );
});

// Storage Provider - Local database
final storageProvider = Provider<IStoragePort>((ref) {
  return MemoryAdapter();
});

// Crypto Provider - Encryption
final cryptoProvider = Provider<ICryptoPort>((ref) {                  # Crypto adapter provider
  return SignalCryptoAdapter();                                       # Return Signal Protocol
});

// AI Provider - Cloudflare AI
final aiProvider = Provider<IAIPort>((ref) {                         # AI adapter provider
  return CloudflareAIAdapter(                                         # Return Cloudflare AI
    baseUrl: 'https://ai.ecomesh.workers.dev',                        # AI worker URL
  );
});

// Messaging Service Provider - Business logic
final messagingServiceProvider = Provider<MessagingService>((ref) {   # Messaging service provider
  return MessagingService(                                            # Create service
    transport: ref.watch(transportProvider),                          # Inject transport
    crypto: ref.watch(cryptoProvider),                                # Inject crypto
    storage: ref.watch(storageProvider),                              # Inject storage
  );
});

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {                 # AI service provider
  return AIService(ai: ref.watch(aiProvider));                        # Create with AI adapter
});

// Messages Stream Provider - Reactive message stream
final messagesStreamProvider = StreamProvider<List<Message>>((ref) {  # Message stream provider
  final service = ref.watch(messagingServiceProvider);                 # Watch messaging service
  return service.incomingMessages                                     # Get incoming stream
      .map((msg) => [msg])                                            // Wrap in list
      .asyncExpand((msg) async* {                                     // Expand stream
        final history = await service.getConversation(msg.first.recipientId); # Get history
        yield history;                                                // Yield full history
      });
});

// Conversation Provider - For specific peer
final conversationProvider = FutureProvider.family<List<Message>, String>((ref, peerId) async { # Family provider for peer
  final service = ref.watch(messagingServiceProvider);                 # Watch service
  return service.getConversation(peerId);                             # Get conversation
});
