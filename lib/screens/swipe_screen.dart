import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import zaroori hai
import '../models/user_model.dart';

class SwipeScreen extends StatefulWidget {
  final List<UserModel> users;

  const SwipeScreen({Key? key, required this.users}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with SingleTickerProviderStateMixin {

  final supabase = Supabase.instance.client; // 🔑 Supabase client instance

  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  String? _swipeStatus; // LIKE / NOPE / null / No more users

  // 💅 Animation for the central feedback icon
  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _initSwipeItems();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  // 1. Backend Logic for handling the LIKE action
  Future<void> _handleLikeAction(UserModel targetUser) async {
    final currentUserId = supabase.auth.currentUser?.id;
    final targetUserId = targetUser.id;

    if (currentUserId == null || targetUserId == null) {
      print('Error: Current user or target user ID is missing.');
      return;
    }

    try {
      // 'likes' table mein entry daalna
      await supabase.from('likes').insert({
        'swiper_id': currentUserId,   // Jisne swipe kiya
        'target_id': targetUserId,    // Jisko like kiya (Is user ko notification milega)
        'status': 'liked',
        'is_new': true,               // Naye like ko track karne ke liye
      });

      print('✅ User $currentUserId liked $targetUserId. Database updated.');

    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Check for unique constraint violation
        print('Warning: User $currentUserId already liked $targetUserId.');
      } else {
        print('🚨 Supabase Error liking user: ${e.message}');
      }
    } catch (e) {
      print('🚨 Generic Error liking user: $e');
    }
  }

  void _initSwipeItems() {
    for (var user in widget.users) {
      _swipeItems.add(
        SwipeItem(
          content: user,
          likeAction: () {
            _showSwipeIcon("LIKE");
            // 🚀 Right-swipe par like handler call hoga
            _handleLikeAction(user);
          },
          nopeAction: () {
            _showSwipeIcon("NOPE");
            // Add NOPE logic here
          },
        ),
      );
    }
  }

  void _showSwipeIcon(String status) {
    setState(() {
      _swipeStatus = status;
    });

    _feedbackController.reset();
    _feedbackController.forward();

    // Reset status after animation completes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _swipeStatus = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // 📝 Custom Widget for User Info overlay
  Widget _buildUserInfoOverlay(UserModel user) {
    return Container(
      // Gradient for professional card bottom-fade
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.7, 1.0], // Start black fade from 70% down
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📛 Name and Country/Age
          Text(
            "${user.username}, ${user.country}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 3))],
            ),
          ),
          const SizedBox(height: 4),
          // 💼 Tagline/Bio
          Text(
            user.bio.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              shadows: [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(0, 1))],
            ),
          ),
          const SizedBox(height: 8),
          // ℹ️ Secondary Info Chips
          Row(
            children: [
              _buildInfoChip(icon: Icons.flag, label: user.country.toString()),
              const SizedBox(width: 8),
              _buildInfoChip(icon: Icons.language, label: user.language.toString()),
            ],
          ),
        ],
      ),
    );
  }

  // 💊 Info Chip Widget
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🃏 Swipe Cards Section
        SwipeCards(
          matchEngine: _matchEngine,
          itemBuilder: (context, index) {
            final user = widget.users[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 🖼️ Image Background
                  Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: user.imageUrl.toString(),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.purple)),
                        errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 80, color: Colors.grey.shade400),
                      )
                  ),

                  // 💬 Info Overlay
                  Positioned.fill(
                    child: _buildUserInfoOverlay(user),
                  ),
                ],
              ),
            );
          },
          onStackFinished: () {
            setState(() => _swipeStatus = "No more users");
            Future.delayed(const Duration(seconds: 2), () {
              if(mounted) setState(() => _swipeStatus = null);
            });
          },
          upSwipeAllowed: true,
          fillSpace: true,
        ),

        // Swipe Overlay Icon with Professional Fade-Out Animation
        if (_swipeStatus == "LIKE" || _swipeStatus == "NOPE")
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _swipeStatus == "LIKE" ? Colors.green.shade600 : Colors.red.shade600,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _swipeStatus!,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _swipeStatus == "LIKE" ? Colors.green.shade600 : Colors.red.shade600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // ✅ Professional "No more users" overlay
        if (_swipeStatus == "No more users")
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.purple.shade900,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.thumb_up_alt_rounded, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "You're All Caught Up!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Check back later for new matches.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}