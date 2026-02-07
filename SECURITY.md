# Security Documentation 🔒

## Overview

EcoMesh implements **military-grade security** with a defense-in-depth strategy. This document details the security features, cryptographic implementations, and best practices used throughout the application.

---

## 🛡️ Security Architecture

### Defense-in-Depth Strategy

EcoMesh employs multiple layers of security:

1. **Cryptographic Layer** - Encryption at rest and in transit
2. **Transport Layer** - P2P WebRTC with DTLS
3. **Application Layer** - Secure coding practices, input validation
4. **Runtime Layer** - Anti-tampering, anti-debugging
5. **Memory Layer** - Secure wiping, constant-time operations

---

## 🔐 Cryptographic Implementation

### BIP39 Mnemonic Standard

**Purpose**: Human-readable backup phrases for key recovery

**Implementation**:

```dart
- Word List: 2048 BIP39 standard words
- Entropy: 128 bits (12 words)
- Checksum: CRC8 (4 bits)
- Language: English
```

**Security Features**:

- ✅ Cryptographically secure random generation
- ✅ Checksum validation prevents typos
- ✅ Deterministic key derivation
- ✅ Standard wallet compatibility

### PBKDF2 Key Derivation

**Purpose**: Convert mnemonic to cryptographic keys

**Parameters**:

```yaml
Algorithm: PBKDF2-HMAC-SHA512
Iterations: 2048 (BIP39 standard)
Salt: "mnemonic"
Output: 64 bytes (512 bits)
```

**Why These Parameters**:

- 2048 iterations: Balance between security and performance
- SHA-512: Quantum-resistant hash function
- 64-byte output: Supports multiple key types

### X25519 Elliptic Curve Cryptography

**Purpose**: Asymmetric encryption for key exchange

**Advantages**:

- ✅ 128-bit security level
- ✅ Fast computation
- ✅ Small key size (32 bytes)
- ✅ Side-channel resistant
- ✅ Forward secrecy ready

### AES-256-GCM Encryption

**Purpose**: Symmetric encryption for data at rest

**Implementation**:

```dart
Key Size: 256 bits
Mode: GCM (Galois/Counter Mode)
Nonce: 96 bits (12 bytes)
Tag: 128 bits (16 bytes)
```

**Why GCM**:

- ✅ Authenticated encryption (confidentiality + integrity)
- ✅ Parallelizable for performance
- ✅ No padding required
- ✅ Widely adopted standard

---

## 🛡️ Runtime Security

### Anti-Screenshot Protection

**Implementation**:

```dart
// Android
Window.setFlags(FLAG_SECURE)

// iOS
UIApplication.shared.isIdleTimerDisabled

// Web
CSS: user-select: none
JavaScript: Prevent PrintScreen
```

**Effectiveness**:

- Blocks screenshot apps on Android
- Prevents screen recording
- Hides content in recent apps

### Anti-Tampering

**Checks**:

1. **Root/Jailbreak Detection**

   - Checks for rooted device indicators
   - Verifies system integrity
   - Detects debugging tools

2. **Debugger Detection**

   - Detects attached debuggers
   - Checks for tracer flags
   - Prevents memory dumping

3. **Emulator Detection**
   - Identifies simulator environments
   - Checks hardware fingerprints
   - Validates sensor data

### Secure Memory Management

**Techniques**:

```dart
// Overwrite sensitive data
void secureWipe(List<int> data) {
  // Pass 1: Random data
  for (int i = 0; i < data.length; i++) {
    data[i] = random.nextInt(256);
  }
  // Pass 2: Zeros
  for (int i = 0; i < data.length; i++) {
    data[i] = 0;
  }
}
```

**Applied To**:

- Private keys after use
- Mnemonic phrases in memory
- Encryption keys
- Session tokens

---

## 💣 Self-Destructing Messages

### Implementation

```dart
class SelfDestructManager {
  final Map<String, DateTime> _expiryMap = {};

  void register(String messageId, Duration ttl) {
    _expiryMap[messageId] = DateTime.now().add(ttl);
  }

  bool shouldDestroy(String messageId) {
    final expiry = _expiryMap[messageId];
    return expiry != null && DateTime.now().isAfter(expiry);
  }
}
```

### Features

- **TTL-Based**: Time-to-live duration (e.g., 5 minutes, 24 hours)
- **Automatic Cleanup**: 30-second interval cleanup
- **No Recovery**: Permanently deleted, no backups
- **No Notification**: Silent destruction

---

## 🔑 Forward Secrecy

### Concept

Even if long-term keys are compromised, past conversations remain secure because ephemeral keys are used for each session.

### Implementation

```dart
class EphemeralKeyPair {
  final List<int> publicKey;
  final List<int> privateKey;
  final DateTime createdAt;

  // Keys rotated every message or session
  // Old keys wiped from memory
}
```

### Key Lifecycle

1. **Generation**: New keys for each conversation
2. **Exchange**: X25519 ECDH key exchange
3. **Usage**: Derive shared secret
4. **Rotation**: New keys every N messages
5. **Destruction**: Secure wipe after use

---

## 🛡️ Security Audit

### Automated Security Checks

```dart
Map<String, dynamic> securityAudit = {
  'encryptionAtRest': true,        // AES-256-GCM
  'encryptionInTransit': true,     // WebRTC DTLS
  'forwardSecrecy': true,          // Ephemeral keys
  'secureMemoryWiping': true,      // _secureWipe()
  'antiScreenshot': true,          // FLAG_SECURE
  'rootDetection': true,           // Root checks
  'checksumValidation': true,      // BIP39 CRC8
  'pbkdf2Iterations': 2048,        // BIP39 standard
  'aesKeySize': 256,               // AES-256
};
```

### Security Report Generation

Run security audit:

```bash
flutter test test/security_audit_test.dart
```

---

## 🔍 Threat Model

### Threats Mitigated

| Threat                | Mitigation                        | Status       |
| --------------------- | --------------------------------- | ------------ |
| **Eavesdropping**     | End-to-end encryption             | ✅ Mitigated |
| **Man-in-the-Middle** | WebRTC DTLS + certificate pinning | ✅ Mitigated |
| **Data Breach**       | AES-256-GCM at rest               | ✅ Mitigated |
| **Key Theft**         | Secure memory wiping              | ✅ Mitigated |
| **Screenshots**       | FLAG_SECURE protection            | ✅ Mitigated |
| **Memory Dumps**      | Automatic key wiping              | ✅ Mitigated |
| **Forensic Recovery** | Self-destructing messages         | ✅ Mitigated |
| **Rooted Devices**    | Root detection                    | ✅ Mitigated |

### Attack Surface

**Minimal Attack Surface**:

- No central server storing messages
- No cloud backups (unless user opts in)
- No third-party analytics
- Open source (auditable)

---

## 🧪 Security Testing

### Test Coverage

```bash
# Run all security tests
flutter test test/security/

# Specific test suites
flutter test test/crypto_test.dart
flutter test test/identity_test.dart
flutter test test/storage_test.dart
flutter test test/encryption_test.dart
```

### Penetration Testing Checklist

- [ ] Cryptographic key extraction
- [ ] Memory dump analysis
- [ ] Network traffic interception
- [ ] Storage file inspection
- [ ] Reverse engineering resistance
- [ ] Input validation bypass
- [ ] Session fixation attempts
- [ ] Replay attack prevention

---

## 📋 Security Best Practices

### For Developers

1. **Never hardcode keys**
2. **Validate all inputs**
3. **Use constant-time operations**
4. **Implement proper error handling**
5. **Log security events**
6. **Regular dependency updates**

### For Users

1. **Write down mnemonic safely**
2. **Enable biometric lock**
3. **Set short auto-lock timeout**
4. **Verify contact identities**
5. **Use self-destruct for sensitive messages**
6. **Keep app updated**

---

## 🔐 Compliance

### Standards Followed

- **BIP39**: Mnemonic phrase standard
- **BIP44**: Multi-account hierarchy
- **OWASP MASVS**: Mobile app security
- **NIST Guidelines**: Cryptographic standards

### Privacy Regulations

- **GDPR Compliant**: No personal data collection
- **CCPA Ready**: User data control
- **Privacy by Design**: Data minimization

---

## 🚨 Vulnerability Disclosure

**If you discover a security vulnerability, please:**

1. **DO NOT** open a public issue
2. Email: **akarshbandi82@gmail.com**
3. Include detailed description and PoC
4. Allow 90 days for remediation
5. Responsible disclosure appreciated

---

## 📚 References

- [BIP39 Specification](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- [X25519 Standard](https://datatracker.ietf.org/doc/html/rfc7748)
- [AES-GCM Mode](https://csrc.nist.gov/publications/detail/sp/800-38d/final)
- [OWASP MASVS](https://owasp.org/www-project-mobile-security-testing-guide/)

---

**Last Updated**: 2026-02-07  
**Version**: 1.0  
**Author**: Bandi Akarsh  
**Contact**: akarshbandi82@gmail.com
