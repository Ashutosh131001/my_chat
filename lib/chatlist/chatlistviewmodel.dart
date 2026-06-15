import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
// 🚨 NEW IMPORT REQUIRED FOR THE CACHE PEEK
import 'package:my_chat/chatpage/messagemodel.dart';

class Chatlistviewmodel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Box<ChatListItem>? _chatBox;

  var chatList = <ChatListItem>[].obs;
  var isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSub;

  @override
  void onInit() {
    super.onInit();
    _loadLocalCache();
    listenchatlist();
  }

  void _loadLocalCache() {
    try {
      if (Hive.isBoxOpen('chat_list_cache')) {
        _chatBox = Hive.box<ChatListItem>('chat_list_cache');

        if (_chatBox != null && _chatBox!.isNotEmpty) {
          final currentUser = _auth.currentUser;
          if (currentUser == null) return;
          final uid = currentUser.uid;

          // 🟢 ONLY load chats into UI if they haven't been cleared
          final visibleChats = _chatBox!.values.where((item) {
            final int clearTime = item.chatroom.clearedBy[uid] ?? 0;
            final int lastTime = item.chatroom.lastMessageTime ?? 0;
            return lastTime > clearTime;
          }).toList();

          visibleChats.sort(
            (a, b) => (b.chatroom.lastMessageTime ?? 0).compareTo(
              a.chatroom.lastMessageTime ?? 0,
            ),
          );
          chatList.assignAll(visibleChats);
        }
      }
    } catch (e) {
      print("Cache Error: $e");
    }
  }

  // LISTEN TO FIRESTORE
  void listenchatlist() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    if (chatList.isEmpty) isLoading.value = true;

    _chatSub = _firestore
        .collection('chatrooms')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen(
          (snapshot) async {
            final List<ChatListItem> uiList = []; // What the user sees
            final List<ChatListItem> cacheList =
                []; // Everything (to remember timestamps)

            for (var doc in snapshot.docs) {
              try {
                final Map<String, dynamic> data = Map<String, dynamic>.from(
                  doc.data(),
                );
                data['chatId'] = doc.id;

                if (data['clearedBy'] == null) {
                  data['clearedBy'] = {};
                }

                // 🚨 THE INTERCEPTOR (HOME SCREEN UI FIX) 🚨
                // If Firebase only has the placeholder, look into our local decrypted cache!
                if (data['lastMessage'] == '🔒 Secure Message') {
                  try {
                    final boxName = 'chat_messages_${doc.id}';
                    Box<MessageModel>? msgBox;

                    if (Hive.isBoxOpen(boxName)) {
                      msgBox = Hive.box<MessageModel>(boxName);
                    } else {
                      // Quickly open it to peek inside
                      msgBox = await Hive.openBox<MessageModel>(boxName);
                    }

                    if (msgBox.isNotEmpty) {
                      // Grab the valid messages
                      final validMessages = msgBox.values
                          .where((m) => !m.deletedFor.contains(uid))
                          .toList();
                      if (validMessages.isNotEmpty) {
                        validMessages.sort(
                          (a, b) => b.timestamp.compareTo(a.timestamp),
                        );
                        final latestMsg = validMessages.first;

                        // Check if our local cache is up to date with Firebase
                        if (latestMsg.timestamp >=
                            (data['lastMessageTime'] ?? 0)) {
                          data['lastMessage'] =
                              latestMsg.messageType == MessageType.image
                              ? '📷 Photo'
                              : latestMsg.text;
                        } else {
                          // They haven't opened the chat yet to download/decrypt the newest message
                          data['lastMessage'] = '🔒 New Message';
                        }
                      }
                    } else {
                      data['lastMessage'] = '🔒 New Message';
                    }
                  } catch (e) {
                    print("Cache peek error: $e");
                  }
                }

                final chatroom = ChatRoomModel.fromMap(data);
                final int clearTime = chatroom.clearedBy[uid] ?? 0;
                final int lastMsgTime = chatroom.lastMessageTime ?? 0;

                final otherId = chatroom.participants.firstWhere(
                  (id) => id != uid,
                  orElse: () => '',
                );

                if (otherId.isEmpty) continue;

                // 🟢 RESTORED: Fetching the displayUser logic
                usermodel? displayUser;

                try {
                  // Try to get the freshest profile from Firebase
                  final userDoc = await _firestore
                      .collection('users')
                      .doc(otherId)
                      .get();
                  if (userDoc.exists) {
                    displayUser = usermodel.frommap(userDoc.data()!);
                  }
                } catch (_) {
                  // Fallback: If offline or failed, grab from existing cache
                  final cached = chatList.firstWhereOrNull(
                    (e) => e.otheruser.uid == otherId,
                  );
                  if (cached != null) {
                    displayUser = cached.otheruser;
                  }
                }

                // 🟢 Now displayUser is defined and we can use it!
                if (displayUser != null) {
                  final chatItem = ChatListItem(
                    chatroom: chatroom,
                    otheruser: displayUser,
                  );

                  // 1. ALWAYS add to Cache (to remember the clearTime)
                  cacheList.add(chatItem);

                  // 2. ONLY add to UI if there are visible messages
                  if (lastMsgTime > clearTime) {
                    uiList.add(chatItem);
                  }
                }
              } catch (e) {
                print("Error processing chatroom: $e");
              }
            }

            // 🔁 SORT AND UPDATE UI
            uiList.sort(
              (a, b) => (b.chatroom.lastMessageTime ?? 0).compareTo(
                a.chatroom.lastMessageTime ?? 0,
              ),
            );

            chatList.assignAll(uiList);
            isLoading.value = false;

            // 🗄️ UPDATE CACHE WITH EVERYTHING
            if (_chatBox != null && _chatBox!.isOpen) {
              await _chatBox!.clear();
              await _chatBox!.addAll(cacheList);
            }
          },
          onError: (error) {
            print("Firebase Error: $error");
            isLoading.value = false;
          },
        );
  }

  void removeChat(String chatId) async {
    // 1. Remove from UI
    chatList.removeWhere((item) => item.chatroom.chatId == chatId);

    // 2. Remove from cache
    if (_chatBox != null && _chatBox!.isOpen) {
      final keysToDelete = _chatBox!.keys.where((key) {
        return _chatBox!.get(key)?.chatroom.chatId == chatId;
      }).toList();

      for (var key in keysToDelete) {
        await _chatBox!.delete(key);
      }
    }
  }

  @override
  void onClose() {
    _chatSub?.cancel();
    super.onClose();
  }
}
