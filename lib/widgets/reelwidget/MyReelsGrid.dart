import 'package:dating_app/widgets/reelwidget/ReelVideoPlayer.dart'; // Reel model ke liye
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Global Color Definition ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)

class MyReelsGrid extends StatefulWidget {
  const MyReelsGrid({super.key});

  @override
  State<MyReelsGrid> createState() => _MyReelsGridState();
}

class _MyReelsGridState extends State<MyReelsGrid> {
  final supabase = Supabase.instance.client;
  late Future<List<Reel>> _myReelsFuture;

  @override
  void initState() {
    super.initState();
    _myReelsFuture = _fetchMyReels();
  }

  // --- Current User ki Reels Fetch karna ---
  Future<List<Reel>> _fetchMyReels() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await supabase
          .from('reels')
          .select()
          .eq('user_id', userId) // Sirf current user ki reels
          .order('created_at', ascending: false);

      if (response != null && response is List) {
        // Assuming Reel.fromJson is correctly defined in ReelVideoPlayer.dart
        return response.map((json) => Reel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user reels: $e');
      return [];
    }
  }

  // Reload Reels function for use after Edit/Delete
  void _reloadReels() {
    setState(() {
      _myReelsFuture = _fetchMyReels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reel>>(
      future: _myReelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                // 💜 Violet color for loading indicator
                child: CircularProgressIndicator(color: primaryViolet),
              ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading reels: ${snapshot.error}'));
        }

        final reels = snapshot.data ?? [];

        if (reels.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(30.0),
            child: Center(
              child: Text(
                'No reels uploaded yet. Tap the upload button to share!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Main SingleChildScrollView handle karega
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 0.7, // Reels ka aspect ratio
          ),
          itemCount: reels.length,
          itemBuilder: (context, index) {
            final reel = reels[index];
            // Yahan hum sirf video ka thumbnail dikha rahe hain (placeholder)
            return GestureDetector(
              onTap: () {
                _showReelOptions(reel);
              },
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video thumbnail placeholder
                      const Icon(Icons.videocam, color: Colors.white54, size: 40),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Text(
                          reel.caption ?? 'No Caption',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Edit aur Delete options dikhane ke liye
  void _showReelOptions(Reel reel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit, color: primaryViolet), // 💜 Violet
              title: const Text('Edit Reel (Caption)'),
              onTap: () {
                Navigator.pop(context);
                _editReelCaption(reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Reel'),
              onTap: () {
                Navigator.pop(context);
                _deleteReel(reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: primaryViolet), // 💜 Violet
              title: const Text('View Reel in Feed'),
              onTap: () {
                // ... logic to view reel ...
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Reel Caption Edit karne ka logic
  void _editReelCaption(Reel reel) {
    // 💡 Add Dialog for editing caption here
    // Example: showDialog(...)
    final TextEditingController _captionController = TextEditingController(text: reel.caption);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Caption'),
        content: TextField(
          controller: _captionController,
          decoration: const InputDecoration(labelText: 'New Caption'),
          maxLength: 150,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveNewCaption(reel.videoUrl!, _captionController.text);
            },
            child: const Text('Save', style: TextStyle(color: primaryViolet)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewCaption(String videoUrl, String newCaption) async {
    try {
      await supabase
          .from('reels')
          .update({'caption': newCaption})
          .eq('video_url', videoUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption updated successfully!')),
      );
      _reloadReels();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update caption: $e')),
      );
    }
  }

  // Reel Delete karne ka logic
  Future<void> _deleteReel(Reel reel) async {
    try {
      // 1. Database se entry delete karein
      await supabase.from('reels').delete().eq('video_url', reel.videoUrl);

      // 2. Storage se file delete karein (Optional, file path assuming it's the last part of videoUrl)
      // This part requires knowing the bucket name ('reels' or 'chatimages' depending on your setup)
      /*
      if (reel.videoUrl != null && reel.videoUrl!.contains('/')) {
         final filePath = reel.videoUrl!.split('/').last;
         await supabase.storage.from('your_bucket_name').remove([filePath]);
      }
      */

      // 3. UI update karein
      _reloadReels();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel deleted successfully!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reel: $e')),
      );
    }
  }
}