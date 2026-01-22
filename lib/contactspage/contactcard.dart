import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ensure these imports match your project structure
import 'package:my_chat/chatpage/cHATpg.dart'; 
import 'package:my_chat/contactspage/contactusermodel.dart'; // Assuming your model is here

class ContactCard extends StatelessWidget {
  final usermodel user;

  const ContactCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF1F1F1),
          width: 1.5,
        ),
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
            contentPadding: const EdgeInsets.all(16),

            /* -------- AVATAR -------- */
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF0F3F8),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.blueAccent,
                      ),
                    )
                  : null,
            ),

            /* -------- NAME & PHONE -------- */
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.phonenumber,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /* -------- ACTION -------- */
            trailing: Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}