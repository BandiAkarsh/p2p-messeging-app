# Architecture Documentation 🏗️

## Overview

EcoMesh implements **Hexagonal Architecture** (Ports & Adapters pattern) with **Clean Architecture** principles. This document provides a comprehensive technical overview of the system design.

---

## 🎯 Architectural Goals

1. **Modularity**: Swappable components without affecting others
2. **Testability**: Easy to test with mock implementations
3. **Security**: Defense-in-depth with isolated security layers
4. **Scalability**: Edge computing for global distribution
5. **Maintainability**: Clear separation of concerns

---

## 🏛️ Architecture Patterns

### Hexagonal Architecture (Ports & Adapters)

```
┌────────────────────────────────────────────────────────────┐
│                      EXTERNAL WORLD                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Web    │  │  Mobile  │  │ Desktop  │  │  CLI     │   │
│  │   UI     │  │   App    │  │   App    │  │  Tool    │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼────────────┼────────────┼────────────┼───────────┘
        │            │            │            │
        └────────────┴────────────┴────────────┘
                     │
              ┌──────▼──────┐
              │   PORTS     │  ← Interfaces (Contracts)
              └──────┬──────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼─────┐ ┌────▼─────┐ ┌────▼─────┐
   │ ADAPTERS │ │ ADAPTERS │ │ ADAPTERS │
   │  WebRTC  │ │  Storage │ │   AI     │
   └──────────┘ └──────────┘ └──────────┘
        │            │            │
        └────────────┼────────────┘
                     │
              ┌──────▼──────┐
              │   DOMAIN    │  ← Business Logic
              └─────────────┘
```

### Clean Architecture Layers

```
Layer 4: Frameworks & Drivers
├─ Flutter UI
├─ WebRTC
├─ Cloudflare Workers
└─ External Libraries

Layer 3: Interface Adapters
├─ UI Widgets
├─ Controllers
├─ Presenters
└─ Gateways

Layer 2: Application Business Rules
├─ Use Cases
├─ Application Services
└─ DTOs

Layer 1: Enterprise Business Rules
├─ Entities
├─ Domain Services
└─ Value Objects
```

---

## 📁 Project Structure

```
ecomesh-messenger/
│
├── 📱 apps/                          # Applications
│   ├── mobile/                       # iOS/Android (Flutter)
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── screens/             # UI Screens
│   │   │   └── widgets/             # Reusable widgets
│   │   └── pubspec.yaml
│   │
│   └── web/                          # Web App (Flutter)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/
│       │   └── widgets/
│       └── pubspec.yaml
│
├── 📦 packages/                      # Shared packages
│   │
│   ├── core/                         # Domain Layer
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── models/          # Domain entities
│   │   │   │   │   ├── user.dart
│   │   │   │   │   ├── message.dart
│   │   │   │   │   └── peer.dart
│   │   │   │   │
│   │   │   │   └── ports/           # Interfaces (Ports)
│   │   │   │       ├── transport_port.dart
│   │   │   │       ├── storage_port.dart
│   │   │   │       ├── ai_port.dart
│   │   │   │       └── crypto_port.dart
│   │   │   │
│   │   │   └── ecomesh_core.dart    # Public API
│   │   └── pubspec.yaml
│   │
│   ├── adapters/                     # Adapter Layer
│   │   ├── lib/
│   │   │   ├── transport/           # Transport adapters
│   │   │   │   ├── webrtc_adapter.dart
│   │   │   │   └── mock_transport.dart
│   │   │   │
│   │   │   ├── storage/             # Storage adapters
│   │   │   │   ├── secure_storage_adapter.dart
│   │   │   │   └── memory_adapter.dart
│   │   │   │
│   │   │   ├── ai/                  # AI adapters
│   │   │   │   └── cloudflare_ai_adapter.dart
│   │   │   │
│   │   │   ├── crypto/              # Crypto adapters
│   │   │   │   └── signal_crypto_adapter.dart
│   │   │   │
│   │   │   └── ecomesh_adapters.dart
│   │   └── pubspec.yaml
│   │
│   └── services/                     # Application Layer
│       ├── lib/
│       │   ├── messaging_service.dart
│       │   ├── identity_service.dart
│       │   ├── discovery_service.dart
│       │   ├── contact_service.dart
│       │   ├── ai_service.dart
│       │   ├── security_manager.dart
│       │   └── providers.dart       # Riverpod providers
│       └── pubspec.yaml
│
├── ⚡ workers/                        # Edge Functions
│   ├── signaling/                    # WebRTC Signaling
│   │   ├── src/
│   │   │   ├── index.ts             # Main worker
│   │   │   └── room.ts              # Durable Object
│   │   ├── wrangler.toml
│   │   └── package.json
│   │
│   └── ai-worker/                    # AI Inference
│       ├── src/
│       │   └── index.ts
│       ├── wrangler.toml
│       └── package.json
│
├── 🐳 docker-compose.yml             # Local development
├── 📋 README.md                      # Main documentation
├── 🔒 SECURITY.md                    # Security docs
├── 🤝 CONTRIBUTING.md                # Contribution guide
└── 🏗️ ARCHITECTURE.md               # This file
```

---

## 🔄 Data Flow

### 1. Message Sending Flow

```
User Input
    ↓
ChatScreen (UI Layer)
    ↓
MessagingService (Application Layer)
    ↓
CryptoAdapter (Encrypt)
    ↓
TransportAdapter (WebRTC)
    ↓
Signaling Worker (WebSocket)
    ↓
Peer Device
```

### 2. Identity Creation Flow

```
User Action
    ↓
CreateAccountScreen
    ↓
IdentityService.generateIdentity()
    ├─ Generate X25519 key pair
    ├─ Create BIP39 mnemonic
    ├─ Derive user ID
    └─ Secure memory operations
    ↓
SecureStorageAdapter.save()
    ├─ AES-256-GCM encryption
    ├─ SharedPreferences persistence
    └─ Key derivation
    ↓
UserNotifier.update()
    ↓
UI Updates
```

### 3. Message Receiving Flow

```
Incoming WebRTC Data
    ↓
WebRTCAdapter.onMessage()
    ↓
CryptoAdapter.decrypt()
    ├─ X25519 ECDH
    ├─ AES-GCM decryption
    └─ Integrity verification
    ↓
MessagingService.receive()
    ├─ Validate sender
    ├─ Decrypt content
    └─ Store locally
    ↓
Riverpod State Update
    ↓
UI Rebuilds
```

---

## 🧩 Component Details

### Core Package (Domain Layer)

**Purpose**: Define business entities and contracts

**Key Components**:

```dart
// models/user.dart - User entity
@freezed
class User with _$User {
  const factory User({
    required String id,              // Unique identifier
    required String username,        // Handle
    required String publicKey,       // X25519 public key
    required DateTime createdAt,     // Account creation
  }) = _User;
}

// ports/transport_port.dart - Transport contract
abstract class ITransportPort {
  Future<void> connect(String peerId);
  Future<void> send(EncryptedMessage message);
  void onMessage(Function(EncryptedMessage) callback);
  Future<void> disconnect();
}
```

**Principles**:

- No external dependencies
- Pure Dart code
- Immutable entities
- Interface segregation

### Adapters Package (Adapter Layer)

**Purpose**: Implement domain interfaces with external technologies

**WebRTC Adapter**:

```dart
class WebRTCAdapter implements ITransportPort {
  final RTCPeerConnection _connection;
  final String _signalingUrl;

  @override
  Future<void> connect(String peerId) async {
    // 1. Connect to signaling server
    // 2. Exchange ICE candidates
    // 3. Establish peer connection
    // 4. Open data channel
  }

  @override
  Future<void> send(EncryptedMessage message) async {
    // Send via RTCDataChannel
  }
}
```

**Secure Storage Adapter**:

```dart
class SecureStorageAdapter implements IStoragePort {
  @override
  Future<void> save(String key, dynamic data) async {
    // 1. Serialize to JSON
    // 2. Encrypt with AES-256-GCM
    // 3. Store in SharedPreferences
  }
}
```

### Services Package (Application Layer)

**Purpose**: Orchestrate use cases and business logic

**Identity Service**:

```dart
class IdentityService {
  Future<Map<String, String>> generateIdentity() async {
    // 1. Generate cryptographically secure random
    // 2. Create X25519 key pair
    // 3. Generate BIP39 mnemonic
    // 4. Derive user ID
    // 5. Secure memory operations
  }
}
```

**Security Manager**:

```dart
class SecurityManager {
  // Self-destructing messages
  void registerSelfDestruct(String id, Duration ttl);

  // Forward secrecy
  Future<EphemeralKeyPair> generateEphemeralKeys();

  // Runtime protection
  bool verifyAppIntegrity();
}
```

---

## 🔐 Security Architecture

### Encryption Layers

```
Layer 1: Application
├─ Message content (plaintext)
└─ User actions

Layer 2: Transport Encryption
├─ WebRTC DTLS 1.2
├─ AES-128-GCM
└─ Perfect Forward Secrecy

Layer 3: Application Encryption
├─ X25519 ECDH
├─ AES-256-GCM
└─ E2E Encryption

Layer 4: Storage Encryption
├─ AES-256-GCM at rest
├─ Master key derivation
└─ Secure enclave (mobile)
```

### Key Management

```
Master Key (Derived from device entropy)
    ↓
├─ Storage Encryption Key
│   └─ Encrypts all stored data
│
├─ Identity Private Key
│   └─ X25519 key for signing
│
└─ Session Keys
    └─ Ephemeral per conversation
```

---

## ☁️ Cloudflare Workers Architecture

### Signaling Worker

**Purpose**: WebRTC connection establishment

**Components**:

```typescript
// Durable Object for room management
export class SignalingRoom {
  async fetch(request: Request) {
    // Handle WebSocket upgrade
    // Manage peer connections
    // Relay ICE candidates
  }
}

// Main worker entry
export default {
  async fetch(request: Request, env: Env) {
    // Route to appropriate room
    // Authenticate requests
    // Handle CORS
  },
};
```

**Scaling**:

- Durable Objects maintain state
- WebSocket connections per room
- Automatic global distribution

### AI Worker

**Purpose**: AI-powered features

**Features**:

- Smart reply generation
- Message translation
- Sentiment analysis
- Language detection

**Integration**:

```typescript
const response = await env.AI.run(
  '@cf/meta/llama-3.1-8b-instruct',
  { messages: [...] }
);
```

---

## 🔄 State Management

### Riverpod Architecture

```dart
// Providers
final transportProvider = Provider<ITransportPort>((ref) =>
  WebRTCAdapter(signalingUrl: '...')
);

final storageProvider = Provider<IStoragePort>((ref) =>
  SecureStorageAdapter()
);

final messagingServiceProvider = Provider<MessagingService>((ref) =>
  MessagingService(
    transport: ref.watch(transportProvider),
    storage: ref.watch(storageProvider),
  )
);

// StateNotifier for auth
final currentUserProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.watch(storageProvider));
});
```

**Benefits**:

- Compile-time safety
- Automatic dependency injection
- Testable with mocks
- Scoped state management

---

## 🧪 Testing Architecture

### Test Pyramid

```
Integration Tests (10%)
├─ End-to-end flows
├─ WebRTC connections
└─ Cloudflare Workers

Service Tests (30%)
├─ Business logic
├─ Use cases
└─ Service orchestration

Unit Tests (60%)
├─ Domain models
├─ Adapters
└─ Utilities
```

### Mock Implementations

```dart
// Mock transport for testing
class MockTransportAdapter implements ITransportPort {
  final List<EncryptedMessage> sentMessages = [];

  @override
  Future<void> send(EncryptedMessage message) async {
    sentMessages.add(message);
  }
}
```

---

## 📊 Performance Considerations

### Optimizations

1. **Bundle Size**

   - Tree shaking enabled
   - Deferred loading
   - Asset optimization
   - Target: < 500KB web, < 25MB mobile

2. **Memory Usage**

   - Secure wiping of keys
   - Lazy loading of conversations
   - Image caching strategy

3. **Network**

   - WebRTC P2P (direct connection)
   - Signaling only for setup
   - Minimal server dependency

4. **Computation**
   - Async encryption operations
   - Worker threads for crypto
   - UI isolation

---

## 🚀 Deployment Architecture

### CI/CD Pipeline

```
GitHub Push
    ↓
GitHub Actions
    ├─ Run tests
    ├─ Build Flutter apps
    ├─ Deploy Workers
    └─ Deploy to Pages
    ↓
Production
```

### Environments

```
Development
├─ Local Docker Compose
├─ Hot reload
└─ Debug builds

Staging
├─ Cloudflare Pages (preview)
├─ Test Workers
└─ Integration tests

Production
├─ Cloudflare Pages (main)
├─ Production Workers
└─ Monitoring
```

---

## 📝 Design Decisions

### Why Hexagonal Architecture?

**Pros**:

- ✅ Testability with mocks
- ✅ Swappable implementations
- ✅ Clear separation of concerns
- ✅ Technology agnostic domain

**Cons**:

- ❌ Initial complexity
- ❌ More boilerplate code

**Verdict**: Worth it for security-critical application

### Why Flutter?

**Pros**:

- ✅ Single codebase for all platforms
- ✅ Native performance
- ✅ Rich UI capabilities
- ✅ Strong typing (Dart)

**Cons**:

- ❌ Web limitations
- ❌ Larger bundle size

**Verdict**: Best choice for cross-platform P2P app

### Why Cloudflare Workers?

**Pros**:

- ✅ Edge computing (global distribution)
- ✅ Generous free tier
- ✅ Durable Objects for state
- ✅ AI inference at edge

**Cons**:

- ❌ Vendor lock-in
- ❌ Limited runtime

**Verdict**: Excellent for P2P signaling server

---

## 🔮 Future Architecture

### Planned Enhancements

1. **Federated Identity**

   - Multiple identity providers
   - Cross-platform sync

2. **Group Chat**

   - Multi-party WebRTC
   - Group key management

3. **File Sharing**

   - P2P file transfer
   - Streaming support

4. **Offline Sync**

   - CRDT data structures
   - Conflict resolution

5. **Voice/Video**
   - WebRTC media streams
   - End-to-end encrypted calls

---

## 📚 References

- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BIP39 Standard](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Last Updated**: 2026-02-07  
**Version**: 1.0  
**Author**: Bandi Akarsh  
**Contact**: akarshbandi82@gmail.com
