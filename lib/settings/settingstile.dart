import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    // ⚡ Updated default colors to match our Premium Dark ecosystem
    this.iconColor = const Color(0xFF00E5FF), // Default: Electric Cyan
    this.textColor = const Color(0xFFF5F5F7), // Default: Crisp Off-White
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 DESIGN TOKENS
    const Color surfaceColor = Color(0xFF161A22); // Premium Obsidian Surface

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        // 💧 Hairline reflective glass edge
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.15,
            ), // Deeper shadow for dark canvas
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
            onTap: onTap,
            // 🌟 Subtle interaction layer when tapped
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            splashColor: iconColor.withOpacity(0.05),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            /* -------- 💎 ICON GLASS WELL -------- */
            leading: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                // Automatically creates a translucent, colored glass background matching the icon
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            /* -------- 📝 TITLE -------- */
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3, // Cinematic typography tracking
              ),
            ),

            /* -------- ➡️ SUBTLE ARROW -------- */
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.15), // Elegant, muted chevron
              ),
            ),
          ),
        ),
      ),
    );
  }
}
