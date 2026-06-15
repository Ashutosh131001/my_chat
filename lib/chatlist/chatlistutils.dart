import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:my_chat/chatlist/chatlistviewmodel.dart';

class ChatListUtils {
  final Chatlistviewmodel vm = Get.put(Chatlistviewmodel());

  // Get Initials (e.g., "Ashutosh" -> "A")
  static String getInitial(String? name) =>
      (name == null || name.isEmpty) ? "?" : name[0].toUpperCase();

  // Format Time (e.g., "10:30 PM" or "22/10")
  static String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return "${date.day}/${date.month}";
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    return "$hour:$min ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  // Show Clear Chat Dialog (Redesigned for Premium Dark Theme)
  static void showClearChatDialog(
    BuildContext context,
    String chatId,
    String currentUid,
  ) {
    // 🎨 DESIGN TOKENS
    const Color surfaceColor = Color(0xFF161A22); // Obsidian Surface Base
    const Color textPrimary = Color(0xFFF5F5F7); // Clean Off-White
    const Color destructiveRed = Color(0xFFFF453A); // Premium Cyber Coral Red

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          // Subtle highlight on the top lip of the sheet to separate from the background
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
                color: Colors.white.withOpacity(0.2), // Translucent and clean
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Redestructive Option Card
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Colors.white.withOpacity(
                    0.02,
                  ), // Ghost card surface
                  leading: CircleAvatar(
                    backgroundColor: destructiveRed.withOpacity(
                      0.12,
                    ), // Deep ruby glass well
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: destructiveRed,
                    ),
                  ),
                  title: const Text(
                    "Clear Chat History",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Wipes local cache and resets conversation feed",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    Get.back();

                    if (chatId.isNotEmpty) {
                      // 🟢 1. OPTIMISTIC UI UPDATE (Instant Deletion)
                      try {
                        final vm = Get.find<Chatlistviewmodel>();
                        vm.chatList.removeWhere(
                          (item) => item.chatroom.chatId == chatId,
                        );
                      } catch (e) {
                        print("VM not found: $e");
                      }

                      // 🟢 2. Instantly wipe the local messages cache
                      final boxName = 'chat_messages_$chatId';
                      try {
                        if (Hive.isBoxOpen(boxName)) {
                          await Hive.box(boxName).clear();
                        } else {
                          await Hive.deleteBoxFromDisk(boxName);
                        }
                      } catch (e) {
                        print("Error clearing local box: $e");
                      }

                      // 🟢 3. Update Firebase (Happens silently in the background)
                      await FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(chatId)
                          .set({
                            'clearedBy': {
                              currentUid: DateTime.now().millisecondsSinceEpoch,
                            },
                          }, SetOptions(merge: true));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.6), // Rich background dimming
      isDismissible: true,
      enableDrag: true,
    );
  }
}
