
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/viewmodels/ProfileVeiwModel.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewModel profileVM = Get.put(ProfileViewModel());

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),

     
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3A86FF),
                  Color(0xFF007BFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "My Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),

     
      body: Obx(() {
        if (profileVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3A86FF)),
          );
        }

        final user = profileVM.currentUser;
        if (user == null) {
          return const Center(child: Text("User not found"));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
            
              GestureDetector(
                onTap: profileVM.pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent.shade100,
                      backgroundImage: profileVM.selectedImage.value != null
                          ? FileImage(profileVM.selectedImage.value!)
                          : (user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null) as ImageProvider?,
                      child: (user.profileImageUrl == null &&
                              profileVM.selectedImage.value == null)
                          ? Text(
                              user.name?.isNotEmpty == true
                                  ? user.name![0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3A86FF),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

            
              _buildField(
                label: "Name",
                initialValue: profileVM.name.value,
                onChanged: profileVM.onNameChanged,
                icon: Icons.person,
              ),

              const SizedBox(height: 18),

             
              _buildField(
                label: "About",
                initialValue: profileVM.about.value,
                onChanged: profileVM.onAboutChanged,
                icon: Icons.info_outline,
              ),

              const SizedBox(height: 18),

              
              _buildReadOnlyField(
                label: "Phone Number",
                value: user.phoneNumber,
                icon: Icons.phone,
              ),

              const SizedBox(height: 30),

              
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: profileVM.hasChanges.value &&
                            !profileVM.isSaving.value
                        ? profileVM.saveProfile
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFF3A86FF),
                    ),
                    child: profileVM.isSaving.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

  
  Widget _buildField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}