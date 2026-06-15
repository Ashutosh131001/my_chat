import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/profile/profileveiwmodel.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewModel profileVM = Get.put(ProfileViewModel());

  ProfileView({super.key});

  // 🎨 DESIGN TOKENS
  static const Color bgCanvas = Color(0xFF0A0C10); // Deep Midnight Charcoal
  static const Color surfaceColor = Color(0xFF161A22); // Obsidian Surface
  static const Color textPrimary = Color(0xFFF5F5F7); // Crisp Off-White
  static const Color textSecondary = Colors.white54; // Muted Silver
  static const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color glassSurface = Color(0x99161A22); // Liquid Glass

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGhostBackButton(),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (profileVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: accentCyan,
              strokeWidth: 2.5,
            ),
          );
        }

        final user = profileVM.currentUser;
        if (user == null) {
          return const Center(
            child: Text("User not found", style: TextStyle(color: textPrimary)),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* -------- 🌟 AMBIENT GLOW & AVATAR -------- */
              Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient Backdrop Glow
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.2),
                        radius: 1.0,
                        colors: [accentCyan.withOpacity(0.12), bgCanvas],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 120),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          profileVM.pickProfileImage();
                        },
                        child: Stack(
                          children: [
                            // Glowing Avatar Well
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: surfaceColor,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
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
                                radius: 65,
                                backgroundColor: const Color(0xFF222834),
                                backgroundImage:
                                    profileVM.selectedImage.value != null
                                    ? FileImage(profileVM.selectedImage.value!)
                                    : (user.profileImageUrl != null
                                              ? NetworkImage(
                                                  user.profileImageUrl!,
                                                )
                                              : null)
                                          as ImageProvider?,
                                child:
                                    (user.profileImageUrl == null &&
                                        profileVM.selectedImage.value == null)
                                    ? Text(
                                        user.name?.isNotEmpty == true
                                            ? user.name![0].toUpperCase()
                                            : "?",
                                        style: GoogleFonts.inter(
                                          fontSize: 45,
                                          fontWeight: FontWeight.w900,
                                          color: accentCyan,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            // Camera Badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: surfaceColor,
                                  border: Border.all(
                                    color: accentCyan,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: accentCyan,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /* -------- 📝 EDITABLE GHOST CARD -------- */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildPremiumField(
                        label: "DISPLAY NAME",
                        initialValue: profileVM.name.value,
                        onChanged: profileVM.onNameChanged,
                        icon: Icons.person_outline_rounded,
                      ),
                      Divider(
                        height: 1,
                        indent: 50,
                        endIndent: 20,
                        color: Colors.white.withOpacity(
                          0.06,
                        ), // Hairline divider
                      ),
                      _buildPremiumField(
                        label: "ABOUT",
                        initialValue: profileVM.about.value,
                        onChanged: profileVM.onAboutChanged,
                        icon: Icons.info_outline_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /* -------- 🔒 SECURE READ-ONLY CARD -------- */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildReadOnlyCard(
                  "SECURE PHONE",
                  user.phoneNumber,
                  Icons.lock_outline_rounded,
                ),
              ),

              const SizedBox(height: 40),

              /* -------- 🚀 DYNAMIC SAVE BUTTON -------- */
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Obx(() {
                  bool canSave =
                      profileVM.hasChanges.value && !profileVM.isSaving.value;
                  return _GlowingSaveButton(
                    canSave: canSave,
                    isSaving: profileVM.isSaving.value,
                    onTap: canSave ? profileVM.saveProfile : null,
                  );
                }),
              ),
              const SizedBox(height: 40),
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
        color: glassSurface,
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

  // 💎 Helper: Ghost Text Fields
  Widget _buildPremiumField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary),
      cursorColor: accentCyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.0,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: accentCyan,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: textSecondary, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  // 💎 Helper: Read-Only Info Card
  Widget _buildReadOnlyCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------
   🚀 CUSTOM ANIMATED TACTILE SAVE BUTTON
   ------------------------------------------------------------ */
class _GlowingSaveButton extends StatefulWidget {
  final bool canSave;
  final bool isSaving;
  final VoidCallback? onTap;

  const _GlowingSaveButton({
    required this.canSave,
    required this.isSaving,
    required this.onTap,
  });

  @override
  State<_GlowingSaveButton> createState() => _GlowingSaveButtonState();
}

class _GlowingSaveButtonState extends State<_GlowingSaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed && widget.canSave ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutQuart,
      child: Listener(
        onPointerDown: (_) {
          if (widget.canSave) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
          }
        },
        onPointerUp: (_) {
          if (widget.canSave) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          }
        },
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Changes from muted grey to glowing cyan when changes are made!
            gradient: widget.canSave
                ? const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
            border: Border.all(
              color: widget.canSave
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: widget.canSave
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF0055FF,
                      ).withOpacity(_isPressed ? 0.2 : 0.4),
                      blurRadius: _isPressed ? 10 : 20,
                      offset: Offset(0, _isPressed ? 4 : 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    "Save Profile",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.canSave
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
