import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/profile/otheruserprofileveiwmodel.dart';

class OtherUserProfileView extends StatelessWidget {
  final String userid;
  final OtherUserProfileViewModel vm = Get.put(OtherUserProfileViewModel());

  OtherUserProfileView({super.key, required this.userid}) {
    vm.fetchUser(userid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // Custom Floating AppBar Look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final user = vm.user.value;
        if (user == null) return const Center(child: Text("User not found"));

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /* -------- PREMIUM HEADER SECTION -------- */
              Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative Background Blur
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.2),
                          Color(0xFFF8F9FD),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 100),
                      // Profile Image with Premium Border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 20),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: const Color(0xFFF0F3F8),
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(
                                  user.name?.isNotEmpty == true
                                      ? user.name![0].toUpperCase()
                                      : "?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user.name ?? "Unknown",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        user.phoneNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /* -------- ALIGNED QUICK ACTIONS (Fixed Alignment) -------- */
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUnifiedAction(
                      Icons.chat_bubble_rounded,
                      "Message",
                      Colors.blueAccent,
                      () => Get.back(),
                    ),
                    _buildUnifiedAction(
                      Icons.phone_rounded,
                      "Call",
                      Colors.green,
                      () {},
                    ),
                    _buildUnifiedAction(
                      Icons.videocam_rounded,
                      "Video",
                      Colors.orange,
                      () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /* -------- INFO SECTIONS (Grouped Premium Cards) -------- */
              _buildSectionCard(
                title: "ABOUT",
                content: user.about ?? "Hey there! I am using MyChat 💬",
                icon: Icons.info_outline_rounded,
              ),

              _buildSectionCard(
                title: "PREFERENCES",
                isList: true,
                children: [
                  _buildSubTile(Icons.photo_library_outlined, "Media & Docs"),
                  const Divider(indent: 50),
                  _buildSubTile(
                    Icons.notifications_active_outlined,
                    "Mute Notifications",
                    trailing: Switch(value: false, onChanged: (v) {}),
                  ),
                  const Divider(indent: 50),
                  _buildSubTile(
                    Icons.block_flipped,
                    "Block User",
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  /* -------- REFINED UI COMPONENTS -------- */

  Widget _buildUnifiedAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      // Using Expanded ensures equal distribution and alignment
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? content,
    bool isList = false,
    List<Widget>? children,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.blueAccent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          if (!isList)
            Text(
              content!,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF4A4A4A),
                height: 1.6,
              ),
            )
          else
            ...children!,
        ],
      ),
    );
  }

  Widget _buildSubTile(
    IconData icon,
    String title, {
    Widget? trailing,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey.shade600, size: 22),
          const SizedBox(width: 15),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          trailing ??
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}
