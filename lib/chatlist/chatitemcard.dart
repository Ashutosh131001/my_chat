import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatlist/chatlistutils.dart';
import 'package:my_chat/chatpage/cHATpg.dart'; // Ensure correct path

// Import your models
import 'package:my_chat/contactspage/contactusermodel.dart'; 
import 'package:my_chat/chatpage/chatroommodel.dart'; 

class ChatItemCard extends StatelessWidget {
  final usermodel user;
  final ChatRoomModel room;
  final String currentUid;

  const ChatItemCard({
    super.key,
    required this.user,
    required this.room,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1.5),
        boxShadow: [
          BoxShadow(
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
              duration: const Duration(milliseconds: 500),
            ),
            onLongPress: () => ChatListUtils.showClearChatDialog(
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
                          ChatListUtils.getInitial(user.name),
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
                      border: Border.all(color: Colors.white, width: 2.5),
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
                      ? ChatListUtils.formatTime(room.lastMessageTime!)
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
  }
}