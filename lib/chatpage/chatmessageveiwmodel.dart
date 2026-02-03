import 'dart:async';
import 'dart:io'; // ⚠️ Required for Internet Check

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

// Import your models
import 'package:my_chat/AI/grammarfixer.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagemodel.dart';

class Chatmessageveiwmodel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🟢 Reactive List
  var messages = <MessageModel>[].obs;

  // 🟢 Local Box for THIS chat
  Box<MessageModel>? _msgBox;
  StreamSubscription? _msgSub;

  var issending = false.obs;
  final isPickingImages = false.obs;
  final TextEditingController messageController = TextEditingController();

  // AI Service
  var isFixingGrammar = false.obs;
  final GrammarService _grammarService = GrammarService();

  @override
  void onClose() {
    messageController.dispose();
    _msgSub?.cancel();
    super.onClose();
  }

  // 🔥 1. NEW HELPER: Check for Real Internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // 🔥 INITIALIZE CHAT
  Future<void> initChat(
    String chatId,
    String myUserId,
    Map<String, int> clearedBy,
  ) async {
    final boxName = 'chat_messages_$chatId';

    if (!Hive.isBoxOpen(boxName)) {
      _msgBox = await Hive.openBox<MessageModel>(boxName);
    } else {
      _msgBox = Hive.box<MessageModel>(boxName);
    }

    _loadLocalMessages(myUserId, clearedBy);
    _listenToLiveMessages(chatId, myUserId, clearedBy);
  }

  void _loadLocalMessages(String myUserId, Map<String, int> clearedBy) {
    if (_msgBox == null || _msgBox!.isEmpty) return;
    final int clearTime = clearedBy[myUserId] ?? 0;

    final localData = _msgBox!.values.where((msg) {
      return msg.timestamp > clearTime && !msg.deletedFor.contains(myUserId);
    }).toList();

    localData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    messages.assignAll(localData);
  }

  void _listenToLiveMessages(
    String chatId,
    String myUserId,
    Map<String, int> clearedBy,
  ) {
    final int clearTime = clearedBy[myUserId] ?? 0;

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

          messages.assignAll(serverMessages);

          if (_msgBox != null && _msgBox!.isOpen) {
            await _msgBox!.clear();
            await _msgBox!.addAll(serverMessages);
          }
          markMessagesAsSeen(chatId);
        });
  }

  // 🛑 UPDATED SEND MESSAGE (With Internet Block)
 Future<void> sendMessage({required String chatId, String? text}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1️⃣ CHECK INTERNET
    final isOnline = await hasInternetConnection();
    if (!isOnline) {
      Get.snackbar("No Internet", "Connect to internet to send 📶");
      return;
    }

    final messageText = text ?? messageController.text.trim();
    final hasImages = selectedImages.isNotEmpty;

    if (messageText.isEmpty && !hasImages) return;

    // 2️⃣ SAFE CLEAR UI
    try {
      messageController.clear();
    } catch (e) {}

    final List<File> localImagesToUpload = List.from(selectedImages);
    selectedImages.clear();

    try {
      final msgRef = _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      final messageId = msgRef.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // ... (Image upload logic remains the same) ...
      List<String> imageUrls = [];
      MessageType messageType = MessageType.text;
      
      if (hasImages) {
        issending.value = true;
        try {
          imageUrls = await _uploadimage(
            chatid: chatId,
            messageid: messageId,
            images: localImagesToUpload,
          );
          messageType = MessageType.image;
        } catch (e) {
          issending.value = false;
          return;
        }
      }
      // ... (End Image logic) ...

      final message = MessageModel(
        messageId: messageId,
        chatId: chatId,
        senderId: user.uid,
        text: messageText,
        urls: imageUrls,
        messageType: messageType,
        timestamp: timestamp,
        starredBy: [],
        deletedFor: [],
        seenBy: [user.uid],
        starredAt: 0,
        isDeletedForEveryone: false,
      );

      // 3️⃣ Save Message
      await msgRef.set(message.toMap());

      // 4️⃣ ✅ CRITICAL FIX: Extract participants from the Chat ID
      // This ensures the 'participants' field is ALWAYS present
      List<String> participants = [];
      if (chatId.contains('_')) {
        participants = chatId.split('_');
      }

      // 5️⃣ Update Chatroom (Create if missing, add participants)
      Map<String, dynamic> roomData = {
        'lastMessage': messageType == MessageType.image ? '📷 Photo' : messageText,
        'lastMessageTime': timestamp,
      };

      // Only add participants if we successfully extracted them
      if (participants.isNotEmpty) {
        roomData['participants'] = participants;
      }

      await _firestore.collection('chatrooms').doc(chatId).set(
        roomData,
        SetOptions(merge: true), // This merges the new data safely
      );

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      issending.value = false;
    }
  }
  // ------------------ OTHER HELPERS ------------------ //

  Future<void> fixGrammar() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    isFixingGrammar.value = true;
    final fixedText = await _grammarService.fixGrammar(text);
    if (fixedText != null) {
      messageController.text = fixedText;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: fixedText.length),
      );
    }
    isFixingGrammar.value = false;
  }

  Future<ChatRoomModel> getorcreatechatroom(String otheruserid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

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
      return chatRoom;
    }
    return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> markMessagesAsSeen(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;
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

    messages.removeWhere((m) => m.messageId == messageId);
  }

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
    messages.clear();
    if (_msgBox != null) await _msgBox!.clear();
  }

  Future<List<String>> _uploadimage({
    required String chatid,
    required String messageid,
    required List<File> images,
  }) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final ref = storage.ref('chat_images/$chatid/$messageid/image_$i.jpg');
      final Uploadtask = await ref.putFile(images[i]);
      urls.add(await Uploadtask.ref.getDownloadURL());
    }
    return urls;
  }

  final RxList<File> selectedImages = <File>[].obs;

  Future<void> pickImagesFromGallery() async {
    if (isPickingImages.value) return;
    isPickingImages.value = true;
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages.assignAll(pickedFiles.map((x) => File(x.path)).toList());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isPickingImages.value = false;
    }
  }
}
