import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/models/chatroommodel.dart';
import 'package:my_chat/models/contactusermodel.dart';
import 'package:my_chat/veiws/otheruserprofileveiw.dart';
import 'package:my_chat/viewmodels/chatmessageveiwmodel.dart';

class pageofchat extends StatelessWidget {
  final usermodel otherUser;
  final Chatmessageveiwmodel chatVM = Get.put(Chatmessageveiwmodel());
  final TextEditingController _messageController = TextEditingController();
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

                        // 🔥 SEEN LOGIC: Update Firestore when receiver views messages
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
                            .toList(); // Reverse for standard chat bottom-anchor

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Anchor messages to the bottom
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 135),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index].data();
                            final bool isMe = msg['senderId'] == currentUid;
                            return _buildUltraMessageBubble(
                              context,
                              msg,
                              isMe,
                              chatId,
                              messages[index].id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildUltraInputPod(chatId),
                ],
              ),

              /* -------- LAYER 3: FLOATING GLASS APP BAR -------- */
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: _buildFloatingGlassHeader(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ---------------- ULTRA FLOATING GLASS HEADER ---------------- */
  Widget _buildFloatingGlassHeader(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(
                      () => OtherUserProfileView(userid: otherUser.uid),
                      transition: Transition.cupertino,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF0F3F8),
                          backgroundImage: otherUser.profileImageUrl != null
                              ? NetworkImage(otherUser.profileImageUrl!)
                              : null,
                          child: otherUser.profileImageUrl == null
                              ? Text(
                                  otherUser.name[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                otherUser.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Online",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.videocam_outlined,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Get.snackbar('Sorry', "the feature is under progress");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------- ULTRA MESSAGE BUBBLE ---------------- */
  Widget _buildUltraMessageBubble(
    BuildContext context,
    Map msg,
    bool isMe,
    String chatId,
    String msgId,
  ) {
    bool isDeleted = msg['isDeletedForEveryone'] == true;

    // Status Logic (Seen receipt)
    List seenBy = msg['seenBy'] ?? [];
    bool isSeen = seenBy.length > 1; // Sender + Receiver

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () =>
                  _showDeleteOptions(context, chatId, msgId, isMe),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Colors.white, Color(0xFFFDFDFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25),
                    topRight: const Radius.circular(25),
                    bottomLeft: Radius.circular(isMe ? 25 : 8),
                    bottomRight: Radius.circular(isMe ? 8 : 25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          // ignore: deprecated_member_use
                          ? Colors.blueAccent.withOpacity(0.2)
                          // ignore: deprecated_member_use
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  isDeleted
                      ? "🚫 This message was deleted"
                      : (msg['text'] ?? ""),
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF2D3436),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(msg['timestamp'] ?? 0),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isMe && !isDeleted) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded, // Double tick
                      size: 15,
                      color: isSeen ? Colors.blueAccent : Colors.grey.shade400,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- ULTRA FLOATING INPUT POD ---------------- */
  Widget _buildUltraInputPod(String chatId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Get.snackbar(
                  "Under Progress 😅",
                  "Wait for few days until it works",
                );
              },
              child: const Icon(
                Icons.sentiment_satisfied_alt_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Write a message...",
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Obx(
              () => GestureDetector(
                onTap: chatVM.issending.value
                    ? null
                    : () async {
                        final text = _messageController.text.trim();
                        if (text.isEmpty) return;
                        _messageController.clear();
                        await chatVM.sendmessage(chatid: chatId, text: text);
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: chatVM.issending.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- HELPERS ---------------- */
  String _formatTime(int timestamp) {
    if (timestamp == 0) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    return "$hour:$min ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _showDeleteOptions(
    BuildContext context,
    String chatId,
    String messageId,
    bool isMe,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            _buildActionTile(
              Icons.delete_outline,
              "Delete for me",
              Colors.black87,
              () {
                Get.back();
                chatVM.deleteMessageForMe(chatId: chatId, messageId: messageId);
              },
            ),
            if (isMe)
              _buildActionTile(
                Icons.delete_forever_rounded,
                "Delete for everyone",
                Colors.redAccent,
                () {
                  Get.back();
                  chatVM.deleteMessageForEveryone(
                    chatId: chatId,
                    messageId: messageId,
                  );
                },
              ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
