import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/contactspage/contactcard.dart';

// ViewModels
import 'package:my_chat/contactspage/contactsveiwmodel.dart';
import 'package:my_chat/contactspage/emptystate.dart';

// Widgets

class ContactsView extends StatelessWidget {
  final ContactsViewModel contactsVM = Get.put(ContactsViewModel());

  ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ideally, this fetch should happen in the onInit() of your ViewModel,
    // but leaving it here is fine for now to preserve your logic.
    contactsVM.fetchAllFirebaseUsers();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
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
            /* -------- APP BAR -------- */
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
              flexibleSpace: const FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
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

            /* -------- LIST -------- */
            if (contactsVM.firebaseUsers.isEmpty)
              const SliverFillRemaining(child: EmptyContactsView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = contactsVM.firebaseUsers[index];
                    return ContactCard(user: user);
                  }, childCount: contactsVM.firebaseUsers.length),
                ),
              ),
          ],
        );
      }),

      /* ---------------- FAB ---------------- */
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
}
