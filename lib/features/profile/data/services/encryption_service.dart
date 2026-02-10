import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _secretKey = 'h3hej3u29ml3igh4jm3.3jriuflwi4fj';

  /// SHA256(key) just like backend
  static encrypt.Key _getKey() {
    final keyBytes = utf8.encode(_secretKey);
    final hash = sha256.convert(keyBytes).bytes;
    return encrypt.Key(Uint8List.fromList(hash));
  }

  static Uint8List _randomBytes(int length) {
    final rand = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rand.nextInt(256)));
  }

  /// Encrypt: Base64(IV + CipherText)
  static String encryptData(String plainText) {
    final key = _getKey();
    final ivBytes = _randomBytes(16);
    final iv = encrypt.IV(ivBytes);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return base64Encode(combined);
  }

  /// Decrypt: Base64(IV + CipherText)
  static String decryptData(String encryptedText) {
    final key = _getKey();
    final raw = base64Decode(encryptedText);

    final iv = encrypt.IV(raw.sublist(0, 16));
    final cipherBytes = raw.sublist(16);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    return encrypter.decrypt(encrypt.Encrypted(cipherBytes), iv: iv);
  }
}
