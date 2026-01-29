import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart'; // ✅ Needed for TextEditingController
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/AI/grammarfixer.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagemodel.dart';
// ✅ IMPORT YOUR GRAMMAR SERVICE

class Chatmessageveiwmodel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var issending = false.obs;
  final isPickingImages = false.obs;

  // 🔥 1. NEW: GLOBAL TEXT CONTROLLER
  // We keep it here so text doesn't vanish when keyboard opens/closes
  final TextEditingController messageController = TextEditingController();

  // 🔥 2. NEW: AI STATE & SERVICE
  var isFixingGrammar = false.obs;
  final GrammarService _grammarService = GrammarService();

  // 🔥 3. NEW: CLEANUP
  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // 🔥 4. NEW: AI GRAMMAR FIX LOGIC
  Future<void> fixGrammar() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isFixingGrammar.value = true; // Start loading spinner

    final fixedText = await _grammarService.fixGrammar(text);

    if (fixedText != null) {
      messageController.text = fixedText;
      // Move cursor to the end of the new text
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: fixedText.length),
      );
    } else {
      Get.snackbar("Error", "Could not fix grammar");
    }

    isFixingGrammar.value = false; // Stop loading spinner
  }

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
      return chatRoom;
    }

    return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
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

  // DELETE MESSAGE FOR ME
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

  // Upload images
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
      final url = await Uploadtask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // SEND MESSAGE (UPDATED)
  Future<void> sendMessage({
    required String chatId,
    // 🔥 REMOVED 'text' parameter because we use the controller now
    String? text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 🔥 USE CONTROLLER TEXT IF NO TEXT PASSED
    final messageText = text ?? messageController.text.trim();

    try {
      issending.value = true;

      final msgRef = _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      final messageId = msgRef.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      List<String> imageUrls = [];

      if (selectedImages.isNotEmpty) {
        imageUrls = await _uploadimage(
          chatid: chatId,
          messageid: messageId,
          images: selectedImages,
        );
      }

      final messageType = imageUrls.isNotEmpty
          ? MessageType.image
          : MessageType.text;

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

      await msgRef.set(message.toMap());

      await _firestore.collection('chatrooms').doc(chatId).update({
        'lastMessage': messageType == MessageType.image
            ? '📷 Photo'
            : messageText,
        'lastMessageTime': timestamp,
      });

      selectedImages.clear();
      // 🔥 CLEAR CONTROLLER AFTER SENDING
      messageController.clear();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      issending.value = false;
    }
  }

  // Holds images picked but NOT sent yet
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

  String _formatLastSeen(int timestamp) {
    if (timestamp == 0) return "Offline";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Last seen just now";
    if (diff.inMinutes < 60) return "Last seen ${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "Last seen ${diff.inHours}h ago";
    return "Last seen offline";
  }
}
