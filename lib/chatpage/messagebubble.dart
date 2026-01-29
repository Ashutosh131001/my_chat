import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_chat/chatpage/chatutils.dart';
import 'package:my_chat/chatpage/fullscreenphoto.dart';


class MessageBubble extends StatelessWidget {
  final Map msg;
  final bool isMe;
  final String chatId;
  final String msgId;

  const MessageBubble({
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
              onLongPress: () => ChatUtils.showDeleteOptions(
                  context, chatId, msgId, isMe),
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
                    // 1. IMAGE DISPLAY (Grid Logic)
                    if (hasImage && !isDeleted)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: urls.length == 1
                            ? _buildSingleImage(urls.first) // Single Image
                            : _buildImageGrid(urls), // Multiple Images
                      ),

                    // 2. TEXT DISPLAY
                    if (text.isNotEmpty || isDeleted)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                        child: Text(
                          isDeleted ? "🚫 This message was deleted" : text,
                          style: TextStyle(
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
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 250,
          height: 250,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 250,
              width: 250,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            width: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.red),
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
          // "+X" Overlay for more than 4 images
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
                  Image.network(urls[index], fit: BoxFit.cover),
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

          // Standard Image
          return GestureDetector(
            onTap: () {
              Get.to(
                () => FullScreenImageView(imageUrls: urls, initialIndex: index),
                transition: Transition.fadeIn,
              );
            },
            child: Image.network(
              urls[index],
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(color: Colors.black12);
              },
            ),
          );
        },
      ),
    );
  }
}