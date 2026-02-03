import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/feedback/sendfeedback.dart';
import 'package:my_chat/profile/profile.dart';
import 'package:my_chat/settings/otpscreen.dart';
import 'package:my_chat/settings/settingstile.dart';
import 'package:my_chat/settings/settingsveiwmodel.dart'; // Ensure filename matches too!

// 1. Rename to SettingsView (Standard naming)
// 2. Extend GetView to automatically get 'controller'
class SettingsView extends GetView<SettingsViewModel> {
  SettingsView({super.key});
  final SettingsViewModel vm = Get.put(SettingsViewModel());

  @override
  Widget build(BuildContext context) {
    // If not using bindings, inject it here.
    // Ideally, use a Binding class, but this is fine for now.
    Get.put(SettingsViewModel());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      // 3. Stack allows us to overlay the loading spinner on top
      // instead of replacing the whole screen (looks smoother)
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /* ---------------- APP BAR ---------------- */
              SliverAppBar(
                expandedHeight: 140.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.6,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1A1A1A),
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
              ),

              /* ---------------- SETTINGS LIST ---------------- */
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SettingsTile(
                      icon: Icons.person_outline,
                      title: "Profile",
                      onTap: () {
                        Get.to(
                          () => ProfileView(), // Use a closure () =>
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 350),
                        );
                      },
                    ),

                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        vm.openPrivacyPolicy();
                        // Open privacy policy
                      },
                    ),

                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: "Send Feedback",
                      onTap: () {
                        Get.to(FeedbackPage());
                      },
                    ),

                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      onTap: () => _showLogoutDialog(context),
                    ),

                    // 🔥 DANGER ZONE SEPARATOR
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.grey.shade200),
                    ),

                    SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      title: "Delete Account",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () {
                        // 4. Trigger OTP request first
                        controller.requestDeleteAccountOtp();

                        // 5. Open the dialog
                        Get.dialog(
                          DeleteAccountOtpDialog(),
                          barrierDismissible: false,
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),

          /* ---------------- LOADING OVERLAY ---------------- */
          // This sits ON TOP of the scroll view.
          // Only this part rebuilds when isLoading changes.
          Obx(() {
            return controller.isLoading.value
                ? Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Helper for Logout Confirmation
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // Blur background
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Hug content
              children: [
                // 1. Icon with soft background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Title & Subtitle
                Text(
                  "Log Out",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to end your session? You will need to login again.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 25),

                // 3. Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Logout Button (Red)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: Colors.redAccent.withOpacity(0.4),
                        ),
                        child: Text(
                          "Yes, Logout",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      // Animation Settings
      transitionDuration: const Duration(milliseconds: 250),
      transitionCurve: Curves.easeOutBack,
    );
  }
}
