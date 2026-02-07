import 'dart:typed_data';                                            // Binary data types

/// Crypto Port Interface - Abstracts encryption/decryption
abstract class ICryptoPort {                                          // Encryption interface
  Future<KeyPair> generateKeyPair();                                  // Generate new key pair
  Future<Uint8List> encrypt(String plaintext, String publicKey);      // Encrypt with public key
  Future<String> decrypt(Uint8List ciphertext, String privateKey);    // Decrypt with private key
  Future<String> sign(String data, String privateKey);                // Sign data
  Future<bool> verify(String data, String signature, String publicKey); // Verify signature
  Future<String> hash(String data);                                   // Create secure hash
}

class KeyPair {                                                       // Encryption keys
  final String publicKey;                                             // Public key (shareable)
  final String privateKey;                                            // Private key (secret)
  final DateTime createdAt;                                           // Creation timestamp

  KeyPair({                                                           // Constructor
    required this.publicKey,                                          // Required public
    required this.privateKey,                                         // Required private
    required this.createdAt,                                          // Required time
  });
}

class EncryptedData {                                                 // Encrypted payload
  final Uint8List ciphertext;                                         // Encrypted content
  final String nonce;                                                 // Unique nonce
  final String senderPublicKey;                                       // Sender's public key

  EncryptedData({                                                     // Constructor
    required this.ciphertext,                                         // Required encrypted data
    required this.nonce,                                              // Required nonce
    required this.senderPublicKey,                                    // Required sender key
  });
}
