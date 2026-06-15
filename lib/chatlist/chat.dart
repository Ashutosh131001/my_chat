import 'dart:ui'; // 🟢 REQUIRED FOR LIQUID GLASS BLUR
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
import 'package:my_chat/contactspage/chatlistpage.dart'; // Verify this import matches your contacts page path
import 'package:my_chat/settings/settingveiw.dart';
import 'package:my_chat/veiws/staredmessage.dart';

class ChatListPage extends StatelessWidget {
  final Chatlistviewmodel chatListVM = Get.put(Chatlistviewmodel());
  final AuthViewModel authvm = Get.put(AuthViewModel());

  ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // 🎨 THEME CONSTANTS
    const Color bgColor = Color(0xFF0A0C10); // Deep Midnight Charcoal
    const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan
    const Color glassSurface = Color(
      0x66161A22,
    ); // 💧 Smoked Translucent Obsidian

    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(() {
        if (chatListVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: accentCyan),
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
            /* -------- 💧 LIQUID GLASS SLIVER APP BAR -------- */
            SliverAppBar(
              expandedHeight: 140.0,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor:
                  Colors.transparent, // 🟢 Must be transparent for blur to show
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 30,
                    sigmaY: 30,
                  ), // 💧 Heavy fluid blur
                  child: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: const Text(
                      "Chats",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        color: glassSurface,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(
                              0.06,
                            ), // Hairline glass reflection
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
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
                const SizedBox(width: 16),
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

      /* -------- 🚀 GLOWING NEON FAB -------- */
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0055FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Get.to(
            ContactsView(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
