import 'dart:developer';
import 'package:dating_app/data/menu_data.dart';
import 'package:dating_app/models/profilemenumodel/profile_menu_item.dart';
import 'package:dating_app/screens/auth.dart';
import 'package:dating_app/screens/buttomscreen/ReelsFeed.dart';
import 'package:dating_app/screens/buttomscreen/reel.dart';
import 'package:dating_app/screens/profilescreen/EditProfilePage.dart';
import 'package:dating_app/screens/profilescreen/SettingsPage.dart';
import 'package:dating_app/widgets/reelwidget/MyReelsGrid.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dating_app/main.dart';
import 'package:dating_app/screens/profilescreen/UpgradeToGoldPage.dart';
import 'package:dating_app/models/profile_widget.dart';
import 'package:dating_app/widgets/profile_widgets/ProfileHeader.dart';
import 'package:dating_app/widgets/profile_widgets/SubscriptionSection.dart';

// 🆕 Activity Page Placeholder
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});
  static const Color primaryColor = Color(0xFF9370DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Your recent app activity will be shown here.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

// --- Global Color Definitions (मीडियम पर्पल थीम) ---
const Color primaryColor = Color(0xFF9370DB); // Medium Purple (नया Primary Color)
const Color accentColor = Color(0xFFB0A2E8); // Slightly lighter for subtle accents
const Color darkBackground = Color(0xFF121212); // Dark Mode Background

class ProfilePage extends StatefulWidget {
  final bool isDemoUser;
  const ProfilePage({super.key,required this.isDemoUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userImageUrl;
  String userName = "My Profile";
  String bio = "You are not gonna tell me who I’m";
  bool _isVerified = false;
  bool _isLoading = false;

  Key _myReelsGridKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- Data Loading Logic ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        log("user data: $response");
        if (response != null && mounted) {
          setState(() {
            userImageUrl = response['image_url'] as String?;
            userName = response['username'] ?? user.email!;
            bio = response['bio'] ?? bio;
            _isVerified = response['is_verified'] ?? false;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- Menu Handlers ---

  void _handleMenuTap(String title) async {
    if (title == 'Get Verified') {
      // Verification logic
    } else if (title == 'Activity Page') { // 🆕 नया आइटम
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ActivityPage()));
    } else if (title == 'Settings') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SettingsPage()));
    } else if (title == 'Share App') {
      _shareApp();
    } else if (title == 'Help & Support') {
      _launchHelpUrl();
    } else if (title == 'Toggle Theme') {
      isDarkMode.value = !isDarkMode.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isDarkMode.value ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
        ),
      );
    } else if (title == 'Logout') {
        final supabase = Supabase.instance.client;
      if(widget.isDemoUser){
        final UserId = '95ea97ca-2949-401c-9b09-eef5c3c219b3';

          // Delete all messages sent or received by demo user
      await supabase
          .from('messages')
          .delete()
          .or('user_id.eq.$UserId,recipient_id.eq.$UserId');

      debugPrint('✅ Demo user messages cleared');
      }
      Supabase.instance.client.auth.signOut().then((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $error')),
        );
      });
    }
  }

  // --- Utility Functions ---

  void _shareApp() {
    Share.share(
        'Check out this amazing dating app! Download it here: [App Store/Play Store Link]');
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse(
        'mailto:support@datingapp.com?subject=Help%20and%20Support');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app.')),
      );
    }
  }

  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
    _loadUserData();
  }

  void _navigateToUpgradeToGold() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UpgradeToGoldPage()),
    );
  }

  void _navigateToReelUpload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReelsScreen()),
    );
    if (mounted) {
      setState(() {
        _myReelsGridKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Current theme based on ValueNotifier
    final isDark = isDarkMode.value;
    final themeColor = isDark ? darkBackground : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final primaryThemeColor = primaryColor; // 💜 0xFF9370DB

    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeColor,
        // 💜 Primary Color Loading Indicator
        body: Center(child: CircularProgressIndicator(color: primaryThemeColor)),
      );
    }

    return Scaffold(
      // 🎨 Scaffold बैकग्राउंड
      backgroundColor: themeColor,
      appBar: AppBar(
        // 🎨 AppBar स्टाइलिंग
        backgroundColor: themeColor,
        elevation: 0.0,
        // 🛠️ टाइटल
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Text(
            "Profile",
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          // 💜 Reel Upload Button
          IconButton(
            onPressed: _navigateToReelUpload,
            icon: const Icon(Icons.videocam_rounded),
            color: primaryThemeColor,
            tooltip: 'Upload Reel',
          ),
          // 💜 Settings Icon
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            icon: const Icon(Icons.settings),
            color: primaryThemeColor,
            tooltip: 'Settings',
          ),
        ],
      ),
      // --- DRAWER (Medium Purple Styled) ---
      drawer: Drawer(
        backgroundColor: themeColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(Supabase.instance.client.auth.currentUser?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                // 💜 Accent color for placeholder
                backgroundColor: accentColor.withOpacity(0.1),
                backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                    ? NetworkImage(userImageUrl!)
                    : const NetworkImage("https://picsum.photos/200?random=20"),
              ),
              decoration: BoxDecoration(
                // 💜 Primary Color Header
                color: primaryThemeColor,
              ),
            ),
            // ⭐ Menu Items (Themes के अनुसार रंग)
            ...menuItems.map((item) {
              // 🆕 Activity Page और Toggle Theme को एक साथ हैंडल करें
              if (item.title == 'Toggle Theme') {
                return Column(
                  children: [
                    // New Activity Page Link
                    ListTile(
                      leading: Icon(Icons.history_toggle_off_rounded, color: primaryThemeColor),
                      title: Text('Activity Page', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        _handleMenuTap('Activity Page');
                      },
                    ),
                    const Divider(height: 1),

                    // Original Toggle Theme
                    ListTile(
                      leading: Icon(item.icon, color: primaryThemeColor),
                      title: Text(item.title, style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        _handleMenuTap(item.title);
                      },
                    ),
                  ],
                );
              }

              String? trailing = item.isVerifiedOption
                  ? (_isVerified ? 'Verified' : 'Pending')
                  : null;

              return ListTile(
                leading: Icon(item.icon, color: primaryThemeColor), // 💜 Primary Color Icon
                title: Text(item.title, style: TextStyle(color: textColor)),
                trailing: trailing != null
                    ? Text(trailing, style: TextStyle(color: _isVerified ? Colors.green : primaryThemeColor)) // 💜 Pending Primary Color
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuTap(item.title);
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PROFILE HEADER ---
              ProfileHeader(
                userName: userName,
                userImageUrl: userImageUrl,
                bio: bio, // Bio passed
                isVerified: _isVerified,
                onLoadUserData: _loadUserData,
                onEditPressed: _navigateToEditProfile, // New parameter
                onSharePressed: _shareApp, // New parameter
                textColor: textColor, // New parameter
                primaryColor: primaryThemeColor, // New parameter
              ),

              const SizedBox(height: 40),

              // --- SUBSCRIPTION SECTION ---
              SubscriptionSection(
                onUpgradePressed: _navigateToUpgradeToGold,
                primaryColor: primaryThemeColor, // 💜 Primary Color
                accentColor: accentColor, // 💜 Accent Color
              ),

              const SizedBox(height: 40),

              // 🆕 --- MY REELS SECTION ---
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10),
                child: Text(
                  "My Reels",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // 🆕 MyReelsGrid widget
              MyReelsGrid(key: _myReelsGridKey),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}