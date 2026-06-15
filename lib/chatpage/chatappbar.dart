import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatutils.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/controllers/prescensebuilder.dart';
import 'package:my_chat/profile/otheruserprofileveiw.dart';

class ChatHeader extends StatelessWidget {
  final usermodel otherUser;

  const ChatHeader({super.key, required this.otherUser});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFFF5F5F7);
    const Color textSecondary = Colors.white54;
    const Color accentCyan = Color(0xFF00E5FF);

    return Container(
      height: 80, // Slightly taller for that fluid, breathable look
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40), // Perfect fluid pill shape
        // 💧 1. SPECULAR HIGHLIGHT: Mimics light hitting liquid glass
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12), // Bright reflection on top-left
            Colors.white.withOpacity(0.01), // Fades to nearly invisible
          ],
        ),
        // 💧 2. LIQUID EDGE: A hairline reflective border
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
        boxShadow: [
          // Deep, soft shadow to make the liquid pop off the screen
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          // 💧 3. EXTREME BLUR: Creates the thick crystal/water distortion
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(
                      () => OtherUserProfileView(user: otherUser),
                      transition: Transition.cupertino,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(
                              0.05,
                            ), // Glass well for avatar
                            backgroundImage: otherUser.profileImageUrl != null
                                ? NetworkImage(otherUser.profileImageUrl!)
                                : null,
                            child: otherUser.profileImageUrl == null
                                ? Text(
                                    otherUser.name.isNotEmpty
                                        ? otherUser.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: accentCyan,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUser.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                PresenceBuilder(
                                  userId: otherUser.uid,
                                  builder: (isOnline, lastSeen) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isOnline
                                                ? accentCyan
                                                : Colors.white24,
                                            boxShadow: isOnline
                                                ? [
                                                    BoxShadow(
                                                      color: accentCyan
                                                          .withOpacity(0.6),
                                                      blurRadius: 6,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isOnline
                                              ? "Online"
                                              : ChatUtils.formatLastSeen(
                                                  lastSeen,
                                                ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOnline
                                                ? accentCyan
                                                : textSecondary,
                                            fontWeight: isOnline
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
