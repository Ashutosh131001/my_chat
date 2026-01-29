import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatappbar.dart';
import 'package:my_chat/chatpage/message_input.dart';
import 'package:my_chat/chatpage/messagebubble.dart';

// ViewModels & Models
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/viewmodels/staredmessageveiwmodel.dart';

// Widgets


class pageofchat extends StatelessWidget {
  final usermodel otherUser;
  
  // Initialize ViewModels
  final Chatmessageveiwmodel chatVM = Get.put(Chatmessageveiwmodel());
  // We initialize this here so ChatUtils can find it later
  final Staredmessageveiwmodel vm = Get.put(Staredmessageveiwmodel());

  final ScrollController _scrollController = ScrollController();

  pageofchat({super.key, required this.otherUser});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<ChatRoomModel>(
      future: chatVM.getorcreatechatroom(otherUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blueAccent,
              ),
            ),
          );
        }

        final String chatId = snapshot.data!.chatId;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: Stack(
            children: [
              /* -------- LAYER 1: PREMIUM WALLPAPER TEXTURE -------- */
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

              /* -------- LAYER 2: CHAT MESSAGES -------- */
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: chatVM.streamMessages(
                        chatId: chatId,
                        myUserId: currentUid,
                        clearedBy: snapshot.data!.clearedBy,
                      ),
                      builder: (context, msgSnapshot) {
                        if (!msgSnapshot.hasData) {
                          return const Center(
                            child: Text(
                              "Say hi 👋",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }

                        // 🔥 SEEN LOGIC
                        final allDocs = msgSnapshot.data!.docs;
                        if (allDocs.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            chatVM.markMessagesAsSeen(chatId);
                          });
                        }

                        // Filter messages locally for "Delete for Me"
                        final messages = allDocs
                            .where((doc) {
                              final List deletedFor =
                                  doc.data()['deletedFor'] ?? [];
                              return !deletedFor.contains(currentUid);
                            })
                            .toList()
                            .reversed
                            .toList();

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index].data();
                            final bool isMe = msg['senderId'] == currentUid;
                            
                            return MessageBubble(
                              msg: msg,
                              isMe: isMe,
                              chatId: chatId,
                              msgId: messages[index].id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // INPUT POD
                  InputPod(
                    chatId: chatId,
                    chatVM: chatVM,
                    scrollController: _scrollController,
                  ),
                ],
              ),

              /* -------- LAYER 3: FLOATING GLASS APP BAR -------- */
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: ChatHeader(otherUser: otherUser),
              ),
            ],
          ),
        );
      },
    );
  }
}