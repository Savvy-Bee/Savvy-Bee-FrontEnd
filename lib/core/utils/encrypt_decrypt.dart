import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A custom encryption service using AES-256-CBC with PKCS7 padding
class EncryptionService {
  // Get encryption key from environment
  static String? get _encryptionKey => dotenv.env['Encryption_Key'];

  /// Encrypts plain text and returns base64 encoded string with IV prepended
  /// Format: [IV:16bytes][CipherText]
  static Future<String?> encryptText(String plainText) async {
    try {
      final key = _encryptionKey;
      if (key == null || key.isEmpty) {
        throw Exception('Encryption key not found in environment');
      }

      // Generate a secure 32-byte key from the environment key
      final keyBytes = _deriveKey(key);
      final encryptKey = encrypt.Key(keyBytes);

      // Generate random 16-byte IV
      final iv = _generateIV();
      final encryptIV = encrypt.IV(iv);

      // Create encrypter with AES CBC mode
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptKey, mode: encrypt.AESMode.cbc),
      );

      // Encrypt the plain text
      final encrypted = encrypter.encrypt(plainText, iv: encryptIV);

      // Combine IV + encrypted data and encode as base64
      final combined = Uint8List.fromList([...iv, ...encrypted.bytes]);
      return base64Encode(combined);
    } catch (e) {
      print('Encryption error: $e');
      return null;
    }
  }

  /// Decrypts base64 encoded cipher text (with IV prepended)
  static Future<String?> decryptText(String cipherText) async {
    try {
      final key = _encryptionKey;
      if (key == null || key.isEmpty) {
        throw Exception('Encryption key not found in environment');
      }

      // Decode base64
      final combined = base64Decode(cipherText);

      // Extract IV (first 16 bytes) and cipher text (rest)
      if (combined.length < 17) {
        throw Exception('Invalid cipher text: too short');
      }

      final iv = combined.sublist(0, 16);
      final encryptedBytes = combined.sublist(16);

      // Generate key
      final keyBytes = _deriveKey(key);
      final encryptKey = encrypt.Key(keyBytes);
      final encryptIV = encrypt.IV(Uint8List.fromList(iv));

      // Create encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptKey, mode: encrypt.AESMode.cbc),
      );

      // Decrypt
      final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));
      return encrypter.decrypt(encrypted, iv: encryptIV);
    } catch (e) {
      print('Decryption error: $e');
      return null;
    }
  }

  /// Generate a secure random 16-byte IV
  static Uint8List _generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  /// Derive a 32-byte key from the environment key using SHA-256
  static Uint8List _deriveKey(String key) {
    // If key is already 32 bytes (64 hex chars), decode it
    if (key.length == 64 && _isHex(key)) {
      return Uint8List.fromList(
        List.generate(
          32,
          (i) => int.parse(key.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );
    }

    // Otherwise, hash it to get 32 bytes
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  /// Check if string is valid hex
  static bool _isHex(String str) {
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(str);
  }
}
