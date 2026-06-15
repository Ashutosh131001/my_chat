import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat/service/securityServices.dart';
// import 'path/to/your/security_service.dart'; // Make sure to import the vault!

class EncryptionBootService {

  static Future<void> initializeEncryptionProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Boot: No user logged in. Skipping key generation.");
      return; 
    }

   
    final newPublicKey = await SecurityService.generateAndSaveKeys();

   
    if (newPublicKey != null) {
      print("Boot: Uploading new Public Key to Firebase...");
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'publicKey': newPublicKey,
          }, SetOptions(merge: true)); 
          
      print("Boot: Public Key successfully secured in the cloud!");
    } else {
      print("Boot: RSA Keys already exist on device. Ready to chat.");
    }
  }
}