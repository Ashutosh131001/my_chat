import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_chat/auth/auth_veiwmodel.dart'; // Keep your existing filename
import 'package:my_chat/auth/login_veiw.dart'; // Keep your existing filename
import 'package:my_chat/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚠️ FIX 1: Make this lazy or fetch it when needed to avoid "AuthViewModel not found" crashes
  // if SettingsViewModel loads before AuthViewModel.
  AuthViewModel get _authVM => Get.find<AuthViewModel>();

  final isLoading = false.obs; // Standard naming camelCase
  String? _verificationId;

  /* ---------------- LOGOUT ---------------- */
  Future<void> logout() async {
    try {
      isLoading.value = true;

      if (_auth.currentUser == null) return;

      // Remove token before signing out
      await _authVM.removeFcmTokenOnLogout();
      await _auth.signOut();

      Get.offAll(() => PhoneLoginView());
    } catch (e) {
      Utils.showsnackbar(
        message: "Logout failed: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /* ---------------- SEND OTP FOR DELETE ---------------- */
  Future<void> requestDeleteAccountOtp() async {
    final user = _auth.currentUser;

    if (user == null || user.phoneNumber == null) {
      Utils.showsnackbar(
        message: "Unable to verify phone number",
        type: SnackbarType.error,
      );
      return;
    }

    isLoading.value = true;

    await _auth.verifyPhoneNumber(
      phoneNumber: user.phoneNumber!,

      // Auto-resolution (Android mostly)
      verificationCompleted: (credential) async {
        await _reauthenticateAndDelete(credential);
        isLoading.value = false; // Ensure loading stops
      },

      // ⚠️ FIX 2: Handle Errors Correctly
      verificationFailed: (e) {
        isLoading.value = false; // CRITICAL: Stop the spinner!
        Utils.showsnackbar(
          message: e.message ?? "Verification failed",
          type: SnackbarType.error,
        );
      },

      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        isLoading.value = false; // Stop spinner so user can enter OTP

        // Optional: Show success message
        Utils.showsnackbar(message: "OTP Sent", type: SnackbarType.success);
      },

      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        isLoading.value = false;
      },
    );
  }

  /* ---------------- VERIFY OTP & DELETE ---------------- */
  Future<void> verifyOtpAndDeleteAccount(String otp) async {
    if (_verificationId == null) {
      Utils.showsnackbar(
        message: "Please request OTP first",
        type: SnackbarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _reauthenticateAndDelete(credential);
    } catch (e) {
      Utils.showsnackbar(
        message: "Invalid OTP or Error: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /* ---------------- FINAL DELETE ---------------- */
  Future<void> _reauthenticateAndDelete(AuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // 1. Re-authenticate (Required for sensitive operations like delete)
      await user.reauthenticateWithCredential(credential);

      // 2. Delete User Data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // 3. Delete Auth Account
      await user.delete();

      // 4. Redirect
      Get.offAll(() => PhoneLoginView());
    } catch (e) {
      Utils.showsnackbar(
        message: "Delete failed: $e",
        type: SnackbarType.error,
      );
      // If error happens here, we must stop loading manually since this is called from callbacks
      isLoading.value = false;
    }
  }

  void openPrivacyPolicy() async {
    final url = Uri.parse(
      "https://raw.githubusercontent.com/Ashutosh131001/MyChat_PrivacyPolicy/main/MyChat_Privacy_Policy.pdf",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open Privacy Policy");
    }
  }
}
