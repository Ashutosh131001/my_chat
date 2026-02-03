import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';

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

  /// 📦 LOAD CHAT LIST FROM HIVE (INSTANT UI)
  void _loadLocalCache() {
    try {
      if (Hive.isBoxOpen('chat_list_cache')) {
        _chatBox = Hive.box<ChatListItem>('chat_list_cache');

        if (_chatBox != null && _chatBox!.isNotEmpty) {
          final cachedChats = _chatBox!.values.toList();

          cachedChats.sort(
            (a, b) => (b.chatroom.lastMessageTime ?? 0).compareTo(
              a.chatroom.lastMessageTime ?? 0,
            ),
          );

          chatList.assignAll(cachedChats);
        }
      }
    } catch (e) {
      print("❌ Cache Error: $e");
    }
  }

  /// 🔥 LISTEN TO FIRESTORE (REAL SOURCE OF TRUTH)
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
            final List<ChatListItem> tempList = [];

            for (var doc in snapshot.docs) {
              try {
                // 🛑 1. GET DATA & INJECT ID (THE FIX)
                // We copy the data to a new map so we can modify it safely
                final Map<String, dynamic> data = Map<String, dynamic>.from(
                  doc.data(),
                );

                // We manually put the Document ID into the 'chatId' field
                data['chatId'] = doc.id;

                // 🛑 2. SAFETY CHECK FOR 'clearedBy'
                // If the field is missing in Firestore, default it to empty map
                if (data['clearedBy'] == null) {
                  data['clearedBy'] = {};
                }

                // 3. NOW CREATE THE MODEL
                // The model will now see the correct ID ('8J0h...') instead of ""
                final chatroom = ChatRoomModel.fromMap(data);

                // --- REST OF YOUR LOGIC IS PERFECT ---

                // 🔥🔥🔥 CLEAR HISTORY FILTER
                final int clearTime = chatroom.clearedBy[uid] ?? 0;
                final int lastMsgTime = chatroom.lastMessageTime ?? 0;

                if (lastMsgTime <= clearTime) {
                  continue;
                }

                final otherId = chatroom.participants.firstWhere(
                  (id) => id != uid,
                  orElse: () => '',
                );

                if (otherId.isEmpty) continue;

                usermodel? displayUser;

                try {
                  final userDoc = await _firestore
                      .collection('users')
                      .doc(otherId)
                      .get();
                  if (userDoc.exists) {
                    displayUser = usermodel.frommap(userDoc.data()!);
                  }
                } catch (_) {
                  final cached = chatList.firstWhereOrNull(
                    (e) => e.otheruser.uid == otherId,
                  );
                  if (cached != null) {
                    displayUser = cached.otheruser;
                  }
                }

                if (displayUser != null) {
                  tempList.add(
                    ChatListItem(chatroom: chatroom, otheruser: displayUser),
                  );
                }
              } catch (e) {
                print("Error processing chatroom: $e");
              }
            }

            // 🔁 SORT
            tempList.sort(
              (a, b) => (b.chatroom.lastMessageTime ?? 0).compareTo(
                a.chatroom.lastMessageTime ?? 0,
              ),
            );

            chatList.assignAll(tempList);
            isLoading.value = false;

            // 💾 CACHE
            if (_chatBox != null && _chatBox!.isOpen) {
              await _chatBox!.clear();
              await _chatBox!.addAll(tempList);
            }
          },
          onError: (error) {
            print("Firebase Error: $error");
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _chatSub?.cancel();
    super.onClose();
  }
}
