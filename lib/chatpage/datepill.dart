import 'dart:ui';
import 'package:flutter/material.dart';

class DatePill extends StatelessWidget {
  final int timestamp;

  const DatePill({super.key, required this.timestamp});

  // 🕒 Logic to convert Timestamp -> "Today", "Yesterday", "12 Jun"
  String _formatDateString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return "Today";
    } else if (msgDate == yesterday) {
      return "Yesterday";
    } else {
      // Standard Date Formatting without extra packages
      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ), // Extra breathing room
      child: Center(
        // Center the pill in the chat feed
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            // 💧 Frosted glass effect so the radial background gently blurs underneath it
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.04,
                ), // Ghostly smoked glass base
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(
                    0.08,
                  ), // Ultra-thin hairline reflection
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.2,
                    ), // Soft dark drop shadow
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _formatDateString(
                  timestamp,
                ).toUpperCase(), // Uppercase for cinematic aesthetic
                style: TextStyle(
                  fontSize: 10, // Slightly smaller, highly refined
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.45), // Muted silver
                  letterSpacing:
                      1.5, // Wide tracking makes tiny text look incredibly premium
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
