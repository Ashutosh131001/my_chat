import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// Your App Imports
import 'package:my_chat/chatpage/chatappbar.dart';
import 'package:my_chat/chatpage/datepill.dart';
import 'package:my_chat/chatpage/message_input.dart';
import 'package:my_chat/chatpage/messagebubble.dart';
import 'package:my_chat/chatpage/vm.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';

// 🟢 Import our new isolated Date Widget

class pageofchat extends StatefulWidget {
  final usermodel otherUser;

  const pageofchat({super.key, required this.otherUser});

  @override
  State<pageofchat> createState() => _pageofchatState();
}

class _pageofchatState extends State<pageofchat> {
  final Chatmessageveiwmodel chatVM = Get.put(Chatmessageveiwmodel());
  final ScrollController _scrollController = ScrollController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  late String chatId;

  @override
  void initState() {
    super.initState();

    // ⚡ 1. Calculate Chat ID Instantly
    List<String> ids = [currentUid, widget.otherUser.uid];
    ids.sort();
    chatId = ids.join("_");

    // ⚡ 2. Offline Cache Check
    Map<String, int> clearedBy = {};
    try {
     

      if (Hive.isBoxOpen('chat_list_cache')) {
        final box = Hive.box<ChatListItem>('chat_list_cache');
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

    // ⚡ 3. Initialize Engine
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

          /* -------- LAYER 2: MESSAGES -------- */
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (chatVM.messages.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show newest at bottom
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                    itemCount: chatVM.messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = chatVM.messages.length - 1 - index;
                      final msgModel = chatVM.messages[reversedIndex];
                      final bool isMe = msgModel.senderId == currentUid;

                      // 🗓️ DATE HEADER LOGIC
                      bool showDateHeader = false;
                      if (reversedIndex == 0) {
                        showDateHeader =
                            true; // First message always gets a date
                      } else {
                        final previousMsg = chatVM.messages[reversedIndex - 1];
                        final currentDate = DateTime.fromMillisecondsSinceEpoch(
                          msgModel.timestamp,
                        );
                        final previousDate =
                            DateTime.fromMillisecondsSinceEpoch(
                              previousMsg.timestamp,
                            );

                        // If the day changed, show the header!
                        if (currentDate.year != previousDate.year ||
                            currentDate.month != previousDate.month ||
                            currentDate.day != previousDate.day) {
                          showDateHeader = true;
                        }
                      }

                      // 💬 CREATE BUBBLE
                      Widget bubble = MessageBubble(
                        msg: msgModel.toMap(),
                        isMe: isMe,
                        chatId: chatId,
                        msgId: msgModel.messageId,
                      );

                      // 🎯 RENDER BUBBLE + DATE PILL
                      if (showDateHeader) {
                        return Column(
                          children: [
                            // 🟢 Use our imported widget!
                            DatePill(timestamp: msgModel.timestamp),
                            bubble,
                          ],
                        );
                      }

                      return bubble;
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
