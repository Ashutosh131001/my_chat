import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/viewmodels/staredmessageveiwmodel.dart';

class ChatUtils {
  // Format Time (e.g., "10:30 PM")
  static String formatTime(int timestamp) {
    if (timestamp == 0) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    return "$hour:$min ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  // Format Last Seen
  static String formatLastSeen(int timestamp) {
    if (timestamp == 0) return "Offline";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Last seen just now";
    if (diff.inMinutes < 60) return "Last seen ${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "Last seen ${diff.inHours}h ago";
    return "Last seen offline";
  }

  // Show Delete/Star Options Bottom Sheet
  static void showDeleteOptions(
    BuildContext context,
    String chatId,
    String messageId,
    bool isMe,
  ) {
    // Retrieve instances using Get.find since they are already initialized
    final chatVM = Get.find<Chatmessageveiwmodel>();
    final starVM = Get.find<Staredmessageveiwmodel>();

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
            _buildActionTile(
              Icons.star,
              "Star the message",
              Colors.black87,
              () {
                Get.back();
                starVM.starMessageById(chatId: chatId, messageId: messageId);
                Get.snackbar('Success', 'The message is starred');
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildActionTile(
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