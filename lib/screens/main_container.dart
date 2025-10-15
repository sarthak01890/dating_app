import 'package:dating_app/screens/buttomscreen/ReelsFeed.dart';
import 'package:dating_app/screens/buttomscreen/reel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'buttomscreen/profile_page.dart';
import 'buttomscreen/discover_page.dart';
import 'gamescreen/gaming.dart';
import 'buttomscreen/NewUsersPage.dart';
import 'down_button.dart'; // Apna DownButtonBar

class MainContainer extends StatefulWidget {
  final bool isDemoUser;

  const MainContainer({super.key,required this.isDemoUser});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  String? _userImageUrl;
    late List<Widget> _pages;

  // final List<Widget> _pages =  [
  //   DiscoverPage(isDemoUser:widget.isDemoUser),   // Index 0 -> Discover
  //   GamingPage(),// Index 1 -> Games
  //   ReelsFeedPage(),     // Index 2
  //   NewUsersPage(),   // Index 3 -> New Users
  //   ProfilePage(),    // Index 4 -> Profile
  // ];

  @override
  void initState() {
    super.initState();
     _pages = [
      DiscoverPage(isDemoUser: widget.isDemoUser), // Now safe
      GamingPage(),
      ReelsFeedPage(),
      NewUsersPage(isDemoUser: widget.isDemoUser),
      ProfilePage(isDemoUser: widget.isDemoUser),
    ];
    _loadUserImageUrl();
  }

  // ✅ Profile Image Supabase se load
  Future<void> _loadUserImageUrl() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('users')
            .select('image_url')
            .eq('id', user.id)
            .single();

        if (mounted && response != null) {
          final imageUrl = response['image_url'] as String?;

          String? finalUrl = imageUrl;
          if (imageUrl != null && !imageUrl.startsWith('http')) {
            finalUrl =
                supabase.storage.from('chatimages').getPublicUrl(imageUrl);
          }

          if (finalUrl != _userImageUrl) {
            setState(() {
              _userImageUrl = finalUrl;
            });
          }
        }
      } catch (e) {
        print('Error fetching user image: $e');
        if (mounted) setState(() => _userImageUrl = null);
      }
    } else {
      if (mounted) setState(() => _userImageUrl = null);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AnimatedSwitcher for smooth transition
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.1, 0), // Slide from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _pages[_selectedIndex],
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: DownButtonBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        userImageUrl: _userImageUrl,
      ),
    );
  }
}
