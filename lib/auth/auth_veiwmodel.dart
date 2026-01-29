import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_chat/auth/auth_model.dart';
import 'package:my_chat/chatlist/chat.dart';
import 'package:my_chat/auth/otpscreen.dart';
import 'package:my_chat/auth/user_detail_page.dart';

class AuthViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  var phoneAuthModel = AuthModel(phonenumber: '').obs;
  final phoneController = TextEditingController();
  final isLoading = false.obs;

  /* ---------------- SEND OTP ---------------- */
  Future<void> verifyPhoneNumber() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Enter phone number');
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',

      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        await _handlePostLogin();
      },

      verificationFailed: (e) {
        Get.snackbar('Error', e.message ?? 'Verification failed');
      },

      codeSent: (verificationId, _) {
        phoneAuthModel.value = phoneAuthModel.value.copywith(
          phonenumber: phone,
          verificationid: verificationId,
        );
        Get.to(() => OTPVerifyView(verificationId: verificationId));
      },

      codeAutoRetrievalTimeout: (verificationId) {
        phoneAuthModel.value = phoneAuthModel.value.copywith(
          verificationid: verificationId,
        );
      },
    );
  }

  /* ---------------- VERIFY OTP ---------------- */
  Future<void> verifyOTP(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: phoneAuthModel.value.verificationid!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _handlePostLogin();
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  /* ---------------- POST LOGIN DECISION ---------------- */
  Future<void> _handlePostLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      // 🔥 NEW USER
      Get.offAll(() => UserDetailsView());
    } else {
      // 🔥 EXISTING USER
      Get.offAll(() => ChatListPage());
    }
  }

  Future<void> removeFcmTokenOnLogout() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
