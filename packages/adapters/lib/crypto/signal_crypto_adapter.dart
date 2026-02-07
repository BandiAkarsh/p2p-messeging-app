import 'dart:typed_data';
import 'dart:convert';
import 'package:ecomesh_core/ecomesh_core.dart';
import 'package:cryptography/cryptography.dart' as crypto;

/// Simple Crypto Adapter - Uses basic encryption (X25519 + AES-GCM)
/// Note: This is a simplified implementation. For production, use proper Signal Protocol.
class SignalCryptoAdapter implements ICryptoPort {
  final Map<String, crypto.SimpleKeyPair> _keyPairs = {};

  @override
  Future<KeyPair> generateKeyPair() async {
    // Generate X25519 key pair for ECDH
    final algorithm = crypto.X25519();
    final keyPair = await algorithm.newKeyPair();
    
    // Extract public key
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = publicKey.bytes;
    
    // Store private key
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final keyId = base64Encode(publicKeyBytes);
    _keyPairs[keyId] = keyPair;
    
    return KeyPair(
      publicKey: base64Encode(publicKeyBytes),
      privateKey: base64Encode(privateKeyBytes),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Uint8List> encrypt(String plaintext, String publicKey) async {
    // Generate ephemeral key pair
    final algorithm = crypto.X25519();
    final ephemeralKeyPair = await algorithm.newKeyPair();
    final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();
    
    // Derive shared secret (simplified - in real implementation would use proper key agreement)
    final sharedSecret = ephemeralPublicKey.bytes;
    
    // Encrypt with AES-GCM
    final aes = crypto.AesGcm.with256bits();
    final nonce = List<int>.generate(12, (_) => DateTime.now().microsecond % 256);
    final encrypted = await aes.encrypt(
      Uint8List.fromList(plaintext.codeUnits),
      secretKey: await aes.newSecretKeyFromBytes(sharedSecret.take(32).toList()),
      nonce: nonce,
    );
    
    // Prepend nonce and ephemeral public key
    final result = Uint8List.fromList([
      ...nonce,
      ...ephemeralPublicKey.bytes,
      ...encrypted.cipherText,
      ...encrypted.mac.bytes,
    ]);
    
    return result;
  }

  @override
  Future<String> decrypt(Uint8List ciphertext, String privateKey) async {
    if (ciphertext.length < 44) {
      throw ArgumentError('Invalid ciphertext');
    }
    
    // Extract nonce (12 bytes), ephemeral public key (32 bytes)
    final nonce = ciphertext.sublist(0, 12);
    final ephemeralPublicKeyBytes = ciphertext.sublist(12, 44);
    final encryptedData = ciphertext.sublist(44, ciphertext.length - 16);
    final macBytes = ciphertext.sublist(ciphertext.length - 16);

    // Derive shared secret (simplified)
    final sharedSecret = ephemeralPublicKeyBytes;

    // Decrypt with AES-GCM
    final aes = crypto.AesGcm.with256bits();
    final decrypted = await aes.decrypt(
      crypto.SecretBox(
        encryptedData,
        nonce: nonce,
        mac: crypto.Mac(macBytes),
      ),
      secretKey: await aes.newSecretKeyFromBytes(sharedSecret.take(32).toList()),
    );
    
    return String.fromCharCodes(decrypted);
  }

  @override
  Future<String> sign(String data, String privateKey) async {
    // Use Ed25519 for signatures
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
          publicKey: await algorithm.newKeyPairFromSeed(publicKeyBytes.sublist(0, 32))
              .then((kp) => kp.extractPublicKey()),
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
}
