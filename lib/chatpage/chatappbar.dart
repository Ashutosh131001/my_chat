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
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(
                      () => OtherUserProfileView(userid: otherUser.uid),
                      transition: Transition.cupertino,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF0F3F8),
                          backgroundImage: otherUser.profileImageUrl != null
                              ? NetworkImage(otherUser.profileImageUrl!)
                              : null,
                          child: otherUser.profileImageUrl == null
                              ? Text(
                                  otherUser.name[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2), // Small gap
                              // 🔥 LIVE PRESENCE STREAM
                              PresenceBuilder(
                                userId: otherUser.uid,
                                builder: (isOnline, lastSeen) {
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 3,
                                        backgroundColor: isOnline
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isOnline
                                            ? "Online"
                                            : ChatUtils.formatLastSeen(
                                                lastSeen,
                                              ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isOnline
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.w800,
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
                IconButton(
                  icon: const Icon(
                    Icons.videocam_outlined,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Get.snackbar('Sorry', "Feature under progress");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
