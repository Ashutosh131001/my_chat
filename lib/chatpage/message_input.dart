
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';

class InputPod extends StatelessWidget {
  final String chatId;
  final Chatmessageveiwmodel chatVM;
  final ScrollController scrollController;

  const InputPod({
    super.key,
    required this.chatId,
    required this.chatVM,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 IMAGE PREVIEW AREA
            Obx(() {
              if (chatVM.selectedImages.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 100,
                padding: const EdgeInsets.only(bottom: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatVM.selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            right: 10,
                            left: 5,
                            top: 5,
                          ),
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: FileImage(chatVM.selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              chatVM.selectedImages.removeAt(index);
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.redAccent,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),

            // 🔹 STANDARD INPUT ROW
            Row(
              children: [
                const SizedBox(width: 5),
                // 📎 ATTACH BUTTON
                InkWell(
                  onTap: () {
                    chatVM.pickImagesFromGallery();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                // SEND BUTTON
                Obx(
                  () => GestureDetector(
                    onTap: chatVM.issending.value
                        ? null
                        : () async {
                            final text = messageController.text.trim();

                            // Prevent empty sends (must have Text OR Images)
                            if (text.isEmpty && chatVM.selectedImages.isEmpty) {
                              return;
                            }

                            messageController.clear();

                            await chatVM.sendMessage(
                              chatId: chatId,
                              text: text,
                            );

                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: chatVM.issending.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}