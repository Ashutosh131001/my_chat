import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 DESIGN TOKENS
    const Color textPrimary = Color(0xFFF5F5F7); // Crisp Off-White
    const Color textSecondary = Colors.white54; // Muted Silver
    const Color accentCyan = Color(0xFF00E5FF); // Electric Cyan

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* -------- 🌟 GLOWING GLASS ORB -------- */
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentCyan.withOpacity(0.05), // Deep translucent well
                border: Border.all(
                  color: accentCyan.withOpacity(0.15), // Reflective edge
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentCyan.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 40,
                      color: accentCyan,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            /* -------- 📝 PREMIUM TYPOGRAPHY -------- */
            Text(
              "No Secure Chats Yet",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "Tap the glowing button below to start an end-to-end encrypted conversation.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
