import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat/contactspage/contactcard.dart';
import 'package:my_chat/contactspage/contactsveiwmodel.dart';
import 'package:my_chat/contactspage/emptystate.dart';

class ContactsView extends StatelessWidget {
  final ContactsViewModel contactsVM = Get.put(ContactsViewModel());

  ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 DESIGN TOKENS
    const Color bgCanvas = Color(0xFF0D1117); // Dark Premium Void
    const Color textPrimary = Color(0xFFF5F5F7); // Off-White
    const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan
    const Color glassSurface = Color(0x66161A22); // Smoked Translucent Obsidian

    contactsVM.fetchAllFirebaseUsers();

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Obx(() {
        if (contactsVM.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: accentCyan),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /* -------- 💧 LIQUID GLASS SLIVER APP BAR -------- */
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 140.0,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors
                  .transparent, // Required to let the background blur look fluid
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: const Text(
                      "Contacts",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        color: glassSurface,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /* -------- CONTACTS LIST -------- */
            if (contactsVM.firebaseUsers.isEmpty)
              const SliverFillRemaining(child: EmptyContactsView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = contactsVM.firebaseUsers[index];
                    // Note: Ensure your ContactCard widget is updated internally
                    // to look good against a dark canvas background!
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ContactCard(user: user),
                    );
                  }, childCount: contactsVM.firebaseUsers.length),
                ),
              ),
          ],
        );
      }),

      /* ---------------- 🚀 GLOWING NEON FAB ---------------- */
      floatingActionButton: GestureDetector(
        onTap: () => contactsVM.fetchAllFirebaseUsers(),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00E5FF),
                Color(0xFF0055FF),
              ], // Electric Cyan to Cyber Blue
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0055FF).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
