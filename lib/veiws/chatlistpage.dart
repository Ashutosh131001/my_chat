import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/veiws/CHATpg.dart';

import 'package:my_chat/viewmodels/contactsveiwmodel.dart';

class ContactsView extends StatelessWidget {
  final ContactsViewModel contactsVM = Get.put(ContactsViewModel());

  ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    contactsVM.fetchAllFirebaseUsers();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          title: const Text(
            "MyChat Users",
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
        if (contactsVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3A86FF)),
          );
        }

        if (contactsVM.firebaseUsers.isEmpty) {
          return const Center(
            child: Text(
              "No MyChat users found 😔",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: contactsVM.firebaseUsers.length,
          itemBuilder: (context, index) {
            final user = contactsVM.firebaseUsers[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFE7F0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => Get.to(
                  () => pageofchat(otherUser: user),
                  transition: Transition.cupertino,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueAccent.shade100,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),

                // ----------- NAME + PHONE NUMBER ----------
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Text(
                  user.phonenumber,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A5A5A),
                  ),
                ),

                // ------------ CHAT ICON --------------
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blueAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF3A86FF),
                  ),
                ),
              ),
            );
          },
        );
      }),

      // -------------- FLOATING BUTTON WITH GRADIENT ----------
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF3A86FF), Color(0xFF007BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => contactsVM.fetchAllFirebaseUsers(),
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}
