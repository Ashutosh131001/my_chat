import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42, // Slightly larger for a better premium touch target
      height: 42,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05), // Ghostly translucent fill
        // 💧 Hairline glass edge to catch the background light
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle depth
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            // 🌟 Premium interaction ripples
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFFF5F5F7), // Crisp premium off-white
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
