import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class TypingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ⚠️ VERIFY: Is this URL exactly what is in your Firebase Console?
  final FirebaseDatabase _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://reddit-86621-default-rtdb.firebaseio.com',
  );

  Timer? _debounce;

  void onTextChanged(String chatId) {
    // 1. DEBUG: Check if the function is even running
    print("--------------------------------------------------");
    print("🔥 TYPING DETECTED!");
    print("📝 Chat ID: $chatId");

    final user = _auth.currentUser;
    if (user == null) {
      print("❌ ERROR: User is not logged in!");
      return;
    }
    print("👤 User ID: ${user.uid}");

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set TRUE
    _setTypingStatus(chatId, true);

    // Set FALSE after 2 seconds
    _debounce = Timer(const Duration(seconds: 2), () {
      print("🛑 Timer finished. Setting typing to FALSE.");
      _setTypingStatus(chatId, false);
    });
  }

  Future<void> _setTypingStatus(String chatId, bool isTyping) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final path = 'typing_status/$chatId/${user.uid}';
      print("📡 Attempting to write to: $path");
      print("💾 Value: ${isTyping ? true : null}");

      await _rtdb.ref(path).set(isTyping ? true : null);

      print("✅ SUCCESS: Data written to Firebase!");
    } catch (e) {
      print("❌ FIREBASE WRITE ERROR: $e");
    }
  }
}
