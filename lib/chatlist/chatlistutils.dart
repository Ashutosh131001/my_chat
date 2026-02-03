import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListUtils {
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
                  await FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(chatId) // 👈 This will now be safe
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
