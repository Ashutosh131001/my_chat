import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ViewModels
import 'package:my_chat/auth/auth_veiwmodel.dart';
import 'package:my_chat/chatlist/chatitemcard.dart';
import 'package:my_chat/chatlist/chatlistviewmodel.dart';
import 'package:my_chat/chatlist/circlebutton.dart';
import 'package:my_chat/chatlist/emptystate.dart';

// Pages & Auth
import 'package:my_chat/contactspage/chatlistpage.dart';
import 'package:my_chat/settings/settingveiw.dart';
import 'package:my_chat/veiws/staredmessage.dart'; // Check if this import is needed for ContactsView

// Widgets & Utils

class ChatListPage extends StatelessWidget {
  final Chatlistviewmodel chatListVM = Get.put(Chatlistviewmodel());
  final AuthViewModel authvm = Get.put(AuthViewModel());

  ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (chatListVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blueAccent,
            ),
          );
        }

        // Filter Logic
        final visibleChats = chatListVM.chatList.where((item) {
          final int clearTime = item.chatroom.clearedBy[currentUid] ?? 0;
          final int lastMsgTime = item.chatroom.lastMessageTime ?? 0;
          return lastMsgTime > clearTime;
        }).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /* -------- APP BAR -------- */
            SliverAppBar(
              expandedHeight: 140.0,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: Colors.white,
              flexibleSpace: const FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  "Chats",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              actions: [
                CircleIconButton(
                  icon: Icons.settings,
                  onTap: () {
                    Get.to(
                      () => SettingsView(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 350),
                    );
                  },
                ),

                const SizedBox(width: 12),
              ],
            ),

            /* -------- CHAT LIST -------- */
            if (visibleChats.isEmpty)
              const SliverFillRemaining(child: EmptyChatView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = visibleChats[index];
                    return ChatItemCard(
                      user: item.otheruser,
                      room: item.chatroom,
                      currentUid: currentUid,
                    );
                  }, childCount: visibleChats.length),
                ),
              ),
          ],
        );
      }),

      /* -------- FAB -------- */
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Get.to(
            ContactsView(), // Make sure this matches your project's import
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
