import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatpage/chatmessageveiwmodel.dart';
import 'package:my_chat/chatpage/vm.dart'; // Ensure this matches your project structure

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
    // 🎨 DESIGN TOKENS
    const Color accentCyan = Color(0xFF00E5FF);
    const Color textPrimary = Color(0xFFF5F5F7);
    const Color hintColor = Colors.white30;

    return Padding(
      // Padding pushes the pod up from the bottom of the screen
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 35),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            // Ambient deep shadow so the glass separates from the background
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            // 💧 LIQUID BLUR EFFECT
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                // 💧 SPECULAR HIGHLIGHT: Simulates light hitting the curved glass
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.01),
                  ],
                ),
                // 💧 HARDWARE EDGE: Ultra-thin reflection line
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 IMAGE PREVIEW AREA
                  Obx(() {
                    if (chatVM.mediaService.selectedImages.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      height: 90,
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 8,
                        bottom: 4,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chatVM.mediaService.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 12,
                                  top: 6,
                                ),
                                width: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(
                                      chatVM.mediaService.selectedImages[index],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => chatVM
                                      .mediaService
                                      .selectedImages
                                      .removeAt(index),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.redAccent.withOpacity(
                                            0.8,
                                          ), // Glassy red close button
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 📎 ATTACH BUTTON
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () =>
                              chatVM.mediaService.pickImagesFromGallery(),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.image_rounded,
                              color: Colors.white.withOpacity(
                                0.6,
                              ), // Silver icon
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                      // ✨ MAGIC AI BUTTON
                      Obx(
                        () => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: chatVM.isFixingGrammar.value
                                ? null
                                : () => chatVM.fixGrammar(),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: chatVM.isFixingGrammar.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            accentCyan, // Premium loader color
                                      ),
                                    )
                                  : const Icon(
                                      Icons.auto_fix_high_rounded,
                                      color:
                                          accentCyan, // Electric cyan magic wand
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // ✍️ TEXT FIELD
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: TextField(
                            controller: chatVM.messageController,
                            maxLines:
                                4, // Allow up to 4 lines before scrolling internally
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                            cursorColor: accentCyan,
                            decoration: const InputDecoration(
                              hintText: "Message...",
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 🚀 SEND BUTTON
                      Obx(
                        () => GestureDetector(
                          onTap: chatVM.issending.value
                              ? null
                              : () async {
                                  final text = chatVM.messageController.text
                                      .trim();

                                  if (text.isEmpty &&
                                      chatVM
                                          .mediaService
                                          .selectedImages
                                          .isEmpty) {
                                    return;
                                  }

                                  await chatVM.sendMessage(chatId: chatId);

                                  if (scrollController.hasClients) {
                                    scrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves
                                          .easeOutQuart, // Smoother cinematic scroll
                                    );
                                  }
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(
                              bottom: 4,
                              right: 4,
                              left: 4,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF00E5FF),
                                  Color(0xFF0055FF),
                                ], // Neon Cyan to Deep Blue
                              ),
                              boxShadow: [
                                // 🌟 Colored Glow
                                BoxShadow(
                                  color: const Color(
                                    0xFF0055FF,
                                  ).withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: chatVM.issending.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
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
          ),
        ),
      ),
    );
  }
}
