import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_chat/chatpage/messagemodel.dart';

class Staredmessageveiwmodel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isloading = false.obs;

  /// ⭐ STAR A MESSAGE
 Future<void> starMessageById({
  required String chatId,
  required String messageId,
}) async {
  final user = _auth.currentUser;
  if (user == null) return;

  try {
    isloading.value = true;

    // 1️⃣ Fetch message
    final doc = await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (!doc.exists) return;

    final message = MessageModel.fromMap(doc.data()!);

    // 2️⃣ Mark message as starred in chat
    await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'starredBy': FieldValue.arrayUnion([user.uid]),
    });

    // 3️⃣ Save snapshot in starredmessages
    await _firestore
        .collection('staredmessages')
        .doc('${user.uid}_${message.messageId}')
        .set({
      ...message.toMap(),
      'starredBy': user.uid,
      'starredAt': DateTime.now().millisecondsSinceEpoch,
    });
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isloading.value = false;
  }
}

  /// ⭐ STREAM STARRED MESSAGES (ONLY CURRENT USER)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamStarredMessages() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('staredmessages')
        .where('starredBy', isEqualTo: user.uid)
        .orderBy('starredAt', descending: true)
        .snapshots();
  }
}