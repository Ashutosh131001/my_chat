import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_chat/models/chatroommodel.dart';
import 'package:my_chat/models/messagemodel.dart';

class Chatmessageveiwmodel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var issending = false.obs;

  
    // CREATE OR GET CHAT ROOM
   
  Future<ChatRoomModel> getorcreatechatroom(String otheruserid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final participants = [currentUser.uid, otheruserid]..sort();
    final chatId = participants.join('_');

    final chatRef = _firestore.collection('chatrooms').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      final chatRoom = ChatRoomModel(
        chatId: chatId,
        participants: participants,
        lastMessage: null,
        lastMessageTime: null,
        clearedBy: {},
      );

      await chatRef.set(chatRoom.toMap());
      return chatRoom; // ✅ RETURN
    }

    //  EXISTING CHATROOM
    return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  
    // SEND MESSAGE
  
  Future<void> sendmessage({
    required String chatid,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      issending.value = true;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final msgRef = _firestore
          .collection('chatrooms')
          .doc(chatid)
          .collection('messages')
          .doc();

      final message = MessageModel(
        messageId: msgRef.id,
        chatId: chatid,
        senderId: user.uid,
        text: text,
        timestamp: timestamp,
        seenBy: [user.uid],
        deletedFor: [],
        isDeletedForEveryone: false,
      );

      await msgRef.set(message.toMap());

      // 2️⃣ Update chatroom
      await _firestore.collection('chatrooms').doc(chatid).update({
        'lastMessage': text,
        'lastMessageTime': timestamp,

        
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      issending.value = false;
    }
  }

  
   // STREAM MESSAGES (REAL TIME)
   
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages({
    required String chatId,
    required String myUserId,
    required Map<String, int> clearedBy,
  }) {
   
    int clearTimestamp = clearedBy[myUserId] ?? 0;

    return _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .where('timestamp', isGreaterThan: clearTimestamp)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

 
   // MARK MESSAGES AS SEEN (DOUBLE TICK)
   
  Future<void> markMessagesAsSeen(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Get all messages sent by the OTHER user that I haven't seen yet
    final snapshot = await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.uid)
        .get();

    WriteBatch batch = _firestore.batch();
    bool hasUpdates = false;

    for (var doc in snapshot.docs) {
      final List seenBy = doc.data()['seenBy'] ?? [];
      if (!seenBy.contains(user.uid)) {
        batch.update(doc.reference, {
          'seenBy': FieldValue.arrayUnion([user.uid]),
        });
        hasUpdates = true;
      }
    }

    if (hasUpdates) await batch.commit();
  }

  /* ----------------------------------------------------
   * 🔹 DELETE MESSAGE FOR ME
   * --------------------------------------------------*/
  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedFor': FieldValue.arrayUnion([user.uid]),
        });
  }

 
    // DELETE MESSAGE FOR EVERYONE
   
  Future<void> deleteMessageForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isDeletedForEveryone': true, 'text': null});
  }

  Future<void> clearChatForMe(String chatId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await FirebaseFirestore.instance.collection('chatrooms').doc(chatId).update(
      {'clearedBy.${user.uid}': timestamp},
    );
  }
}
