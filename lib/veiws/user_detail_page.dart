import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/viewmodels/user_veiw_model.dart';

class UserDetailsView extends StatelessWidget {
  UserDetailsView({super.key});

  final UserVeiwModel userVM = Get.put(UserVeiwModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              /// App Title
              Text(
                "Profile Setup",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let’s personalize your account 💬",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 40),

              /// Profile Image Picker (Reactive)
              GestureDetector(
                onTap: () => userVM.pickImage(),
                child: Obx(() {
                  final image = userVM.profileImage.value;
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: image != null
                            ? FileImage(image)
                            : null,
                        child: image == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 40),

              /// Name Field
              TextField(
                controller: userVM.nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  hintText: "Enter your name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              /// About Field
              TextField(
                controller: userVM.aboutController,
                decoration: InputDecoration(
                  labelText: "About (optional)",
                  hintText: "Hey there! I am using MyChat 💬",
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              /// Continue Button
              Obx(() {
                return ElevatedButton(
                  onPressed: userVM.isloading.value
                      ? null
                      : () async {
                          final name = userVM.nameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar("Error", "Please enter your name");
                            return;
                          }

                          await userVM.saveuserinfo(
                            name: name,
                            about: userVM.aboutController.text.trim(),
                            profileimage: userVM.profileImage.value,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: userVM.isloading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
