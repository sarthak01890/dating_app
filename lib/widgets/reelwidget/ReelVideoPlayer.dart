import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// 💜 Global Color Definition (Medium Purple)
const Color primaryMediumPurple = Color(0xFF9370DB);

// Simple data model for Reel
class Reel {
  final String videoUrl;
  final String caption;
  final String userId;

  Reel({
    required this.videoUrl,
    required this.caption,
    required this.userId,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      videoUrl: json['video_url'] as String,
      caption: json['caption'] as String,
      userId: json['user_id'] as String,
    );
  }
}

// ✅ StatefulWidget must be defined before its State
class ReelVideoPlayer extends StatefulWidget {
  final Reel reel;

  const ReelVideoPlayer({super.key, required this.reel});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  // ❤️ Like state & count
  bool _isLiked = false;
  int _likeCount = 12000; // Starting likes (12K)

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      }).catchError((error) {
        print("Video Initialization Error: $error");
        setState(() {
          _isInitialized = false;
        });
      });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  // ❤️ Toggle Like
  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: _isInitialized
                    ? VideoPlayer(_controller)
                    : const Center(
                  child: CircularProgressIndicator(color: primaryMediumPurple),
                ),
              ),
            ),
          ),

          if (!_controller.value.isPlaying)
            Icon(Icons.play_arrow, size: 80.0, color: Colors.white.withOpacity(0.8)),

          // User info & caption
          Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.reel.userId.substring(0, 8)}...',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 5.0, color: Colors.black)]),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    widget.reel.caption,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [Shadow(blurRadius: 5.0, color: Colors.black)]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ❤️ Action Buttons (Right side)
          // ❤️ Action Buttons (Right side)
          Positioned(
            right: 10,
            bottom: 50,
            child: Column(
              children: [
                // Like button - MODIFIED
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        // The icon correctly turns red based on the local _isLiked state.
                        color: _isLiked ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 5),
                      // Show the like count
                      Text(
                        _likeCount >= 1000
                            ? '${(_likeCount / 1000).toStringAsFixed(1)}K'
                            : '$_likeCount',
                        style: const TextStyle(color: Colors.white),
                      ),
                      // Add the "Likes" label underneath the count.
                      const Text(
                        'Likes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Smaller font for the label
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Comment button (unchanged)
                Column(
                  children: const [
                    Icon(Icons.comment, color: Colors.white, size: 30),
                    SizedBox(height: 5),
                    Text('300', style: TextStyle(color: Colors.white)),
                    // Add a "Comments" label for consistency
                    Text(
                      'Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Share button (unchanged)
                Column(
                  children: const [
                    Icon(Icons.share, color: Colors.white, size: 30),
                    SizedBox(height: 5),
                    // Add a "Share" label for consistency
                    Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
