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

  pageofchat({super.key, required this.otherUser});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<ChatRoomModel>(
      future: chatVM.getorcreatechatroom(otherUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final ChatRoomModel initialRoom = snapshot.data!;
        final String chatId = initialRoom.chatId;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .doc(chatId)
              .snapshots(),
          builder: (context, roomSnapshot) {
            if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final chatRoom = ChatRoomModel.fromMap(roomSnapshot.data!.data()!);

            final int? clearedAt = chatRoom.clearedBy[currentUid];

            return Scaffold(
              backgroundColor: const Color(0xFFF2F6FF),

              /* ---------------- APP BAR ---------------- */
              appBar: AppBar(
                backgroundColor: Colors.blueAccent,
                title: InkWell(
                  onTap: () {
                    Get.to(
                      () => OtherUserProfileView(userid: otherUser.uid),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: otherUser.profileImageUrl != null
                            ? NetworkImage(otherUser.profileImageUrl!)
                            : null,
                        child: otherUser.profileImageUrl == null
                            ? Text(otherUser.name[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(otherUser.name),
                    ],
                  ),
                ),
              ),

              /* ---------------- BODY ---------------- */
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: chatVM.streamMessages(
                        chatId: chatId,
                        myUserId: currentUid,
                        clearedBy: chatRoom.clearedBy,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: Text("Say hi 👋"));
                        }

                        final messages = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index].data();
                            final bool isMe = msg['senderId'] == currentUid;

                            final List deletedFor = msg['deletedFor'] ?? [];

                            // DELETE FOR ME
                            if (deletedFor.contains(currentUid)) {
                              return const SizedBox.shrink();
                            }

                            // CLEAR CHAT FILTER (IMPORTANT)
                            final int msgTime = msg['timestamp'];
                            if (clearedAt != null && msgTime <= clearedAt) {
                              return const SizedBox.shrink();
                            }

                            final bool isDeletedForEveryone =
                                msg['isDeletedForEveryone'] == true;

                            return GestureDetector(
                              onLongPress: () {
                                _showDeleteOptions(
                                  context,
                                  chatId,
                                  messages[index].id,
                                  isMe,
                                );
                              },
                              child: Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blueAccent
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isDeletedForEveryone
                                            ? "This message was deleted"
                                            : msg['text'] ?? "",
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black87,
                                          fontStyle: isDeletedForEveryone
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(msgTime),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  _buildInputBar(chatId),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /* ---------------- INPUT BAR ---------------- */
  Widget _buildInputBar(String chatId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            return CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: IconButton(
                icon: chatVM.issending.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: chatVM.issending.value
                    ? null
                    : () async {
                        final text = _messageController.text.trim();
                        if (text.isEmpty) return;
                        _messageController.clear();
                        await chatVM.sendmessage(chatid: chatId, text: text);
                      },
              ),
            );
          }),
        ],
      ),
    );
  }

  /* ---------------- DELETE OPTIONS ---------------- */
  void _showDeleteOptions(
    BuildContext context,
    String chatId,
    String messageId,
    bool isMe,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Delete for me"),
                onTap: () {
                  Navigator.pop(context);
                  chatVM.deleteMessageForMe(
                    chatId: chatId,
                    messageId: messageId,
                  );
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Delete for everyone"),
                  onTap: () {
                    Navigator.pop(context);
                    chatVM.deleteMessageForEveryone(
                      chatId: chatId,
                      messageId: messageId,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final m = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? "PM" : "AM";
    return "$h:$m $ampm";
  }
}
