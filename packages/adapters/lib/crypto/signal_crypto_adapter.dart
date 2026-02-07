import 'dart:typed_data';
import 'package:ecomesh_core/ecomesh_core.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

/// Signal Protocol Crypto Adapter - E2E encryption using Signal Protocol
class SignalCryptoAdapter implements ICryptoPort {
  final Map<String, SessionCipher> _sessionCiphers = {};
  final Map<String, SignalProtocolAddress> _addresses = {};
  InMemorySignalProtocolStore? _store;
  IdentityKeyPair? _identityKeyPair;
  int _registrationId = 0;

  @override
  Future<KeyPair> generateKeyPair() async {
    // Generate Signal Protocol identity key pair
    final identityKeyPair = await KeyHelper.generateIdentityKeyPair();
    final registrationId = KeyHelper.generateRegistrationId(false);
    
    _identityKeyPair = identityKeyPair;
    _registrationId = registrationId;
    
    // Initialize store
    _store = InMemorySignalProtocolStore(identityKeyPair, registrationId);
    
    // Get public key as base64
    final publicKey = identityKeyPair.getPublicKey().serialize();
    final privateKey = identityKeyPair.getPrivateKey().serialize();
    
    return KeyPair(
      publicKey: base64Encode(publicKey),
      privateKey: base64Encode(privateKey),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Uint8List> encrypt(String plaintext, String publicKey) async {
    if (_store == null) {
      throw StateError('Crypto adapter not initialized. Call generateKeyPair() first.');
    }

    final remotePublicKey = base64Decode(publicKey);
    final address = SignalProtocolAddress(publicKey, 0);
    _addresses[publicKey] = address;

    // Create session builder
    final sessionBuilder = SessionBuilder(_store!, _store!, _store!, _store!, address);
    
    // Process prekey bundle (simplified - in real use, get from server)
    // This is a simplified implementation
    final remoteIdentityKey = IdentityKey.fromBytes(remotePublicKey, 0);
    final preKey = await KeyHelper.generatePreKeys(0, 1);
    final signedPreKey = await KeyHelper.generateSignedPreKey(_identityKeyPair!, 0);
    
    final bundle = PreKeyBundle(
      _registrationId,
      address.getDeviceId(),
      preKey.first.id,
      preKey.first.getKeyPair().publicKey,
      signedPreKey.id,
      signedPreKey.getKeyPair().publicKey,
      signedPreKey.signature,
      remoteIdentityKey,
    );

    await sessionBuilder.processPreKeyBundle(bundle);

    // Encrypt message
    final sessionCipher = SessionCipher(_store!, _store!, _store!, _store!, address);
    _sessionCiphers[publicKey] = sessionCipher;

    final ciphertext = await sessionCipher.encrypt(Uint8List.fromList(plaintext.codeUnits));
    
    // Return serialized ciphertext
    if (ciphertext is PreKeySignalMessage) {
      return ciphertext.serialize();
    } else {
      return ciphertext.serialize();
    }
  }

  @override
  Future<String> decrypt(Uint8List ciphertext, String privateKey) async {
    if (_store == null) {
      throw StateError('Crypto adapter not initialized');
    }

    // Find session cipher for this sender
    // In real implementation, we'd identify sender from ciphertext
    final sessionCipher = _sessionCiphers.values.first;
    
    try {
      final plaintext = await sessionCipher.decrypt(PreKeySignalMessage(ciphertext));
      return String.fromCharCodes(plaintext);
    } catch (e) {
      // Try decrypting as SignalMessage
      try {
        final plaintext = await sessionCipher.decryptFromSignalMessage(SignalMessage(ciphertext));
        return String.fromCharCodes(plaintext);
      } catch (e2) {
        throw Exception('Failed to decrypt: $e2');
      }
    }
  }

  @override
  Future<String> sign(String data, String privateKey) async {
    // Signal Protocol uses ed25519 for signatures
    final algorithm = crypto.Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(
      base64Decode(privateKey).sublist(0, 32),
    );
    
    final signature = await algorithm.sign(
      Uint8List.fromList(data.codeUnits),
      keyPair: keyPair,
    );
    
    return base64Encode(signature.bytes);
  }

  @override
  Future<bool> verify(String data, String signature, String publicKey) async {
    try {
      final algorithm = crypto.Ed25519();
      final publicKeyBytes = base64Decode(publicKey);
      
      final verified = await algorithm.verify(
        Uint8List.fromList(data.codeUnits),
        signature: crypto.Signature(
          base64Decode(signature),
          publicKey: await algorithm.newKeyPairFromSeed(publicKeyBytes.sublist(0, 32)).then((kp) => kp.extractPublicKey()),
        ),
      );
      
      return verified;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> hash(String data) async {
    final algorithm = crypto.Blake2b();
    final hash = await algorithm.hash(Uint8List.fromList(data.codeUnits));
    return base64Encode(hash.bytes);
  }

  // Helper to convert bytes to base64
  String base64Encode(List<int> bytes) {
    return const crypto.Base64Codec().encode(bytes);
  }

  List<int> base64Decode(String base64) {
    return const crypto.Base64Codec().decode(base64);
  }
}
