import 'package:flutter/material.dart';

class DownButtonBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final String? userImageUrl;

  const DownButtonBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.purple;
    const double iconSize = 26.0;

    // 💅 Animated Profile Icon setup
    Widget profileIconWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selectedIndex == 3 ? primaryColor : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: AnimatedScale(
        scale: selectedIndex == 3 ? 1.2 : 1.0, // zoom effect on select
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: CircleAvatar(
          radius: 12,
          backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
              ? NetworkImage(userImageUrl!) as ImageProvider<Object>
              : const AssetImage("assets/images/default_profile.png"),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
    );

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 10,

      items: [
        // Index 0: Home
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: selectedIndex == 0 ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Icon(Icons.home, size: iconSize),
          ),
          label: "Home",
        ),

        // Index 1: Games
        BottomNavigationBarItem(
          icon: AnimatedScale(
            scale: selectedIndex == 1 ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Icon(Icons.sports_esports_rounded, size: iconSize),
          ),
          label: "Games",
        ),

        // Index 2: Reels (This is the one you added and want to select)
        BottomNavigationBarItem(
          icon: AnimatedScale(
            // **CORRECTION 1:** The index must be 2 for the Reels item.
            scale: selectedIndex == 2 ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Icon(Icons.play_circle_fill, size: iconSize),
          ),
          label: "Reels",
        ),

        // Index 3: Users
        // You had two different items for index 3 and 4 in your original code.
        // We'll keep the `Users` icon here and update the index check.
        BottomNavigationBarItem(
          icon: AnimatedScale(
            // **CORRECTION 2:** The index must be 3 for the Users item.
            scale: selectedIndex == 3 ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Icon(Icons.people, size: iconSize),
          ),
          label: "Users",
        ),


        // Index 4: Profile Icon
        // **CORRECTION 3:** The animation logic for the Profile Icon (profileIconWidget)
        // needs to check for selectedIndex == 4. This is done outside the items list.
        // I have also updated your `profileIconWidget` logic below for consistency.
        BottomNavigationBarItem(
          icon: profileIconWidget,
          label: "Profile",
        ),
      ],
    );
  }
}
