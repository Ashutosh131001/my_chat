import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/vm.dart';
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
    final chatVM = Get.find<Chatmessageveiwmodel>();
    final starVM = Get.find<Staredmessageveiwmodel>();

    // 🎨 DESIGN TOKENS
    const Color surfaceColor = Color(0xFF161A22);
    const Color textPrimary = Color(0xFFF5F5F7);
    const Color destructiveRed = Color(0xFFFF453A);
    const Color cyberGold = Color(0xFFFFD60A); // Premium gold for staring
    const Color mutedAction = Color(
      0xFF8E8E93,
    ); // iOS-style muted grey for local delete

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🛠️ Modern Drag Handle Indicator
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // 🗑️ Delete For Me (Muted/Local Action)
            _buildPremiumActionTile(
              icon: Icons.delete_outline_rounded,
              title: "Delete for me",
              subtitle: "Removes from your device only",
              accentColor: mutedAction,
              onTap: () {
                Get.back();
                chatVM.deleteMessageForMe(chatId: chatId, messageId: messageId);
              },
            ),
            const SizedBox(height: 12),

            // 💥 Delete For Everyone (Destructive Action - Only if sender)
            if (isMe) ...[
              _buildPremiumActionTile(
                icon: Icons.delete_forever_rounded,
                title: "Delete for everyone",
                subtitle: "Permanently removes for all users",
                accentColor: destructiveRed,
                onTap: () {
                  Get.back();
                  chatVM.deleteMessageForEveryone(
                    chatId: chatId,
                    messageId: messageId,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // ⭐ Star Message (Positive Action)
            _buildPremiumActionTile(
              icon: Icons.star_rounded,
              title: "Star message",
              subtitle: "Save to your starred messages",
              accentColor: cyberGold,
              onTap: () {
                Get.back();
                starVM.starMessageById(chatId: chatId, messageId: messageId);

                // ⚡ Premium Dark Snackbar
                Get.snackbar(
                  'Message Starred',
                  'Saved to your bookmarks securely.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFF222834).withOpacity(0.9),
                  colorText: Colors.white,
                  icon: const Icon(Icons.star_rounded, color: cyberGold),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  barBlur: 20,
                  borderWidth: 1,
                  borderColor: Colors.white.withOpacity(0.1),
                );
              },
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.6), // Dim the chat background
      isScrollControlled: true,
    );
  }

  // 💎 Premium Ghost Card Tile Builder
  static Widget _buildPremiumActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tileColor: Colors.white.withOpacity(0.02), // Subtle ghost layer
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: accentColor.withOpacity(
              0.12,
            ), // Colored glass well
            child: Icon(icon, color: accentColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFF5F5F7), // Always crisp white for title
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
