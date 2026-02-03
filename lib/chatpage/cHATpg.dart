import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:my_chat/chatpage/chatappbar.dart';
import 'package:my_chat/chatpage/message_input.dart';
import 'package:my_chat/chatpage/messagebubble.dart';

// ViewModels & Models
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart'; // Needed for ChatListItem box

class pageofchat extends StatefulWidget {
  final usermodel otherUser;

  const pageofchat({super.key, required this.otherUser});

  @override
  State<pageofchat> createState() => _pageofchatState();
}

class _pageofchatState extends State<pageofchat> {
  // We use Get.put to ensure the controller exists
  final Chatmessageveiwmodel chatVM = Get.put(Chatmessageveiwmodel());
  final ScrollController _scrollController = ScrollController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  late String chatId;

  @override
  void initState() {
    super.initState();

    // ⚡ 1. Calculate Chat ID Instantly (No Database Call needed!)
    // Standard logic: Combine UIDs alphabetically
    List<String> ids = [currentUid, widget.otherUser.uid];
    ids.sort();
    chatId = ids.join("_");

    // ⚡ 2. Try to find "ClearedBy" data from our offline cache
    // This ensures we don't show deleted messages even if offline
    Map<String, int> clearedBy = {};
    try {
      if (Hive.isBoxOpen('chat_list_cache')) {
        final box = Hive.box<ChatListItem>('chat_list_cache');
        // Find the chat item that matches this ID
        final item = box.values.firstWhereOrNull(
          (item) => item.chatroom.chatId == chatId,
        );
        if (item != null) {
          clearedBy = item.chatroom.clearedBy;
        }
      }
    } catch (e) {
      print("Cache check skipped: $e");
    }

    // ⚡ 3. Initialize the Engine
    chatVM.initChat(chatId, currentUid, clearedBy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          /* -------- LAYER 1: WALLPAPER -------- */
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://www.transparenttextures.com/patterns/cubes.png",
                  ),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          /* -------- LAYER 2: MESSAGES (Now Offline Ready) -------- */
          Column(
            children: [
              Expanded(
                // 🔥 NO STREAM BUILDER! We use Obx for instant updates.
                child: Obx(() {
                  // While Hive loads (usually < 10ms), show nothing or loader
                  // But usually, this is instant.
                  if (chatVM.messages.isEmpty) {
                    // Optional: You could show a "Say Hi" placeholder here
                    // But we return empty container to avoid flickering
                    return const SizedBox.shrink();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show newest at bottom (standard chat)
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                    // We reverse the list from the controller to match ListView.reverse
                    itemCount: chatVM.messages.length,
                    itemBuilder: (context, index) {
                      // Get message from Controller (Obs List)
                      // Note: Controller list is Oldest -> Newest.
                      // Since ListView is reversed, we need to invert the index access
                      // or simply reverse the list in logic.
                      // EASIEST WAY: Reverse the access index
                      final reversedIndex = chatVM.messages.length - 1 - index;
                      final msgModel = chatVM.messages[reversedIndex];

                      final bool isMe = msgModel.senderId == currentUid;

                      return MessageBubble(
                        // ⚠️ Convert Model back to Map for your existing Bubble widget
                        msg: msgModel.toMap(),
                        isMe: isMe,
                        chatId: chatId,
                        msgId: msgModel.messageId,
                      );
                    },
                  );
                }),
              ),

              // INPUT POD
              InputPod(
                chatId: chatId,
                chatVM: chatVM,
                scrollController: _scrollController,
              ),
            ],
          ),

          /* -------- LAYER 3: APP BAR -------- */
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: ChatHeader(otherUser: widget.otherUser),
          ),
        ],
      ),
    );
  }
}
