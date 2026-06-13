import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagemodel.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Box<MessageModel>? _msgBox;
  StreamSubscription? _msgSub;

  // 🌐 Internet Check
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // 📥 Get or Create Chatroom (with Offline Fallback)
  Future<ChatRoomModel> getOrCreateChatRoom(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final participants = [currentUser.uid, otherUserId]..sort();
    final chatId = participants.join('_');

    final chatRef = _firestore.collection('chatrooms').doc(chatId);
    DocumentSnapshot doc;
    
    try {
      doc = await chatRef.get(const GetOptions(source: Source.server));
    } catch (e) {
      doc = await chatRef.get(const GetOptions(source: Source.cache));
    }

    if (!doc.exists) {
      final chatRoom = ChatRoomModel(
        chatId: chatId,
        participants: participants,
        lastMessage: null,
        lastMessageTime: null,
        clearedBy: {},
      );
      await chatRef.set(chatRoom.toMap());
      return chatRoom;
    }
    return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // 🎧 Listen to Live Messages (and load local cache)
  Future<void> listenToMessages({
    required String chatId,
    required String myUserId,
    required Map<String, int> clearedBy,
    required Function(List<MessageModel>) onUpdate,
  }) async {
    final boxName = 'chat_messages_$chatId';

    if (!Hive.isBoxOpen(boxName)) {
      _msgBox = await Hive.openBox<MessageModel>(boxName);
    } else {
      _msgBox = Hive.box<MessageModel>(boxName);
    }

    final int clearTime = clearedBy[myUserId] ?? 0;

    // 1. Send Local Data Instantly
    if (_msgBox != null && _msgBox!.isNotEmpty) {
      final localData = _msgBox!.values.where((msg) {
        return msg.timestamp > clearTime && !msg.deletedFor.contains(myUserId);
      }).toList();
      localData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      onUpdate(localData);
    }

    // 2. Open Live Server Stream
    _msgSub = _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .where('timestamp', isGreaterThan: clearTime)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) async {
          List<MessageModel> serverMessages = [];

          for (var doc in snapshot.docs) {
            try {
              final msg = MessageModel.fromMap(doc.data());
              if (!msg.deletedFor.contains(myUserId)) {
                serverMessages.add(msg);
              }
            } catch (e) {
              print("Error parsing message: $e");
            }
          }

          if (_msgBox != null && _msgBox!.isOpen) {
            await _msgBox!.clear();
            await _msgBox!.addAll(serverMessages);
          }
          
          onUpdate(serverMessages); // Pass fresh data back to the UI
          _markMessagesAsSeen(chatId, myUserId);
        });
  }

  // 📝 Save Message to Firestore
  Future<void> saveMessageToFirestore({
    required String chatId,
    required MessageModel message,
  }) async {
    // 1. Save Message
    await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());

    // 2. Update Chatroom
    List<String> participants = chatId.contains('_') ? chatId.split('_') : [];
    
    Map<String, dynamic> roomData = {
      'lastMessage': message.messageType == MessageType.image ? '📷 Photo' : message.text,
      'lastMessageTime': message.timestamp,
    };

    if (participants.isNotEmpty) {
      roomData['participants'] = participants;
    }

    await _firestore.collection('chatrooms').doc(chatId).set(
      roomData,
      SetOptions(merge: true),
    );
  }

  // 👀 Background Helper: Mark Seen
  Future<void> _markMessagesAsSeen(String chatId, String myUserId) async {
    final snapshot = await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: myUserId)
        .get();

    WriteBatch batch = _firestore.batch();
    bool hasUpdates = false;

    for (var doc in snapshot.docs) {
      final List seenBy = doc.data()['seenBy'] ?? [];
      if (!seenBy.contains(myUserId)) {
        batch.update(doc.reference, {'seenBy': FieldValue.arrayUnion([myUserId])});
        hasUpdates = true;
      }
    }
    if (hasUpdates) await batch.commit();
  }

  // 🗑️ Delete Helpers
  Future<void> clearChatForMe(String chatId, String myUserId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('chatrooms').doc(chatId).update(
      {'clearedBy.$myUserId': timestamp},
    );
    if (_msgBox != null) await _msgBox!.clear();
  }

  Future<void> deleteMessageForMe(String chatId, String messageId, String myUserId) async {
    await _firestore.collection('chatrooms').doc(chatId).collection('messages').doc(messageId).update({
      'deletedFor': FieldValue.arrayUnion([myUserId]),
    });
  }

  Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
    await _firestore.collection('chatrooms').doc(chatId).collection('messages').doc(messageId).update({
      'isDeletedForEveryone': true, 'text': null,
    });
  }

  void dispose() {
    _msgSub?.cancel();
  }
}