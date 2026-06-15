import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatlist/chatlistutils.dart';
import 'package:my_chat/chatlist/preveiw.dart';
import 'package:my_chat/chatpage/cHATpg.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';

class ChatItemCard extends StatefulWidget {
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
  State<ChatItemCard> createState() => _ChatItemCardState();
}

class _ChatItemCardState extends State<ChatItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color surfaceColor = Color(0xFF161A22);
    const Color accentCyan = Color(0xFF00E5FF);
    const Color textPrimary = Color(0xFFF5F5F7);
    final Color textSecondary = Colors.white.withOpacity(0.6);
    const Color cyberRed = Color(0xFFFF453A);

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutQuart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Slidable(
          key: ValueKey(widget.room.chatId),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (context) {
                  HapticFeedback.heavyImpact();
                  ChatListUtils.showClearChatDialog(
                    context,
                    widget.room.chatId,
                    widget.currentUid,
                  );
                },
                backgroundColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: cyberRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: cyberRed.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: cyberRed,
                        size: 26,
                      ),
                      Text(
                        "Clear",
                        style: TextStyle(
                          color: cyberRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: Listener(
            onPointerDown: (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            },
            onPointerUp: (_) => setState(() => _isPressed = false),
            onPointerCancel: (_) => setState(() => _isPressed = false),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () => Get.to(
                      () => pageofchat(otherUser: widget.user),
                      transition: Transition.cupertino,
                    ),
                    onLongPress: () {
                      HapticFeedback.heavyImpact();
                      // 🟢 Triggering the Liquid Glass Preview
                      Get.dialog(
                        ChatPreviewDialog(
                          user: widget.user,
                          room: widget.room,
                          currentUid: widget.currentUid,
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF222834),
                      backgroundImage: widget.user.profileImageUrl != null
                          ? NetworkImage(widget.user.profileImageUrl!)
                          : null,
                      child: widget.user.profileImageUrl == null
                          ? Text(
                              ChatListUtils.getInitial(widget.user.name),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: accentCyan,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        widget.room.lastMessage ?? "Start a conversation",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
