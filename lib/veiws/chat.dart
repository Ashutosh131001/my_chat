
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/veiws/CHATpg.dart';
import 'package:my_chat/veiws/chatlistpage.dart';
import 'package:my_chat/veiws/profile.dart';
import 'package:my_chat/veiws/login_veiw.dart';

import 'package:my_chat/viewmodels/auth_veiwmodel.dart';
import 'package:my_chat/viewmodels/chatlistviewmodel.dart';

class ChatListPage extends StatelessWidget {
  final Chatlistviewmodel chatListVM = Get.put(Chatlistviewmodel());
  final AuthViewModel authvm = Get.put(AuthViewModel());

  ChatListPage({super.key});

  String getInitial(String? name) =>
      (name == null || name.isEmpty) ? "?" : name[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white, // Match the pure white theme
      body: Obx(() {
        if (chatListVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blueAccent,
            ),
          );
        }

        final visibleChats = chatListVM.chatList.where((item) {
          final int clearTime = item.chatroom.clearedBy[currentUid] ?? 0;
          final int lastMsgTime = item.chatroom.lastMessageTime ?? 0;
          return lastMsgTime > clearTime;
        }).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140.0,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  "Messages",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              actions: [
                _circleIconButton(
                  Icons.person_outline,
                  () => Get.to(
                    () => ProfileView(),
                    transition: Transition.cupertino,
                    duration: const Duration(milliseconds: 350),
                  ),
                ),
                _circleIconButton(Icons.logout_rounded, () async {
                  await authvm.removeFcmTokenOnLogout();
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(() => PhoneLoginView());
                }),
                const SizedBox(width: 12),
              ],
            ),

            /* -------- CHAT LIST (Unified Card Style) -------- */
            if (visibleChats.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = visibleChats[index];
                    final user = item.otheruser;
                    final room = item.chatroom;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFF1F1F1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () => Get.to(
                              () => pageofchat(otherUser: user),
                              transition: Transition.cupertino,
                              duration: Duration(milliseconds: 500),
                            ),
                            onLongPress: () => _showClearChatDialog(
                              context,
                              room.chatId,
                              currentUid,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFF0F3F8),
                                  backgroundImage: user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null,
                                  child: user.profileImageUrl == null
                                      ? Text(
                                          getInitial(user.name),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              user.name.isNotEmpty ? user.name : "Unknown",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                room.lastMessage ?? "Start a conversation",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  room.lastMessageTime != null
                                      ? _formatTime(room.lastMessageTime!)
                                      : "",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: Color(0xFFD1D1D1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: visibleChats.length),
                ),
              ),
          ],
        );
      }),

      /* -------- UNIFIED OBSIDIAN FAB -------- */
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF434343)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Get.to(
            ContactsView(),
            transition: Transition.cupertino,
            duration: Duration(milliseconds: 500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  /* -------- REFINED UI HELPERS -------- */
  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.black87, size: 18),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 70,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            "No conversations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return "${date.day}/${date.month}";
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    return "$hour:$min ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _showClearChatDialog(
    BuildContext context,
    String chatId,
    String currentUid,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text(
                "Clear History",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () async {
                Get.back();
                await FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(chatId)
                    .update({
                      'clearedBy.$currentUid':
                          DateTime.now().millisecondsSinceEpoch,
                    });
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
