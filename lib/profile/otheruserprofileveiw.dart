import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your models
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatlist/user_model.dart';
import 'package:my_chat/profile/otheruserprofileveiwmodel.dart';

class OtherUserProfileView extends StatefulWidget {
  final usermodel user;

  const OtherUserProfileView({super.key, required this.user});

  @override
  State<OtherUserProfileView> createState() => _OtherUserProfileViewState();
}

class _OtherUserProfileViewState extends State<OtherUserProfileView> {
  final OtherUserProfileViewModel vm = Get.put(OtherUserProfileViewModel());

  // 🎨 DESIGN TOKENS
  static const Color bgCanvas = Color(0xFF0A0C10); // Deep Midnight Charcoal
  static const Color surfaceColor = Color(0xFF161A22); // Obsidian Surface
  static const Color textPrimary = Color(0xFFF5F5F7); // Crisp Off-White
  static const Color textSecondary = Colors.white54; // Muted Silver
  static const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color cyberRed = Color(0xFFFF453A); // Premium Destructive Red
  static const Color neonGreen = Color(0xFF39FF14); // Tech Green for Calls

  @override
  void initState() {
    super.initState();
    vm.loadFromLocal(widget.user);
    vm.fetchUser(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGhostBackButton(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        final UserModel user =
            vm.user.value ??
            UserModel(
              uid: widget.user.uid,
              phoneNumber: widget.user.phonenumber,
              name: widget.user.name,
              about: widget.user.about,
              profileImageUrl: widget.user.profileImageUrl,
              isOnline: false,
              createdAt: 0,
            );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /* -------- 🌟 AMBIENT GLOW HEADER -------- */
              Stack(
                alignment: Alignment.center,
                children: [
                  // Deep Ambient Top Glow
                  Container(
                    height: 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.6),
                        radius: 1.2,
                        colors: [
                          accentCyan.withOpacity(0.12), // Cyan studio light
                          bgCanvas, // Fades to absolute dark
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 110),

                      // 🖼️ Premium Avatar Well
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surfaceColor,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.08,
                            ), // Hardware edge
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentCyan.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: const Color(0xFF222834), // Dark core
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(
                                  (user.name != null && user.name!.isNotEmpty)
                                      ? user.name![0].toUpperCase()
                                      : "?",
                                  style: GoogleFonts.inter(
                                    fontSize: 55,
                                    fontWeight: FontWeight.w900,
                                    color: accentCyan,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 📝 Name
                      Text(
                        user.name ?? "Unknown",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🏷️ Glass Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentCyan.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentCyan.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          "Secure Contact",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /* -------- 🚀 TACTILE ACTION BUTTON -------- */
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _GlowingActionButton(onTap: () => Get.back()),
              ),

              const SizedBox(height: 10),

              /* -------- 1. ABOUT SECTION (Ghost Card) -------- */
              _buildPremiumGhostCard(
                title: "ABOUT",
                content: user.about ?? "Hey there! I am using MyChat.",
                icon: Icons.info_outline_rounded,
                accentColor: accentCyan,
              ),

              /* -------- 2. CONTACT DETAILS (Ghost Card) -------- */
              _buildContactDetailsCard(user.phoneNumber),

              /* -------- 3. E2E SECURITY BADGE -------- */
              _buildSecurityBadge(),

              const SizedBox(height: 20),

              /* -------- 4. REPORT / DANGER ZONE -------- */
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Get.snackbar(
                    "Report Submitted",
                    "We will review this user securely.",
                    backgroundColor: surfaceColor.withOpacity(0.9),
                    colorText: Colors.white,
                    icon: const Icon(Icons.shield_rounded, color: cyberRed),
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(20),
                    barBlur: 20,
                    borderColor: Colors.white.withOpacity(0.1),
                    borderWidth: 1,
                  );
                },
                icon: const Icon(Icons.flag_rounded, color: cyberRed, size: 20),
                label: Text(
                  "Block or Report User",
                  style: GoogleFonts.inter(
                    color: cyberRed,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: cyberRed.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  // 💎 Helper: Top Back Button
  Widget _buildGhostBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
    );
  }

  // 💎 Helper: Standard Ghost Card
  Widget _buildPremiumGhostCard({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: textPrimary,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // 💎 Helper: Contact Specific Card
  Widget _buildContactDetailsCard(String phoneNumber) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_iphone_rounded,
                size: 18,
                color: neonGreen,
              ),
              const SizedBox(width: 8),
              Text(
                "CONTACT DETAILS",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: neonGreen,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: neonGreen.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: neonGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phoneNumber,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Mobile",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💎 Helper: E2E Security Notice
  Widget _buildSecurityBadge() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Deeper void color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentCyan.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentCyan.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: accentCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Messages and calls are end-to-end encrypted. No one outside of this chat can read or listen to them.",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------
   🚀 CUSTOM ANIMATED "SEND MESSAGE" BUTTON
   ------------------------------------------------------------ */
class _GlowingActionButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GlowingActionButton({required this.onTap});

  @override
  State<_GlowingActionButton> createState() => _GlowingActionButtonState();
}

class _GlowingActionButtonState extends State<_GlowingActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutQuart,
      child: Listener(
        onPointerDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        },
        onPointerUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap(); // Execute routing when finger lifts
        },
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E5FF),
                Color(0xFF0055FF),
              ], // Electric Cyan to Deep Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF0055FF,
                ).withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 10 : 20,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_rounded,
                size: 22,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                "Send Message",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
