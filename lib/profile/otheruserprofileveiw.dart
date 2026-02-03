import 'dart:ui';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    vm.loadFromLocal(widget.user);
    vm.fetchUser(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
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
              /* -------- HEADER SECTION -------- */
              Stack(
                alignment: Alignment.center,
                children: [
                  // Taller Background to fill upper space
                  Container(
                    height: 360,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.1),
                          const Color(0xFFF8F9FD),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 110),
                      // Profile Image
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 20),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80, // Slightly larger
                          backgroundColor: const Color(0xFFF0F3F8),
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(
                                  (user.name != null && user.name!.isNotEmpty)
                                      ? user.name![0].toUpperCase()
                                      : "?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 55,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        user.name ?? "Unknown",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Removed Phone number from here to move it to a "Card" below
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "MyChat User",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /* -------- ACTION BUTTON -------- */
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: Colors.blueAccent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_rounded, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          "Send Message",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /* -------- 1. ABOUT SECTION -------- */
              _buildSectionCard(
                title: "ABOUT",
                content: user.about ?? "Hey there! I am using MyChat 💬",
                icon: Icons.info_outline_rounded,
              ),

              /* -------- 2. CONTACT DETAILS (New Filler) -------- */
              // Moving the phone number here creates a whole new visual block
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
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
                    Row(
                      children: [
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "CONTACT DETAILS",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.call, color: Colors.green),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.phoneNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              "Mobile",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /* -------- 3. SECURITY (Static Filler) -------- */
              // This doesn't need to DO anything, it just reassures the user
              // and fills the screen nicely.
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F8), // Slightly darker bg
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Messages and calls are end-to-end encrypted. No one outside of this chat, not even MyChat, can read or listen to them.",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /* -------- 4. REPORT BUTTON (Footer) -------- */
              TextButton.icon(
                onPressed: () {
                  Get.snackbar(
                    "Report",
                    "Report submitted. We will review this user.",
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20),
                  );
                },
                icon: const Icon(
                  Icons.flag_outlined,
                  color: Colors.redAccent,
                  size: 20,
                ),
                label: Text(
                  "Block or Report User",
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSectionCard({
    required String title,
    required String content,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(25),
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
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blueAccent.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF4A4A4A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
