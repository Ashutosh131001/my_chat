import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_chat/feedback/sendfeedback.dart';
import 'package:my_chat/profile/profile.dart';
import 'package:my_chat/settings/otpscreen.dart';
import 'package:my_chat/settings/settingstile.dart';
import 'package:my_chat/settings/settingsveiwmodel.dart';

class SettingsView extends GetView<SettingsViewModel> {
  SettingsView({super.key});
  final SettingsViewModel vm = Get.put(SettingsViewModel());

  // 🎨 DESIGN TOKENS
  static const Color bgCanvas = Color(0xFF0A0C10); // Deep Premium Void
  static const Color surfaceColor = Color(0xFF161A22); // Obsidian Dialogs
  static const Color textPrimary = Color(0xFFF5F5F7); // Crisp Off-White
  static const Color glassSurface = Color(0x66161A22); // Liquid Glass
  static const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color cyberRed = Color(0xFFFF453A); // Premium Destructive Red

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsViewModel());

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /* ---------------- 💧 LIQUID GLASS APP BAR ---------------- */
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 140.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 30,
                      sigmaY: 30,
                    ), // Heavy blur
                    child: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                      title: const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          color: glassSurface,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(
                                0.06,
                              ), // Hardware edge
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
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
                      icon: Icons.person_outline_rounded,
                      title: "Profile",
                      onTap: () {
                        Get.to(
                          () => ProfileView(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 350),
                        );
                      },
                    ),

                    SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: "Notification Settings",
                      onTap: () {
                        controller.handleManualNotificationToggle();
                      },
                    ),

                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        vm.openPrivacyPolicy();
                      },
                    ),

                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: "Send Feedback",
                      onTap: () {
                        Get.to(() => FeedbackPage());
                      },
                    ),

                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      onTap: () => _showLogoutDialog(context),
                    ),

                    // 🔥 DANGER ZONE SEPARATOR
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "DANGER ZONE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: cyberRed.withOpacity(0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      title: "Delete Account",
                      iconColor: cyberRed,
                      textColor: cyberRed,
                      onTap: () {
                        controller.requestDeleteAccountOtp();
                        Get.dialog(
                          DeleteAccountOtpDialog(), // Make sure this dialog is dark themed too!
                          barrierDismissible: false,
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),

          /* ---------------- 💎 PREMIUM LOADING OVERLAY ---------------- */
          Obx(() {
            return controller.isLoading.value
                ? Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ), // Blurs the background while loading
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: accentCyan,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🚪 PREMIUM OBSIDIAN LOGOUT DIALOG
  // ----------------------------------------------------------------------
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ), // Heavy blur for focus
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: surfaceColor, // Obsidian Base
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ), // Glass reflection
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Glowing Cyber Red Icon
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cyberRed.withOpacity(0.1), // Translucent red well
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cyberRed.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .power_settings_new_rounded, // Slightly more aggressive logout icon
                    color: cyberRed,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Title & Subtitle
                Text(
                  "Disconnect Session",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to end your secure session? You will need to authenticate again to access your messages.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Action Buttons
                Row(
                  children: [
                    // Premium Ghost Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(
                            0.05,
                          ), // Ghostly background
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Destructive Cyber Red Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cyberRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: cyberRed.withOpacity(0.4),
                        ),
                        child: Text(
                          "Disconnect",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeOutQuart,
    );
  }
}
