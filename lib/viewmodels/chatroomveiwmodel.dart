import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';

class ChatRoomVeiwModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isSending = false.obs;

  Future<String> getorcreatechatroom(String otheruserid) async {
    final currentuser = _auth.currentUser;
    if (currentuser == null) {
      Get.snackbar('Oops', 'UserNotLoggedin');
    }
    final List<String> participants = [?currentuser?.uid, otheruserid]..sort();
    final String chatid = participants.join('_');

    final chatroomref = _firestore.collection('chatrooms').doc(chatid);
    final doc = await chatroomref.get();
    if (!doc.exists) {
      final chatroom = ChatRoomModel(
        chatId: chatid,
        participants: participants,
        lastMessage: null,
        lastMessageTime: null,
        clearedBy: {}
      );

      await chatroomref.set(chatroom.toMap());
    } else {}
    return chatid;
  }

  //send message
  Future<void> sendmessage({
    required String chatid,
    required String text,
  }) async {
    try {
      isSending.value = true;
      final currentuser = _auth.currentUser;
      if (currentuser == null) {
        throw Exception("user not logged in");
      }
      final messageref = _firestore
          .collection('chatrooms')
          .doc(chatid)
          .collection('messages')
          .doc();

      final messagedata = {
        'messageid': messageref.id,
        'senderid': currentuser.uid,
        'text': text,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      await messageref.set(messagedata);
      await _firestore.collection('chatrooms').doc(chatid).update({
        'lastMessage': text,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      Get.snackbar("error", e.toString());
    } finally {
      isSending.value = false;
    }
  }

  //Stream real time messages
  Stream<QuerySnapshot<Map<String, dynamic>>> streammessages(String chatid) {
    return _firestore
        .collection('chatrooms')
        .doc(chatid)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
