import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/chatpage/cHATpg.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatlist/chatlistutils.dart';

class ChatPreviewDialog extends StatelessWidget {
  final usermodel user;
  final ChatRoomModel room;
  final String currentUid;

  const ChatPreviewDialog({
    super.key,
    required this.user,
    required this.room,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    const Color surfaceColor = Color(0xFF161A22);
    const Color accentCyan = Color(0xFF00E5FF);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* -------- 🖼️ HERO PROFILE IMAGE -------- */
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentCyan, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(
                              ChatListUtils.getInitial(user.name),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              /* -------- 📝 CONTACT INFO -------- */
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LATEST MESSAGE",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            room.lastMessage ?? "Start a conversation",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /* -------- 🚀 ACTION BUTTON -------- */
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.to(() => pageofchat(otherUser: user));
                    },
                    child: Text(
                      "Enter Conversation",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
