import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/models/contactusermodel.dart';
import 'package:my_chat/veiws/otheruserprofileveiw.dart';
import 'package:my_chat/viewmodels/chatroomveiwmodel.dart';

class ChatPage extends StatelessWidget {
  final usermodel otherUser;
  final ChatRoomVeiwModel chatVM = Get.put(ChatRoomVeiwModel());

  ChatPage({super.key, required this.otherUser});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chatVM.getorcreatechatroom(otherUser.uid),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          );
        }

        final chatId = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),

          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            elevation: 2,
            title: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Get.to(() => OtherUserProfileView(userid: otherUser.uid));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent.shade100,
                    backgroundImage: otherUser.profileImageUrl != null
                        ? NetworkImage(otherUser.profileImageUrl!)
                        : null,
                    child: otherUser.profileImageUrl == null
                        ? Text(
                            otherUser.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    otherUser.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatVM.streammessages(chatId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "Say hi 👋",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            messages[index].data() as Map<String, dynamic>;

                        final bool isMe =
                            msg['senderid'] ==
                            FirebaseAuth.instance.currentUser!.uid;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blueAccent : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                  bottomLeft: isMe
                                      ? Radius.circular(14)
                                      : Radius.circular(0),
                                  bottomRight: isMe
                                      ? Radius.circular(0)
                                      : Radius.circular(14),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              _buildMessageInput(chatId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(String chatId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 25),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Obx(() {
            return GestureDetector(
              onTap: chatVM.isSending.value
                  ? null
                  : () async {
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;

                      _messageController.clear();

                      await chatVM.sendmessage(chatid: chatId, text: text);
                    },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blueAccent,
                child: chatVM.isSending.value
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}
