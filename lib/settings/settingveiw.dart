import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/profile/profile.dart';
import 'package:my_chat/settings/otpscreen.dart';
import 'package:my_chat/settings/settingstile.dart';
import 'package:my_chat/settings/settingsveiwmodel.dart'; // Ensure filename matches too!

// 1. Rename to SettingsView (Standard naming)
// 2. Extend GetView to automatically get 'controller'
class SettingsView extends GetView<SettingsViewModel> {
  const SettingsView({super.key});

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
                          () =>  ProfileView(), // Use a closure () =>
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 350),
                        );
                      },
                    ),

                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        // Open privacy policy
                      },
                    ),

                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: "Send Feedback",
                      onTap: () {
                        // Open feedback page
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
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
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
    Get.defaultDialog(
      title: "Logout",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to log out?",
      textConfirm: "Yes, Logout",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1A1A1A),
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.logout();
      },
    );
  }
}