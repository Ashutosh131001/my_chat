import 'dart:ui'; // Required for ImageFilter (Glass Effect)
import 'package:cached_network_image/cached_network_image.dart'; // 🟢 NEW IMPORT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for HapticFeedback & Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/chatutils.dart';
import 'package:my_chat/chatpage/fullscreenphoto.dart';

class MessageBubble extends StatelessWidget {
  final Map msg;
  final bool isMe;
  final String chatId;
  final String msgId;

  // 🟢 Inject Controller
  final Chatmessageveiwmodel controller = Get.find<Chatmessageveiwmodel>();

  MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatId,
    required this.msgId,
  });

  @override
  Widget build(BuildContext context) {
    bool isDeleted = msg['isDeletedForEveryone'] == true;

    // Get the list of URLs
    List urls = msg['urls'] ?? [];
    bool hasImage = urls.isNotEmpty;
    String text = msg['text'] ?? "";

    List seenBy = msg['seenBy'] ?? [];
    bool isSeen = seenBy.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              // 🟢 PREMIUM LONG PRESS ACTION
              onLongPress: () {
                if (!isDeleted) {
                  HapticFeedback.mediumImpact(); // 📳 Vibration
                  _showPremiumOptions(context);
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
                          colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Colors.white, Color(0xFFFDFDFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 5),
                    bottomRight: Radius.circular(isMe ? 5 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? Colors.blueAccent.withOpacity(0.2)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. IMAGE DISPLAY (Updated with Caching)
                    if (hasImage && !isDeleted)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: urls.length == 1
                            ? _buildSingleImage(urls.first)
                            : _buildImageGrid(urls),
                      ),

                    // 2. TEXT DISPLAY
                    if (text.isNotEmpty || isDeleted)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                        child: Text(
                          isDeleted ? "🚫 This message was deleted" : text,
                          style: GoogleFonts.poppins(
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF2D3436),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isMe && !isDeleted) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded,
                      size: 15,
                      color: isSeen ? Colors.blueAccent : Colors.grey.shade400,
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
     💎 PREMIUM GLASSMORPHISM SHEET (Delete Options)
     ------------------------------------------------------------ */
  void _showPremiumOptions(BuildContext context) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FD),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              if (isMe)
                _buildPremiumAction(
                  icon: Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  label: "Delete for Everyone",
                  subtitle: "Remove from all devices",
                  onTap: () {
                    Get.back();
                    controller.deleteMessageForEveryone(
                      chatId: chatId,
                      messageId: msgId,
                    );
                  },
                  isDanger: true,
                ),

              _buildPremiumAction(
                icon: Icons.delete_outline_rounded,
                color: Colors.orangeAccent,
                label: "Delete for Me",
                subtitle: "Remove only from this device",
                onTap: () {
                  Get.back();
                  controller.deleteMessageForMe(
                    chatId: chatId,
                    messageId: msgId,
                  );
                },
              ),

              if (msg['text'] != null && msg['text'].toString().isNotEmpty)
                _buildPremiumAction(
                  icon: Icons.copy_rounded,
                  color: Colors.blueAccent,
                  label: "Copy Text",
                  subtitle: "Copy to clipboard",
                  onTap: () {
                    Get.back();
                    Clipboard.setData(ClipboardData(text: msg['text']));
                    Get.snackbar(
                      "Copied",
                      "Text copied to clipboard",
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(10),
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1),
                    );
                  },
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildPremiumAction({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDanger
              ? Border.all(color: color.withOpacity(0.1), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------------------------------------------
     🖼️ IMAGE HELPERS (Updated with CachedNetworkImage)
     ------------------------------------------------------------ */

  Widget _buildSingleImage(String url) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => FullScreenImageView(imageUrls: [url], initialIndex: 0),
          transition: Transition.fadeIn,
        );
      },
      child: Hero(
        tag: url,
        child: CachedNetworkImage(
          // 🟢 USES DISK CACHE NOW
          imageUrl: url,
          fit: BoxFit.cover,
          width: 250,
          height: 250,
          // Smooth loading placeholder
          placeholder: (context, url) => Container(
            height: 250,
            width: 250,
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          // Error widget (e.g. if offline and never downloaded)
          errorWidget: (context, url, error) => Container(
            height: 250,
            width: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
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
              onTap: () {
                Get.to(
                  () =>
                      FullScreenImageView(imageUrls: urls, initialIndex: index),
                  transition: Transition.fadeIn,
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    // 🟢 USES DISK CACHE
                    imageUrl: urls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.black12),
                  ),
                  Container(
                    color: Colors.black54,
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
            onTap: () {
              Get.to(
                () => FullScreenImageView(imageUrls: urls, initialIndex: index),
                transition: Transition.fadeIn,
              );
            },
            child: CachedNetworkImage(
              // 🟢 USES DISK CACHE
              imageUrl: urls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}
