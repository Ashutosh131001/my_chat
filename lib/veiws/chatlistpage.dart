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
      backgroundColor: const Color(0xFFFBFBFC), // Match ChatListPage background
      body: Obx(() {
        if (contactsVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blueAccent,
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /* -------- ULTRA PREMIUM LARGE APP BAR -------- */
            SliverAppBar(
              expandedHeight: 140.0,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1A1A1A),
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  "Contacts",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),

            /* -------- CURVED CARD LIST -------- */
            if (contactsVM.firebaseUsers.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = contactsVM.firebaseUsers[index];

                    return Container(
                      // Box with Border and Curves in all directions
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFF1F1F1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () => Get.to(
                              () => pageofchat(otherUser: user),
                              transition: Transition.cupertino,
                              duration: Duration(milliseconds: 500),
                            ),
                            contentPadding: const EdgeInsets.all(16),

                            /* -------- AVATAR -------- */
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFF0F3F8),
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.blueAccent,
                                      ),
                                    )
                                  : null,
                            ),

                            /* -------- NAME & PHONE -------- */
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                user.phonenumber,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            /* -------- ACTION -------- */
                            trailing: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: contactsVM.firebaseUsers.length),
                ),
              ),
          ],
        );
      }),

      /* ---------------- UNIFIED OBSIDIAN FAB ---------------- */
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF434343)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => contactsVM.fetchAllFirebaseUsers(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 70,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            "No users found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
