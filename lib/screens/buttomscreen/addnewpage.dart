import 'package:flutter/material.dart';
import 'package:dating_app/screens/down_button.dart';

// --- Global Color Definition ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)

class Addnewpage extends StatefulWidget {
  const Addnewpage({super.key});

  @override
  State<Addnewpage> createState() => _AddnewpageState();
}

class _AddnewpageState extends State<Addnewpage> {
  int _selectedTab = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedTab = index;
      // yahan aap navigation ya action define kar sakte ho
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold का बैकग्राउंड थीम के अनुसार (सफेद या डार्क)
    final themeColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      // 🎨 AppBar का बैकग्राउंड और टेक्स्ट कलर वायलेट थीम के अनुसार सेट करें
      appBar: AppBar(
        title: Text(
          "Add New Page",
          style: TextStyle(
            color: textColor,
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryViolet), // 💜 Back/Menu Icon
      ),

      // 🎨 Body
      body: Center(
        child: Text(
          "Gaming Content Here",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryViolet, // 💜 टेक्स्ट को वायलेट करें
          ),
        ),
      ),
      // 💡 यदि आप BottomNavigationBar जोड़ते हैं, तो उसका रंग भी primaryViolet रखें
      // उदाहरण:
      /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _onBottomNavTap,
        selectedItemColor: primaryViolet,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Gaming'),
        ],
      ),
      */
    );
  }
}