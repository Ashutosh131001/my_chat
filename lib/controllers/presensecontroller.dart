import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PresenceController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://reddit-86621-default-rtdb.firebaseio.com/',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _configurePresence();
  }

  void _configurePresence() {
    // 1. Listen to the device's connection state
    _rtdb.ref('.info/connected').onValue.listen((event) async {
      final isConnected = event.snapshot.value == true;
      final user = _auth.currentUser;

      if (user != null && isConnected) {
        // Defines where we store this user's status
        final userStatusRef = _rtdb.ref('/status/${user.uid}');

        // 2. PREPARE the "Offline" message for the server to send LATER
        // This runs on the server if the connection is lost/killed.
        await userStatusRef.onDisconnect().update({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
        });

        // 3. SET the "Online" status NOW
        await userStatusRef.update({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
        });

        // (Optional) Sync to Firestore for general records
        _firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  // Call this manually if you want to set offline on explicit logout
  Future<void> setOffline() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _rtdb.ref('/status/${user.uid}').update({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
