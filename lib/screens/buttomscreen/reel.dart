// reel.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🎯 CommentSheet.dart का Import Path
import 'package:dating_app/widgets/reelwidget/CommentSheet.dart';


// 💜 Global Color Definition
const Color primaryMediumPurple = Color(0xFF9370DB);

class ReelsFeedPage extends StatefulWidget {
  const ReelsFeedPage({super.key});

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage> with WidgetsBindingObserver {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _reels = [];
  bool _isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;
  Map<int, VideoPlayerController> _controllers = {};

  Map<String, bool> _reelLikeStatus = {};
  String? _currentUserId;

  // ⭐️ Current User ka naam store karne ke liye
  String? _currentUsername; // Default value null rakhte hain

  // ⭐️ Supabase se username fetch karein (Profiles table se)
  Future<void> _fetchUsername() async {
    _currentUserId = supabase.auth.currentUser?.id;
    // अगर यूज़र Logged-in नहीं है तो आगे न बढ़ें
    if (_currentUserId == null) {
      if(mounted) setState(() => _currentUsername = "Guest");
      return;
    }

    try {
      // 'profiles' table से username fetch करें
      final response = await supabase
          .from('users')
          .select('username')
          .eq('id', _currentUserId!)
          .maybeSingle(); // 💡 maybeSingle() का उपयोग करें ताकि row न मिलने पर null आए

      if (mounted) {
        // Fetch किए गए username को सुरक्षित रूप से Cast करें।
        final fetchedUsername = response?['username'] as String?;

        setState(() {
          // Fallback: अगर username null/empty है, तो User ID का पहला भाग उपयोग करें
          _currentUsername = fetchedUsername?.isNotEmpty == true
              ? fetchedUsername
              : _currentUserId!.substring(0, 8); // e.g., '12a3b4c5'
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
      if (mounted) {
        setState(() {
          _currentUsername = "ErrorUser"; // Debugging के लिए
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    // User ID set होने के बाद username fetch करें
    _currentUserId = supabase.auth.currentUser?.id;
    WidgetsBinding.instance.addObserver(this);
    _fetchUsername(); // Username fetch करें
    _fetchReels();
    _pageController.addListener(_pageChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Pause videos when app goes to background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controllers.forEach((_, controller) => controller.pause());
    } else {
      _controllers[_currentPage]?.play();
    }
  }

  void _pageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _controllers[_currentPage]?.pause();
        _currentPage = page;
        _controllers[_currentPage]?.play();
      });
    }
  }

  Future<void> _fetchReels() async {
    if (_currentUserId == null) {
      setState(() => _isLoading = false);
      print("User not logged in.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Fetch Reels data
      final List<dynamic> reelData = await supabase
          .from('reels')
          .select('video_url, caption');

      // 2. Fetch all current user's Likes from the 'user_favs' table
      final List<dynamic> userLikesData = await supabase
          .from('user_favs')
          .select('reel_id')
          .eq('user_id', _currentUserId!);

      final Set<String> likedReelIds = userLikesData
          .map((like) => like['reel_id'] as String)
          .toSet();

      final reels = reelData.map((e) => e as Map<String, dynamic>).toList();

      for (int i = 0; i < reels.length; i++) {
        final reelId = reels[i]['video_url'] as String;

        // Initialize video controller
        final controller =
        VideoPlayerController.networkUrl(Uri.parse(reelId));
        await controller.initialize();
        controller.setLooping(true);
        _controllers[i] = controller;

        _reelLikeStatus[reelId] = likedReelIds.contains(reelId);
      }

      if (mounted) {
        setState(() {
          _reels = reels;
        });
      }

    } catch (e) {
      print('Error fetching reels or likes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // Start playing the first video if available
        if (_controllers.containsKey(0)) _controllers[0]!.play();
      }
    }
  }

  Future<void> _toggleLikeStatus(String reelId, bool currentlyLiked) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like a reel.')),
      );
      return;
    }

    // Optimistic UI update
    setState(() {
      _reelLikeStatus[reelId] = !currentlyLiked;
    });

    try {
      if (currentlyLiked) {
        // UNLIKE: Delete record
        await supabase.from('user_favs')
            .delete()
            .eq('user_id', _currentUserId!)
            .eq('reel_id', reelId);
      } else {
        // LIKE: Insert new record
        await supabase.from('user_favs')
            .insert({
          'user_id': _currentUserId,
          'reel_id': reelId,
        });
      }
    } catch (e) {
      // Failure: Local state ko revert karein
      if (mounted) {
        setState(() {
          _reelLikeStatus[reelId] = currentlyLiked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like status on server.')),
        );
      }
      print('Supabase Like Toggle Error: $e');
    }
  }

  // ⭐️ FUNCTION: Comment slider (Modal Bottom Sheet)
  void _showCommentSheet(BuildContext context, String reelId) {
    // Video ko pause karein
    _controllers[_currentPage]?.pause();

    // 🎯 currentUsername को pass करें। अगर null है तो भी safe fallback दें।
    // Username fetch होने तक 'Loading...' या 'Guest' दिखाया जा सकता है
    final username = _currentUsername ?? "Loading...";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // currentUsername को CommentSheet में pass करें
        return CommentSheet(reelId: reelId, currentUsername: username);
      },
    ).whenComplete(() {
      // Jab sheet band ho jaye to video ko resume karein
      _controllers[_currentPage]?.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method)
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryMediumPurple))
          : _reels.isEmpty
          ? const Center(child: Text('No reels found.'))
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final controller = _controllers[index];

          final String reelId = reel['video_url'] as String;
          final bool isLiked = _reelLikeStatus[reelId] ?? false;


          return Stack(
            children: [
              // --- Video Player ---
              GestureDetector(
                onTap: () {
                  if (controller != null && controller.value.isInitialized) {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  }
                },
                child: controller != null && controller.value.isInitialized
                    ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                )
                    : const Center(
                  child: CircularProgressIndicator(color: primaryMediumPurple),
                ),
              ),

              // Play/Pause icon overlay
              if (controller != null && !controller.value.isPlaying && controller.value.isInitialized)
                Icon(Icons.play_arrow, size: 80.0, color: Colors.white.withOpacity(0.8)),


              // --- Caption ---
              Positioned(
                left: 16,
                bottom: 50,
                child: Text(
                  reel['caption'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 5,
                        color: Colors.black87,
                      )
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // --- Action Icons ---
              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ❤️ Like button
                    GestureDetector(
                      onTap: () => _toggleLikeStatus(reelId, isLiked),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Likes',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 💬 Comment button - CALLS THE SHEET
                    GestureDetector(
                      // सुनिश्चित करें कि _currentUsername fetch हो चुका है
                      onTap: () {
                        if (_currentUsername != null) {
                          _showCommentSheet(context, reelId);
                        } else {
                          // अगर fetch नहीं हुआ है तो लोडिंग मैसेज दिखाएं
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fetching username... Please wait.')),
                          );
                        }
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.comment, color: Colors.white, size: 32),
                          SizedBox(height: 5),
                          Text('Comments', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📤 Share button
                    GestureDetector(
                      onTap: () { /* Add share action */ },
                      child: Column(
                        children: const [
                          Icon(Icons.share, color: Colors.white, size: 32),
                          SizedBox(height: 5),
                          Text('Share', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}