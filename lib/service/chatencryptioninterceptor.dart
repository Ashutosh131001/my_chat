import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as pc;

class ChatEncryptionInterceptor {
  static const _storage = FlutterSecureStorage();
  static const String _privateKeyKey = 'mychat_private_key';

 
  static enc.Key generateChatRoomAESKey() {
    return enc.Key.fromSecureRandom(32); 
  }

  
  static String encryptMessage(String plainText, enc.Key aesKey) {
   
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return "${iv.base64}:${encrypted.base64}";
  }

  /// 3. Unscrambles the text message before showing it in the GetX UI
  static String decryptMessage(String encryptedPayload, enc.Key aesKey) {
    try {
      final parts = encryptedPayload.split(':');
      if (parts.length != 2) return "🔒 [Corrupted Message]";

      final iv = enc.IV.fromBase64(parts[0]);
      final encryptedText = enc.Encrypted.fromBase64(parts[1]);

      final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
      return encrypter.decrypt(encryptedText, iv: iv);
    } catch (e) {
      return "🔒 [Encrypted Message]";
    }
  }

  

 
  static String lockAESKeyWithRSA(enc.Key aesKey, String publicKeyPem) {
    var helper = RsaKeyHelper();
    final publicKey = helper.parsePublicKeyFromPem(publicKeyPem) as pc.RSAPublicKey;
    
    final encrypter = enc.Encrypter(enc.RSA(publicKey: publicKey));
    return encrypter.encrypt(aesKey.base64).base64;
  }

  
  static Future<enc.Key?> unlockAESKeyWithRSA(String encryptedAESKeyBase64) async {
    try {
      // Pull your private key out of the secure hardware vault
      final privateKeyPem = await _storage.read(key: _privateKeyKey);
      if (privateKeyPem == null) {
        print("Error: No Private Key found on this device.");
        return null;
      }

      var helper = RsaKeyHelper();
      final privateKey = helper.parsePrivateKeyFromPem(privateKeyPem) as pc.RSAPrivateKey;
      final encrypter = enc.Encrypter(enc.RSA(privateKey: privateKey));
      final decryptedAESBase64 = encrypter.decrypt(enc.Encrypted.fromBase64(encryptedAESKeyBase64));
      
      return enc.Key.fromBase64(decryptedAESBase64);
    } catch (e) {
      print("Failed to unlock AES Key: $e");
      return null;
    }
  }
}