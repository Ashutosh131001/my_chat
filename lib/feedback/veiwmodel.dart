import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackViewModel extends GetxController {
  // Logic Variables
  final TextEditingController textController = TextEditingController();
  var isSubmitting = false.obs; // Observable for loading state

  // 1. Submit to Firestore
  Future<void> submitFeedback() async {
    // Hide Keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    final text = textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        "Empty",
        "Please type some feedback first.",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Create the data packet
      final feedbackData = {
        'uid': user?.uid ?? 'anonymous',
        'email': user?.email ?? 'unknown',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'version': '1.0.0+2', // Ideally fetch this using package_info_plus
        'status': 'open',
      };

      await FirebaseFirestore.instance
          .collection('app_feedback')
          .add(feedbackData);

      // Success Reset
      textController.clear();
      Get.back(); // Close the page

      Get.snackbar(
        "Received!",
        "Thanks for helping us improve.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 20,
      );
    } catch (e) {
      Get.snackbar("Error", "Could not send feedback. Try again.");
    } finally {
      isSubmitting.value = false;
    }
  }

  // 2. Open Email App
  void openEmailFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ashutoshbhardwaj822026@gmail.com', // ⚠️ CHANGE THIS TO YOUR EMAIL
      query: 'subject=MyChat Feedback&body=Describe your issue here:',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar("Error", "Could not open email client");
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
