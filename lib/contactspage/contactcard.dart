import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🟢 Required for Haptic Feedback
import 'package:get/get.dart';
import 'package:my_chat/chatpage/cHATpg.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';

// 🟢 Converted to StatefulWidget to handle the press animation
class ContactCard extends StatefulWidget {
  final usermodel user;

  const ContactCard({super.key, required this.user});

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  // 🟢 State tracking for the shrink animation
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 🎨 DESIGN TOKENS
    const Color surfaceColor = Color(0xFF161A22); // Premium Obsidian Surface
    const Color textPrimary = Color(0xFFF5F5F7); // Crisp Off-White
    const Color textSecondary = Colors.white54; // Muted Silver Grey
    const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan

    return AnimatedScale(
      // ⚡ Smooth shrink effect when pressed
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutQuart,
      child: Listener(
        // ⚡ Detects physical touch instantly
        onPointerDown: (_) {
          HapticFeedback.lightImpact(); // Subtle physical vibration
          setState(() => _isPressed = true);
        },
        // ⚡ Restores size when touch ends or cancels
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            // 💧 Hairline reflective border
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
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
                  () => pageofchat(
                    otherUser: widget.user,
                  ), // Note: using widget.user
                  transition: Transition.cupertino,
                  duration: const Duration(milliseconds: 500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                /* -------- 🖼️ AVATAR -------- */
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.04), // Glass well
                  backgroundImage: widget.user.profileImageUrl != null
                      ? NetworkImage(widget.user.profileImageUrl!)
                      : null,
                  child: widget.user.profileImageUrl == null
                      ? Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: accentCyan,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),

                /* -------- 📝 NAME & PHONE -------- */
                title: Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.user.phonenumber,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                /* -------- ⚡ ACTION BUTTON -------- */
                trailing: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: accentCyan.withOpacity(
                      0.08,
                    ), // Soft cyan glowing container
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentCyan.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    size: 16,
                    color: accentCyan,
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
