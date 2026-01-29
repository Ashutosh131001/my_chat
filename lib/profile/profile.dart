import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/profile/profileveiwmodel.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewModel profileVM = Get.put(ProfileViewModel());

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white for that premium feel
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (profileVM.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final user = profileVM.currentUser;
        if (user == null) {
          return const Center(child: Text("User not found"));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* -------- PROFILE IMAGE SECTION -------- */
              Center(
                child: GestureDetector(
                  onTap: profileVM.pickProfileImage,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: const Color(0xFFF0F3F8),
                          backgroundImage: profileVM.selectedImage.value != null
                              ? FileImage(profileVM.selectedImage.value!)
                              : (user.profileImageUrl != null
                                        ? NetworkImage(user.profileImageUrl!)
                                        : null)
                                    as ImageProvider?,
                          child:
                              (user.profileImageUrl == null &&
                                  profileVM.selectedImage.value == null)
                              ? Text(
                                  user.name?.isNotEmpty == true
                                      ? user.name![0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1A1A), // Dark chic color
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /* -------- INPUT SECTION GROUP -------- */
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
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
                    const Divider(height: 1, indent: 50, endIndent: 20),
                    _buildPremiumField(
                      label: "ABOUT",
                      initialValue: profileVM.about.value,
                      onChanged: profileVM.onAboutChanged,
                      icon: Icons.info_outline_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /* -------- READ ONLY INFO -------- */
              _buildReadOnlyCard(
                "Phone",
                user.phoneNumber,
                Icons.phone_iphone_rounded,
              ),

              const SizedBox(height: 40),

              /* -------- SAVE BUTTON -------- */
              Obx(() {
                bool canSave =
                    profileVM.hasChanges.value && !profileVM.isSaving.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canSave ? profileVM.saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      elevation: canSave ? 8 : 0,
                      shadowColor: Colors.blueAccent.withOpacity(0.4),
                      backgroundColor: const Color(0xFF007BFF),
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: profileVM.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Save Profile",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: canSave
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPremiumField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildReadOnlyCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
