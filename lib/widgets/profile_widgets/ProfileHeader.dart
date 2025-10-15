import 'package:flutter/material.dart';

// 💜 Global Color Definition (Medium Purple)
// इसका उपयोग तब होगा जब आप इसे ProfilePage से पास करेंगे।
const Color primaryMediumPurple = Color(0xFF9370DB);

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? userImageUrl;
  final String bio;
  final bool isVerified;
  final Function() onLoadUserData;
  final VoidCallback onEditPressed;
  final VoidCallback onSharePressed;
  final Color textColor;
  final Color primaryColor; // कंस्ट्रक्टर से पास किया गया Color

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.bio,
    required this.isVerified,
    required this.onEditPressed,
    required this.onSharePressed,
    required this.textColor,
    required this.primaryColor,
    required this.onLoadUserData,
  });

  @override
  Widget build(BuildContext context) {
    // ❌ local `primaryColor` declaration हटा दिया गया है।
    // अब यह `widget.primaryColor` (यानी this.primaryColor) का उपयोग करेगा।

    // Bio Text Color को light/dark mode के अनुसार एडजस्ट करने के लिए।
    final bioTextColor = textColor.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo and Buttons Row
          Row(
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
                    Text(
                      userName,
                      style: TextStyle( // 🎨 textColor का उपयोग
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Edit Profile Button
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // 💜 Primary Color का उपयोग
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: onEditPressed,
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
                              // 💜 Primary Color Border
                              side: BorderSide(color: primaryColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: onSharePressed,
                            child: Text(
                              "Share",
                              style: TextStyle(
                                fontSize: 14,
                                // 💜 Primary Color Text
                                color: primaryColor,
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

          const SizedBox(height: 25),

          // About/Bio Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bioTextColor, // 🎨 Dark/Light Mode के अनुसार रंग
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bio,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  // 🎨 Dark/Light Mode के अनुसार रंग
                  color: bioTextColor,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}