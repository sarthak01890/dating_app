import 'package:flutter/material.dart';

class SubscriptionSection extends StatelessWidget {
  final VoidCallback onUpgradePressed;
  final Color primaryColor; // This will be 0xFF8A2BE2 (Violet)
  final Color accentColor;  // This will be 0xFF9370DB (Medium Purple/Accent)

  const SubscriptionSection({
    super.key,
    required this.onUpgradePressed,
    // 💡 इन्हें constructor में शामिल करें
    required this.primaryColor,
    required this.accentColor,
  });

  // Colors for this section (केवल Gold को छोड़कर, बाकी colors अब props से आ रहे हैं)
  static const Color primaryGold = Color(0xFFF7BA00);


  Widget _buildFeatureRow({
    required String featureName,
    required IconData freeIcon,
    required IconData plusIcon,
    required IconData goldIcon,
    required Color color, // यह अब accentColor या primaryColor होगा
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(child: Text(featureName, style: const TextStyle(fontSize: 16))),
          SizedBox(
            width: 50,
            child: Icon(freeIcon, color: Colors.grey[400]),
          ),
          SizedBox(
            width: 50,
            // PLUS Icon color (Uses Accent/Primary Color)
            child: Icon(plusIcon, color: color == primaryGold ? primaryGold : primaryColor),
          ),
          SizedBox(
            width: 50,
            // GOLD Icon color (Uses Accent/Primary Color)
            child: Icon(goldIcon, color: color == primaryGold ? primaryGold : primaryColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPGRADE YOUR EXPERIENCE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),

          // Pricing Tiers Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 80,
                child: TextButton(
                  onPressed: () {},
                  // 💜 PLUS Text Color Accent Color से लिया गया
                  child: Text('PLUS', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryGold, width: 1),
                ),
                child: TextButton(
                  onPressed: () {},
                  child: const Text('GOLD', style: TextStyle(color: primaryGold, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          // Feature Rows
          _buildFeatureRow(
            featureName: 'See Who Likes You',
            freeIcon: Icons.lock_outline,
            plusIcon: Icons.lock_outline,
            goldIcon: Icons.check,
            color: primaryGold, // Gold features remain gold
          ),
          _buildFeatureRow(
            featureName: 'Unlimited Likes',
            freeIcon: Icons.lock_outline,
            plusIcon: Icons.check,
            goldIcon: Icons.check,
            color: primaryColor, // 💜 Violet (Primary)
          ),
          _buildFeatureRow(
            featureName: 'Unlimited Rewinds',
            freeIcon: Icons.lock_outline,
            plusIcon: Icons.check,
            goldIcon: Icons.check,
            color: primaryColor, // 💜 Violet (Primary)
          ),
          _buildFeatureRow(
            featureName: '5 Super Likes per day',
            freeIcon: Icons.lock_outline,
            plusIcon: Icons.star_outline_rounded,
            goldIcon: Icons.star_rounded,
            color: primaryGold, // Gold features remain gold
          ),

          const SizedBox(height: 30),

          // Call to Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // 💜 Violet Button
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: onUpgradePressed, // Call the passed callback
              child: const Text(
                "UPGRADE TO GOLD",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'See all Plans and Features',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}