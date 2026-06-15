import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/chatutils.dart';
import 'package:my_chat/chatpage/fullscreenphoto.dart';
import 'package:my_chat/chatpage/vm.dart';

class MessageBubble extends StatelessWidget {
  final Map msg;
  final bool isMe;
  final String chatId;
  final String msgId;

  final Chatmessageveiwmodel controller = Get.put(Chatmessageveiwmodel());

  MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatId,
    required this.msgId,
  });

  static const Color surfaceColor = Color(0xFF161A22);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Colors.white54;
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color imagePlaceholder = Color(0xFF222834);

  @override
  Widget build(BuildContext context) {
    bool isDeleted = msg['isDeletedForEveryone'] == true;
    List urls = msg['urls'] ?? [];
    bool hasImage = urls.isNotEmpty;
    String text = msg['text'] ?? "";
    List seenBy = msg['seenBy'] ?? [];
    bool isSeen = seenBy.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              // ⚡ 1. CAPTURE TAP COORDINATES
              onLongPressStart: (details) {
                if (!isDeleted) {
                  HapticFeedback.mediumImpact();
                  _showLiquidContextMenu(context, details.globalPosition);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Color(0xFF0055FF), Color(0xFF0033AA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : surfaceColor,
                  border: isMe
                      ? null
                      : Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 0.5,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(22),
                    topRight: const Radius.circular(22),
                    bottomLeft: Radius.circular(isMe ? 22 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? const Color(0xFF0055FF).withOpacity(0.25)
                          : Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE DISPLAY
                    if (hasImage && !isDeleted)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: urls.length == 1
                            ? _buildSingleImage(urls.first)
                            : _buildImageGrid(urls),
                      ),

                    // TEXT DISPLAY
                    if (text.isNotEmpty || isDeleted)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                        child: Text(
                          isDeleted ? "🚫 This message was deleted" : text,
                          style: GoogleFonts.inter(
                            color: isDeleted
                                ? Colors.white30
                                : (isMe ? Colors.white : textPrimary),
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            fontStyle: isDeleted
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // TIMESTAMP & TICKS
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ChatUtils.formatTime(msg['timestamp'] ?? 0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (isMe && !isDeleted) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: isSeen
                          ? accentCyan
                          : Colors.white.withOpacity(0.2),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------------------------------------------
     🍏 2. iOS-STYLE LIQUID GLASS POPOVER
     ------------------------------------------------------------ */
  void _showLiquidContextMenu(BuildContext context, Offset tapPosition) {
    final screenSize = MediaQuery.of(context).size;

    // Prevent the menu from rendering off the bottom of the screen
    double topOffset = tapPosition.dy;
    if (topOffset > screenSize.height - 220) {
      topOffset = screenSize.height - 220;
    }

    Get.dialog(
      Stack(
        children: [
          // 📍 Position the menu relative to the tap
          Positioned(
            top: topOffset,
            // If it's my message, snap menu to the right. If other, snap left.
            left: isMe ? null : 20,
            right: isMe ? 20 : null,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack, // 🍏 iOS springy pop effect
                tween: Tween(begin: 0.8, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    // Origin of animation matches bubble alignment
                    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                    child: Opacity(
                      opacity: scale.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 220, // Strict iOS-style width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 30,
                        sigmaY: 30,
                      ), // Heavy fluid blur
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(
                            0x99161A22,
                          ), // Translucent obsidian
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (msg['text'] != null &&
                                msg['text'].toString().isNotEmpty) ...[
                              _buildContextMenuItem(
                                icon: Icons.copy_rounded,
                                title: "Copy",
                                color: textPrimary,
                                onTap: () {
                                  Get.back();
                                  Clipboard.setData(
                                    ClipboardData(text: msg['text']),
                                  );
                                },
                              ),
                              _buildDivider(),
                            ],

                            _buildContextMenuItem(
                              icon: Icons.delete_outline_rounded,
                              title: "Delete for Me",
                              color: textPrimary,
                              onTap: () {
                                Get.back();
                                controller.deleteMessageForMe(
                                  chatId: chatId,
                                  messageId: msgId,
                                );
                              },
                            ),

                            if (isMe) ...[
                              _buildDivider(),
                              _buildContextMenuItem(
                                icon: Icons.delete_forever_rounded,
                                title: "Delete for Everyone",
                                color: const Color(0xFFFF453A), // Cyber Red
                                onTap: () {
                                  Get.back();
                                  controller.deleteMessageForEveryone(
                                    chatId: chatId,
                                    messageId: msgId,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.15), // Very light dim
      transitionDuration: Duration.zero, // We handle animation manually above
    );
  }

  // 💎 Helper: Individual Menu Item
  Widget _buildContextMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // 💎 Helper: Ultra-thin Divider
  Widget _buildDivider() {
    return Container(height: 0.5, color: Colors.white.withOpacity(0.08));
  }

  /* ------------------------------------------------------------
     🖼️ IMAGE HELPERS 
     ------------------------------------------------------------ */

  Widget _buildSingleImage(String url) {
    return GestureDetector(
      onTap: () => Get.to(
        () => FullScreenImageView(imageUrls: [url], initialIndex: 0),
        transition: Transition.fadeIn,
      ),
      child: Hero(
        tag: url,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: 250,
          height: 250,
          placeholder: (context, url) => Container(
            height: 250,
            width: 250,
            color: imagePlaceholder,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentCyan,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 250,
            width: 250,
            color: imagePlaceholder,
            child: const Icon(
              Icons.broken_image_rounded,
              color: Colors.white30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List urls) {
    return SizedBox(
      width: 250,
      height: urls.length > 2 ? 250 : 125,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: urls.length > 4 ? 4 : urls.length,
        itemBuilder: (context, index) {
          if (index == 3 && urls.length > 4) {
            return GestureDetector(
              onTap: () => Get.to(
                () => FullScreenImageView(imageUrls: urls, initialIndex: index),
                transition: Transition.fadeIn,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: urls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: imagePlaceholder),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        "+${urls.length - 3}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return GestureDetector(
            onTap: () => Get.to(
              () => FullScreenImageView(imageUrls: urls, initialIndex: index),
              transition: Transition.fadeIn,
            ),
            child: CachedNetworkImage(
              imageUrl: urls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: imagePlaceholder),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}
