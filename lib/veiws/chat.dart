import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/veiws/CHATpg.dart';
import 'package:my_chat/veiws/chatlistpage.dart';
import 'package:my_chat/veiws/login_veiw.dart';
import 'package:my_chat/veiws/profile.dart';
import 'package:my_chat/viewmodels/auth_veiwmodel.dart';
import 'package:my_chat/viewmodels/chatlistviewmodel.dart';

class ChatListPage extends StatelessWidget {
  final Chatlistviewmodel chatListVM = Get.put(Chatlistviewmodel());
  final AuthViewModel authvm = Get.put(AuthViewModel());

  ChatListPage({super.key});

  String getInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "?";
    }
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),

      /* ---------------- APP BAR ---------------- */
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "My Chats",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () async {
                await authvm.removeFcmTokenOnLogout();
                await FirebaseAuth.instance.signOut();
                Get.offAll(
                  () => PhoneLoginView(),
                  transition: Transition.fadeIn,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                Get.to(() => ProfileView(), transition: Transition.cupertino);
              },
              icon: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),

      //body
      body: Obx(() {
        if (chatListVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3A86FF)),
          );
        }

        final visibleChats = chatListVM.chatList.where((item) {
          final int clearTime = item.chatroom.clearedBy[currentUid] ?? 0;
          final int lastMsgTime = item.chatroom.lastMessageTime ?? 0;

          // Show chat if it was never cleared, OR if a new message arrived after clearing
          return lastMsgTime > clearTime;
        }).toList();

        if (visibleChats.isEmpty) {
          return const Center(
            child: Text(
              "No Chats Yet 😔\nStart messaging someone!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: visibleChats.length,
          itemBuilder: (context, index) {
            final item = visibleChats[index];
            final user = item.otheruser;
            final room = item.chatroom;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFE7F0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () {
                  // Pass the otherUser and the chatRoom object to the chat page
                  // so the chat page knows the 'clearedBy' timestamp immediately
                  Get.to(
                    () => pageofchat(otherUser: user),
                    transition: Transition.cupertino,
                    duration: Durations.long4,
                  );
                },
                onLongPress: () {
                  _showClearChatDialog(context, room.chatId, currentUid);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                /* -------- PROFILE IMAGE -------- */
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueAccent.shade100,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          getInitial(user.name),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),

                /* -------- NAME -------- */
                title: Text(
                  user.name.isNotEmpty == true ? user.name : "Unknown",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                /* -------- LAST MESSAGE -------- */
                subtitle: Text(
                  room.lastMessage ?? "Tap to start conversation",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A5A5A),
                  ),
                ),

                /* -------- TIME -------- */
                trailing: Text(
                  room.lastMessageTime != null
                      ? _formatTime(room.lastMessageTime!)
                      : "",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            );
          },
        );
      }),

      /* ---------------- FAB ---------------- */
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Get.to(ContactsView());
          },
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }

  /* ---------------- TIME FORMAT ---------------- */
  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? "PM" : "AM";
    return "$hour:$min $ampm";
  }

  /* ---------------- DIALOG ---------------- */
  void _showClearChatDialog(
    BuildContext context,
    String chatId,
    String currentUid,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  "Clear chat for me",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  await FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(chatId)
                      .update({
                        'clearedBy.$currentUid':
                            DateTime.now().millisecondsSinceEpoch,
                      });
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
