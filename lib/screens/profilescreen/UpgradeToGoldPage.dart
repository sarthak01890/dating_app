import 'package:flutter/material.dart';

// --- Global Color Definition ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)

// Subscription plan index enumeration for clarity
enum SubscriptionPlan {
  week,
  month,
  sixMonths,
  year,
}

class UpgradeToGoldPage extends StatefulWidget {
  const UpgradeToGoldPage({super.key});

  @override
  State<UpgradeToGoldPage> createState() => _UpgradeToGoldPageState();
}

class _UpgradeToGoldPageState extends State<UpgradeToGoldPage> {
  // 💜 प्राथमिक रंग को global constant से उपयोग करें
  final Color primaryColor = primaryViolet;
  // ⭐️ गोल्ड रंग को बरकरार रखें
  final Color primaryGold = const Color(0xFFF7BA00);

  // ⭐ State variable to track the currently selected plan
  // Initially set to month as it was marked 'BEST VALUE'
  SubscriptionPlan _selectedPlan = SubscriptionPlan.month;

  // Widget to build a single subscription card
  Widget _buildSubscriptionCard({
    required String duration,
    required String price,
    required String monthlyPrice,
    required SubscriptionPlan plan,
    bool isBestValueDefault = false, // To show "BEST VALUE" only on the default recommended one
  }) {
    // Check if the current card is selected
    bool isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan; // Update the selected plan on tap
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          // 💜 Violet for selected card background
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            // 💜 Thicker Violet border for selected card
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.2), // 💜 Violet shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SELECTED/BEST VALUE Banner
            if (isSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor, // 💜 Violet Banner
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: Text(
                  isBestValueDefault ? 'BEST VALUE' : 'SELECTED',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),


            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      // 💜 Violet text for selected card
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      // 💜 Violet text for selected card
                      color: isSelected ? primaryColor : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    monthlyPrice,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get the current price for the button
  String _getCurrentPrice() {
    switch (_selectedPlan) {
      case SubscriptionPlan.week:
        return '₹149.00';
      case SubscriptionPlan.month:
        return '₹499.00';
      case SubscriptionPlan.sixMonths:
        return '₹1,999.00';
      case SubscriptionPlan.year:
        return '₹2,999.00';
      default:
        return '???';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade to Gold"),
        backgroundColor: primaryColor, // 💜 Violet AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold Icon and Title
            Row(
              children: [
                Icon(Icons.workspace_premium, color: primaryGold, size: 40),
                const SizedBox(width: 10),
                Text(
                  'Unlock Dating App Gold!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: primaryColor, // 💜 Violet Title Text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Enjoy exclusive features like See Who Likes You, Unlimited Likes, and more.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Subscription Options (Clickable Cards)
            _buildSubscriptionCard(
              duration: '1 Week Subscription',
              price: '₹149.00',
              monthlyPrice: 'Great for a trial!',
              plan: SubscriptionPlan.week,
            ),
            _buildSubscriptionCard(
              duration: '1 Month Subscription',
              price: '₹499.00',
              monthlyPrice: 'Save 16% compared to weekly plan.',
              plan: SubscriptionPlan.month,
              isBestValueDefault: true,
            ),
            _buildSubscriptionCard(
              duration: '6 Months Subscription',
              price: '₹1,999.00',
              monthlyPrice: 'Save 33% (₹333/month)',
              plan: SubscriptionPlan.sixMonths,
            ),
            _buildSubscriptionCard(
              duration: '1 Year Subscription',
              price: '₹2,999.00',
              monthlyPrice: 'Best deal! (₹250/month)',
              plan: SubscriptionPlan.year,
            ),

            const SizedBox(height: 40),

            // Purchase Button (Call to Action)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold, // Using Gold for the final purchase button
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  // TODO: Implement actual payment gateway integration here.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proceeding to Payment for ${_getCurrentPrice()}... (Dummy Action)'),
                    ),
                  );
                },
                child: Text(
                  "BUY GOLD NOW - ${_getCurrentPrice()}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Terms and Conditions
            Center(
              child: Text(
                'By tapping "BUY GOLD NOW", your payment will be processed via your selected method and your subscription will automatically renew.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}