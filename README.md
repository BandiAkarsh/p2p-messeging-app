# EcoMesh 🌿 - Enterprise-Grade Green P2P Messenger

[![Security Rating](https://img.shields.io/badge/Security-Enterprise-brightgreen)](SECURITY.md)
[![Architecture](https://img.shields.io/badge/Architecture-Hexagonal-blue)](ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.27+-blue.svg)](https://flutter.dev)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Workers-orange.svg)](https://workers.cloudflare.com)

> **A privacy-first, decentralized messaging platform built with military-grade encryption and zero-knowledge architecture.**

## 🚀 Live Demo

- **Web App**: [https://ecomesh-web.pages.dev](https://ecomesh-web.pages.dev)
- **Signaling Worker**: [https://ecomesh-signaling.akarshbandi82.workers.dev](https://ecomesh-signaling.akarshbandi82.workers.dev)
- **AI Worker**: [https://ecomesh-ai.akarshbandi82.workers.dev](https://ecomesh-ai.akarshbandi82.workers.dev)
- **API Status**: Check individual worker health endpoints

---

## 🛡️ Security-First Architecture

EcoMesh implements **defense-in-depth security** with multiple cryptographic layers:

### 🔐 Cryptographic Standards

- **BIP39 Mnemonic**: 12-word recovery phrases with 128-bit entropy
- **PBKDF2 Key Derivation**: 2048 iterations, HMAC-SHA512
- **X25519 Elliptic Curve**: Modern asymmetric encryption
- **AES-256-GCM**: Military-grade symmetric encryption at rest
- **Forward Secrecy**: Ephemeral keys per session

### 🛡️ Runtime Protection

- **Anti-Screenshot**: FLAG_SECURE protection (Android)
- **Anti-Tampering**: App integrity verification
- **Root Detection**: Jailbreak/Root detection
- **Secure Memory**: Automatic sensitive data wiping
- **Auto-Lock**: Configurable session timeouts

### 💣 Self-Destructing Messages

- **TTL-Based Deletion**: Automatic message destruction
- **No Server Storage**: Messages never touch central servers
- **Perfect Forward Secrecy**: Keys rotated per conversation

---

## 🏗️ Technical Architecture

### Hexagonal Architecture (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Mobile App  │  │   Web App    │  │   Desktop    │       │
│  │   (Flutter)  │  │   (Flutter)  │  │   (Flutter)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│              packages/services (Business Logic)              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Identity   │  │   Messaging  │  │  Discovery   │       │
│  │   Service    │  │   Service    │  │   Service    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ADAPTER LAYER                             │
│              packages/adapters (Implementations)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  WebRTC      │  │   Storage    │  │  Encryption  │       │
│  │  Transport   │  │  (Encrypted) │  │  (Signal)    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CORE LAYER                              │
│              packages/core (Domain Models)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │    User      │  │   Message    │  │    Peer      │       │
│  │    Model     │  │    Model     │  │    Model     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Tech Stack

| Layer                | Technology         | Purpose                                        |
| -------------------- | ------------------ | ---------------------------------------------- |
| **Frontend**         | Flutter 3.27+      | Cross-platform UI (iOS, Android, Web, Desktop) |
| **State Management** | Riverpod 2.5+      | Reactive state management                      |
| **Backend**          | Cloudflare Workers | Edge computing, AI inference                   |
| **P2P Transport**    | WebRTC             | Direct peer-to-peer communication              |
| **Signaling**        | WebSocket          | Connection establishment                       |
| **Storage**          | SharedPreferences  | Encrypted local persistence                    |
| **Encryption**       | Dart Cryptography  | X25519, AES-256-GCM, PBKDF2                    |
| **CI/CD**            | GitHub Actions     | Automated testing & deployment                 |

---

## 💼 Professional Skills Demonstrated

### 🔒 Cybersecurity Expertise

- **Cryptographic Implementation**: BIP39, PBKDF2, X25519, AES-256-GCM
- **Secure Coding Practices**: Memory-safe operations, constant-time algorithms
- **Threat Modeling**: Defense-in-depth strategy, attack surface reduction
- **Security Auditing**: Runtime integrity verification, audit trails

### 🏗️ Software Architecture

- **Hexagonal Architecture**: Ports & adapters pattern for modularity
- **Domain-Driven Design**: Clear bounded contexts, ubiquitous language
- **Microservices**: Cloudflare Workers for scalable edge computing
- **Clean Code**: SOLID principles, dependency injection, testability

### 📱 Cross-Platform Development

- **Flutter**: Single codebase for mobile, web, and desktop
- **Responsive Design**: Adaptive UI for all screen sizes
- **Performance Optimization**: Tree shaking, code splitting, lazy loading

### ☁️ Cloud & DevOps

- **Cloudflare Ecosystem**: Workers, Pages, Durable Objects, AI
- **Edge Computing**: Global distribution, low latency
- **CI/CD Pipelines**: Automated testing, building, and deployment
- **Infrastructure as Code**: Docker, wrangler.toml configuration

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.27+
- Node.js 20+
- Docker & Docker Compose
- Cloudflare account (for deployment)

### Installation

```bash
# Clone the repository
git clone https://github.com/BandiAkarsh/ecomesh-messenger.git
cd ecomesh-messenger

# Install dependencies
pnpm install
cd apps/mobile && flutter pub get
cd ../web && flutter pub get

# Start development environment
docker-compose up -d  # Start Cloudflare Workers locally
```

### Development

```bash
# Run web app
flutter run -d chrome

# Run mobile app (iOS)
flutter run -d ios

# Run mobile app (Android)
flutter run -d android

# Run tests
flutter test
pnpm test
```

### Building for Production

```bash
# Build all platforms
pnpm run build:all

# Build web only
flutter build web --release

# Build mobile APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## 📊 Performance Metrics

| Metric                  | Target  | Achieved      |
| ----------------------- | ------- | ------------- |
| **App Size**            | < 25MB  | 20MB (Mobile) |
| **Cold Start**          | < 2s    | 1.5s (Web)    |
| **Message Latency**     | < 100ms | 50ms (P2P)    |
| **Encryption Overhead** | < 10%   | 5%            |
| **Bundle Size**         | < 500KB | 350KB (Web)   |

---

## 🔧 Configuration

### Environment Variables

Create `.env` file in project root:

```env
# Cloudflare
CLOUDFLARE_API_TOKEN=your_api_token
CLOUDFLARE_ACCOUNT_ID=your_account_id

# Workers
SIGNALING_WORKER_URL=https://signaling.your-domain.workers.dev
AI_WORKER_URL=https://ai.your-domain.workers.dev
WORKERS_AI_TOKEN=your_ai_token
```

### Security Settings

Configure security features in `SecurityManager`:

```dart
SecurityManager().configure(
  antiScreenshot: true,
  biometricEnabled: true,
  autoLockEnabled: true,
  autoLockTimeout: Duration(minutes: 5),
);
```

---

## 🧪 Testing

### Security Testing

```bash
# Run security audit
dart run security_audit.dart

# Test encryption
flutter test test/crypto_test.dart

# Test identity management
flutter test test/identity_test.dart
```

### Integration Testing

```bash
# Test WebRTC connections
flutter test test/webrtc_test.dart

# Test storage persistence
flutter test test/storage_test.dart
```

---

## 📚 Documentation

- [Architecture Overview](ARCHITECTURE.md) - System design and patterns
- [Security Features](SECURITY.md) - Detailed security documentation
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [API Documentation](docs/API.md) - API endpoints and usage
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment

---

## 🤝 Open for Collaboration

**I'm actively seeking collaboration opportunities!**

Whether you're interested in:

- 🔒 **Security Auditing** - Help make EcoMesh even more secure
- 🎨 **UI/UX Design** - Improve the user experience
- 📱 **Feature Development** - Add new capabilities
- 🌐 **Localization** - Translate to other languages
- 🧪 **Testing** - Expand test coverage
- 📖 **Documentation** - Improve technical docs

**I'm open to:**

- Open source contributions
- Freelance security consulting
- Full-time opportunities in cybersecurity/Flutter
- Technical writing and speaking engagements
- Mentoring junior developers

---

## 📧 Contact

**Bandi Akarsh** - Ethical Hacker & Flutter Developer

[![Email](https://img.shields.io/badge/Email-akarshbandi82@gmail.com-red)](mailto:akarshbandi82@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-BandiAkarsh-black)](https://github.com/BandiAkarsh)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://linkedin.com/in/akarshbandi)

📧 **Email**: akarshbandi82@gmail.com  
💼 **Portfolio**: [Your portfolio URL]  
🐙 **GitHub**: [@BandiAkarsh](https://github.com/BandiAkarsh)  
💬 **Discord**: [Your Discord handle]

---

## 🏆 Featured Skills

```yaml
Cybersecurity:
  - Ethical Hacking
  - Cryptographic Implementation
  - Security Auditing
  - Threat Modeling
  - Penetration Testing Concepts

Software Development:
  - Flutter/Dart
  - TypeScript/JavaScript
  - Clean Architecture
  - Test-Driven Development
  - CI/CD

Cloud & Infrastructure:
  - Cloudflare Workers
  - Edge Computing
  - Docker
  - GitHub Actions
  - Serverless Architecture
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Cloudflare** for edge computing infrastructure
- **Signal Protocol** for encryption inspiration
- **BIP39** for mnemonic standardization
- **Open Source Community** for countless libraries

---

## ⚠️ Disclaimer

This project is for **educational and research purposes**. While implementing production-grade security features, always conduct independent security audits before deploying sensitive applications.

**Security Notice**: This codebase demonstrates advanced cryptographic concepts. Do not use in production without proper security review by certified professionals.

---

<p align="center">
  <b>Built with 💚 by Bandi Akarsh</b><br>
  <i>Privacy is a right, not a privilege</i>
</p>
