import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/cHATpg.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagebubble.dart';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          height: 400,
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF161A22).withOpacity(0.9), // Obsidian
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // 💧 Preview Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),

              // 💬 Preview Area
              Expanded(
                child: Center(
                  child: Text(
                    "Latest Message: \n\"${room.lastMessage ?? 'No messages'}\"",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              // 🚀 Enter Chat Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.to(() => pageofchat(otherUser: user));
                    },
                    child: const Text(
                      "Enter Chat",
                      style: TextStyle(color: Colors.black),
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
