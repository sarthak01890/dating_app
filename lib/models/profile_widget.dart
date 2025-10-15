import 'package:flutter/material.dart';

// --- Global Color Definitions ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)
const Color accentPurple = Color(0xFF9370DB); // Medium Purple (एक्सेंट रंग)


class ProfileWidget extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? color;
  final int badge;
  final String? trailingText;
  final bool isMenu;
  final bool isBanner;
  final VoidCallback? onTap;

  const ProfileWidget({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.color,
    this.badge = 0,
    this.trailingText,
    this.isMenu = false,
    this.isBanner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔔 isBanner के लिए थीम
    if (isBanner) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // 💜 बैनर बैकग्राउंड के लिए हल्का बैंगनी
            color: primaryViolet.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: primaryViolet))), // 💜 टेक्स्ट को वायलेट करें
              TextButton(
                onPressed: onTap, // onTap का उपयोग करें
                child: const Text("Confirm", style: TextStyle(color: primaryViolet)), // 💜 बटन को वायलेट करें
              ),
            ],
          ),
        ),
      );
    }

    // 📜 isMenu के लिए थीम (लिस्टटाइल)
    if (isMenu) {
      return ListTile(
        leading: icon != null
            ? Icon(icon, color: accentPurple) // 💜 Accent Purple Icon
            : null,
        title: Text(label),
        trailing: badge > 0
            ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red, // 🔴 Badge को लाल ही रहने दें
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badge.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        )
            : trailingText != null
            ? Text(trailingText!, style: const TextStyle(color: Colors.grey))
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Arrow को ग्रे रहने दें
        onTap: onTap,
      );
    }

    // ✨ डिफ़ॉल्ट विजेट
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: color ?? primaryViolet), // 💜 Primary Violet Icon
          if (icon != null) const SizedBox(width: 6),
          Text(label),
          if (value != null) const SizedBox(width: 4),
          if (value != null) Text(value!),
        ],
      ),
    );
  }
}