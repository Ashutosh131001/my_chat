import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/auth/user_veiw_model.dart';

class UserDetailsView extends StatelessWidget {
  UserDetailsView({super.key});

  final UserVeiwModel userVM = Get.put(UserVeiwModel());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              // 🌈 Premium Gradient Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  "Profile Setup",
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 📝 Refined Subtitle
              Text(
                "Let’s personalize your account so your friends can recognize you.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.4,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // 📸 Premium Profile Image Picker
              Center(
                child: GestureDetector(
                  onTap: () => userVM.pickImage(),
                  child: Obx(() {
                    final image = userVM.profileImage.value;
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Avatar Container with Glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF5F7FA),
                            backgroundImage: image != null
                                ? FileImage(image)
                                : null,
                            child: image == null
                                ? Icon(
                                    Icons.person_outline_rounded,
                                    size: 55,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                        // Sleek Camera Icon Badge
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.indigo],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode
                                  ? const Color(0xFF121212)
                                  : Colors.white,
                              width: 4,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // 👤 Name Input Field
              _buildPremiumTextField(
                controller: userVM.nameController,
                hintText: "Your Name",
                icon: Icons.person_outline_rounded,
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 20),

              // ℹ️ About Input Field
              _buildPremiumTextField(
                controller: userVM.aboutController,
                hintText: "About (e.g., At work, Available)",
                icon: Icons.info_outline_rounded,
                isDarkMode: isDarkMode,
              ),

              SizedBox(height: size.height * 0.08),

              // 🚀 Premium Gradient Continue Button
              Obx(() {
                final isLoading = userVM.isloading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isLoading
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                            )
                          : const LinearGradient(
                              colors: [Colors.blueAccent, Colors.indigo],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      boxShadow: isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                final name = userVM.nameController.text.trim();
                                if (name.isEmpty) {
                                  Get.snackbar(
                                    "Required",
                                    "Please enter your name to continue",
                                    backgroundColor: Colors.redAccent
                                        .withOpacity(0.9),
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                  return;
                                }

                                await userVM.saveuserinfo(
                                  name: name,
                                  about: userVM.aboutController.text.trim(),
                                  profileimage: userVM.profileImage.value,
                                );
                              },
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "Continue",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 🛠 Helper Widget for Premium Text Fields
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            size: 22,
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 15),
        ),
      ),
    );
  }
}
