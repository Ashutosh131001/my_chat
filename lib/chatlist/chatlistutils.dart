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

  // Show Clear Chat Dialog
  static void showClearChatDialog(
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

                if (chatId.isNotEmpty) {
                  // 🟢 1. OPTIMISTIC UI UPDATE (Instant Deletion)
                  // Find the active controller and wipe this chat from the screen instantly
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
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
