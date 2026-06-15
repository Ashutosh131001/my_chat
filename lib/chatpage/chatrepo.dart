import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagemodel.dart';

// 🚨 IMPORT YOUR ENCRYPTION TOOLS HERE
import 'package:encrypt/encrypt.dart' as enc;
import 'package:my_chat/service/chatencryptioninterceptor.dart';
// import 'package:my_chat/services/chat_encryption_interceptor.dart'; // Adjust path!

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Box<MessageModel>? _msgBox;
  StreamSubscription? _msgSub;

  // 🚨 THE VAULT MEMORY: Holds the fast AES key while this specific chat is open
  enc.Key? currentRoomAesKey;

  // 🌐 Internet Check
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // 📥 Get or Create Chatroom (with Offline Fallback & RSA Handshake)
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

   
    // We need to fetch both Public Keys to securely share the AES Key
    final myUserDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final friendUserDoc = await _firestore.collection('users').doc(otherUserId).get();

    final myPublicKey = myUserDoc.data()?['publicKey'];
    final friendPublicKey = friendUserDoc.data()?['publicKey'];

    if (!doc.exists) {
      // BRAND NEW CHAT
      Map<String, dynamic> roomData = {
        'chatId': chatId,
        'participants': participants,
        'lastMessage': null,
        'lastMessageTime': null,
        'clearedBy': {},
      };

      // Only secure the room if BOTH users have updated the app and have keys
      if (myPublicKey != null && friendPublicKey != null) {
        currentRoomAesKey = ChatEncryptionInterceptor.generateChatRoomAESKey();
        
        roomData['aesKey_${currentUser.uid}'] = ChatEncryptionInterceptor.lockAESKeyWithRSA(currentRoomAesKey!, myPublicKey);
        roomData['aesKey_$otherUserId'] = ChatEncryptionInterceptor.lockAESKeyWithRSA(currentRoomAesKey!, friendPublicKey);
      } else {
        print("Warning: Missing Public Keys. Chat will be unencrypted until both users update.");
        currentRoomAesKey = null;
      }

      await chatRef.set(roomData);
      return ChatRoomModel.fromMap(roomData);
    }

    // EXISTING CHAT
    Map<String, dynamic> existingData = doc.data() as Map<String, dynamic>;

    if (existingData.containsKey('aesKey_${currentUser.uid}')) {
       // Unlock the AES key using your hardware Private Key
       final myLockedKey = existingData['aesKey_${currentUser.uid}'];
       currentRoomAesKey = await ChatEncryptionInterceptor.unlockAESKeyWithRSA(myLockedKey);
    } 
    // Fallback: If it's an old chat, we upgrade it to a secure chat right now!
    else if (myPublicKey != null && friendPublicKey != null) {
       currentRoomAesKey = ChatEncryptionInterceptor.generateChatRoomAESKey();
       
       await chatRef.update({
          'aesKey_${currentUser.uid}': ChatEncryptionInterceptor.lockAESKeyWithRSA(currentRoomAesKey!, myPublicKey),
          'aesKey_$otherUserId': ChatEncryptionInterceptor.lockAESKeyWithRSA(currentRoomAesKey!, friendPublicKey),
       });
    }

    return ChatRoomModel.fromMap(existingData);
  }

  // 🎧 Listen to Live Messages
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
              Map<String, dynamic> data = doc.data();

              // 🚨 THE INTERCEPTOR (INCOMING TEXT) 🚨
              // If Firebase gives us Gibberish, unscramble it before showing the UI
              if (data['isEncrypted'] == true && currentRoomAesKey != null && data['text'] != null) {
                 data['text'] = ChatEncryptionInterceptor.decryptMessage(data['text'], currentRoomAesKey!);
              }

              final msg = MessageModel.fromMap(data);
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
    
    // 🚨 THE INTERCEPTOR (OUTGOING TEXT) 🚨
    MessageModel finalMessage = message;

    // If it's a text message and we have an active vault, scramble it!
    if (message.messageType == MessageType.text && currentRoomAesKey != null && message.text != null) {
      final scrambledText = ChatEncryptionInterceptor.encryptMessage(message.text!, currentRoomAesKey!);
      
      finalMessage = message.copyWith(
        text: scrambledText,
        isEncrypted: true, // Tell Firebase this is a secure message
      );
    }

    // 1. Save Message to Firebase
    await _firestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(finalMessage.messageId)
        .set(finalMessage.toMap());

    // 2. Update Chatroom
    List<String> participants = chatId.contains('_') ? chatId.split('_') : [];
    
    // 🔥 CRITICAL UI FIX FOR HOME SCREEN:
    // If we save the gibberish text to the 'lastMessage' field, your Home screen 
    // will just show random letters. We show a placeholder instead!
    String displayLastMessage = finalMessage.messageType == MessageType.image
        ? '📷 Photo'
        : (finalMessage.isEncrypted ? '🔒 Secure Message' : finalMessage.text ?? '');

    Map<String, dynamic> roomData = {
      'lastMessage': displayLastMessage,
      'lastMessageTime': finalMessage.timestamp,
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