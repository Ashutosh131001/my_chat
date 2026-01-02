import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/viewmodels/otheruserprofileveiwmodel.dart';

class OtherUserProfileView extends StatelessWidget {
  final String userid;

  final OtherUserProfileViewModel vm =
      Get.put(OtherUserProfileViewModel());

  OtherUserProfileView({super.key, required this.userid}) {
    vm.fetchUser(userid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Obx(() {
        
        if (vm.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        final user = vm.user.value;

        if (user == null) {
          return const Center(
            child: Text("User not found"),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent.shade100,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.name?.isNotEmpty == true
                            ? user.name![0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 20),

              // Name
              Text(
                user.name ?? "Unknown",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // About
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  user.about ?? "Hey there! I am using MyChat 💬",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Phone
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone"),
                subtitle: Text(user.phoneNumber),
              ),
            ],
          ),
        );
      }),
    );
  }
}