import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/api.dart' as pc;
import 'package:rsa_encrypt/rsa_encrypt.dart';

class SecurityService {
 
  static const _storage = FlutterSecureStorage();
  
  
  static const String _privateKeyKey = 'mychat_private_key';

  
  static Future<String?> generateAndSaveKeys() async {
    try {
     
      final existingKey = await _storage.read(key: _privateKeyKey);
      if (existingKey != null) {
        print("Secure Lock: Keys already exist on this device.");
        return null; 
      }

      print("Secure Lock: Generating new RSA Key Pair...");
      
    
      var helper = RsaKeyHelper();
      final keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());

      
      final privateKeyString = helper.encodePrivateKeyToPemPKCS1(keyPair.privateKey as pc.RSAPrivateKey);
      final publicKeyString = helper.encodePublicKeyToPemPKCS1(keyPair.publicKey as pc.RSAPublicKey);

     
      await _storage.write(key: _privateKeyKey, value: privateKeyString);
      print("Secure Lock: Private Key saved to device hardware.");

     
      return publicKeyString;

    } catch (e) {
      print("Encryption Error: Failed to generate keys: $e");
      return null;
    }
  }
}