import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_chat/AI/grammarfixer.dart';
import 'package:my_chat/chatpage/chatrepo.dart';
import 'package:my_chat/chatpage/mediaservice.dart';
import 'package:my_chat/chatpage/messagemodel.dart';

// Import our new services


class Chatmessageveiwmodel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🟢 1. Inject Services
  final ChatRepository _chatRepo = ChatRepository();
  final MediaService mediaService = MediaService(); // Public so UI can read selectedImages
  final GrammarService _grammarService = GrammarService();

  // 🟢 2. UI State Variables
  var messages = <MessageModel>[].obs;
  var issending = false.obs;
  var isFixingGrammar = false.obs;
  final TextEditingController messageController = TextEditingController();

  @override
  void onClose() {
    messageController.dispose();
    _chatRepo.dispose(); // Safely closes the database streams
    super.onClose();
  }

  // 🟢 3. Initialize UI Connection
  Future<void> initChat(String chatId, String myUserId, Map<String, int> clearedBy) async {
    messages.clear(); // Clear old ghosts
    
    await _chatRepo.listenToMessages(
      chatId: chatId,
      myUserId: myUserId,
      clearedBy: clearedBy,
      onUpdate: (newMessages) {
        messages.assignAll(newMessages); // Stream feeds directly into our UI
      },
    );
  }

  // 🟢 4. The Send Logic (Bringing everything together)
  Future<void> sendMessage({required String chatId, String? text}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check Internet
    final isOnline = await _chatRepo.hasInternetConnection();
    if (!isOnline) {
      Get.snackbar("No Internet", "Connect to internet to send 📶");
      return;
    }

    final messageText = text ?? messageController.text.trim();
    final hasImages = mediaService.selectedImages.isNotEmpty;

    if (messageText.isEmpty && !hasImages) return;

    // Secure local data and clear UI instantly for snappy feel
    issending.value = true;
    messageController.clear();
    final List<File> imagesToUpload = List.from(mediaService.selectedImages);
    mediaService.clearImages();

    try {
      // Pre-generate a Document ID for the image storage path
      final messageId = FirebaseFirestore.instance.collection('chats').doc().id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      List<String> imageUrls = [];
      MessageType messageType = MessageType.text;

      // Handle Image Uploads via MediaService
      if (hasImages) {
        imageUrls = await mediaService.uploadImages(
          chatId: chatId,
          messageId: messageId,
          images: imagesToUpload,
        );
        messageType = MessageType.image;
      }

      // Create the Model
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

      // Save to Database via ChatRepository
      await _chatRepo.saveMessageToFirestore(chatId: chatId, message: message);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      issending.value = false;
    }
  }

  // 🟢 5. UI Action Wrappers
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

  Future<void> clearChatForMe(String chatId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _chatRepo.clearChatForMe(chatId, user.uid);
      messages.clear();
    }
  }

  Future<void> deleteMessageForMe({required String chatId, required String messageId}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _chatRepo.deleteMessageForMe(chatId, messageId, user.uid);
      messages.removeWhere((m) => m.messageId == messageId);
    }
  }

  Future<void> deleteMessageForEveryone({required String chatId, required String messageId}) async {
    await _chatRepo.deleteMessageForEveryone(chatId, messageId);
  }
}