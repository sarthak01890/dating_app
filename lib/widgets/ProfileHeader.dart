import 'package:flutter/material.dart';
import 'package:dating_app/screens/profilescreen/EditProfilePage.dart';
import 'package:dating_app/data/menu_data.dart'; // Colors (Assuming primaryPink is defined here)
import 'package:share_plus/share_plus.dart';

// 💜 Updated Global Color Definition
const Color primaryMediumPurple = Color(0xFF9370DB);

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? userImageUrl;
  final bool isVerified;
  final Function() onLoadUserData; // Function to refresh data

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.isVerified,
    required this.onLoadUserData,
  });

  void _shareApp() {
    Share.share(
        'Check out this amazing dating app! Download it here: [App Store/Play Store Link]');
  }

  // 💡 HACK: Updated color to 0xFF9370DB
  static const Color _primaryColor = primaryMediumPurple;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Picture (Left)
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                    ? NetworkImage(userImageUrl!)
                    : const NetworkImage("https://picsum.photos/200?random=20"),
              ),
              if (isVerified)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    // 💙 Verification Icon Color
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 20),

          // 2. Name and Buttons (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // Username
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Edit Profile and Share Profile Buttons (One Line)
                Row(
                  children: [
                    // Edit Profile Button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // 💜 Medium Purple Button
                            backgroundColor: _primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                            onLoadUserData(); // Refresh data after editing
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    // Share Profile Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          // 💜 Medium Purple Border
                          side: const BorderSide(color: _primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _shareApp,
                        child: const Text(
                          "Share",
                          style: TextStyle(
                            fontSize: 14,
                            // 💜 Medium Purple Text
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}