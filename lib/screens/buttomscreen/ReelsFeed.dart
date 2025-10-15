import 'dart:io';
import 'package:dating_app/screens/buttomscreen/reel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Global Color Definitions ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet
const Color accentPurple = Color(0xFF9370DB); // Accent Purple

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final supabase = Supabase.instance.client;

  File? _videoFile;
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  // --- 1. Video Picker ---
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Agar pehle se koi controller hai, to usse dispose kar dein
      _videoController?.dispose();

      // Naya controller initialize karein
      _videoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
          _videoController!.setLooping(true);
        });

      setState(() {
        _videoFile = file;
      });
    }
  }

  // --- 2. Upload Logic (Updated) ---
  Future<void> _uploadReel() async {
    if (_videoFile == null) {
      _showSnackBar('Please select a video first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Compress the video first
      final compressedInfo = await VideoCompress.compressVideo(
        _videoFile!.path,
        quality: VideoQuality.MediumQuality, // reduces size
        deleteOrigin: false,
      );

      if (compressedInfo == null) {
        _showSnackBar('Video compression failed.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final compressedFile = File(compressedInfo.path!);

      // Check file size (50 MB limit for free tier)
      final fileSize = await compressedFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        _showSnackBar('Video too large! Please select a smaller one.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if user is logged in
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('You must be logged in to upload a reel.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final currentUserId = currentUser.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = compressedFile.path.split('.').last;
      final filePath = '$currentUserId/$timestamp.$fileExtension';

      // Upload to Supabase Storage
      await supabase.storage.from('reels').upload(
        filePath,
        compressedFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get public URL
      final publicUrl = supabase.storage.from('reels').getPublicUrl(filePath);

      // Insert metadata into DB
      await supabase.from('reels').insert({
        'user_id': currentUserId,
        'video_url': publicUrl,
        'caption': _captionController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Reel uploaded successfully! Navigating to feed...');

      // Navigate to the Reels Feed page
      if (mounted) {
        Navigator.pushReplacement( // Using pushReplacement to prevent going back to upload screen easily
          context,
          MaterialPageRoute(
            // NOTE: Ensure ReelsFeedPage is correctly defined and imported,
            // the original code had a placeholder for its constructor.
            builder: (_) => const ReelsFeedPage(),
          ),
        );
      }

      // Reset state (although navigation might make this redundant, it's good practice)
      _videoController?.pause();
      setState(() {
        _videoFile = null;
        _videoController = null;
        _captionController.clear();
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Upload failed: ${e.toString()}');
      print('Supabase Upload Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Utility ---
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reel Upload'),
        backgroundColor: primaryViolet, // Applied primaryViolet
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🎬 Video Preview Area
            _videoFile == null
                ? Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentPurple), // Applied accentPurple
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_collection, size: 50, color: accentPurple), // Applied accentPurple
                    const SizedBox(height: 8),
                    const Text("No video selected", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
                : AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),

            const SizedBox(height: 20),

            // ✍️ Caption Input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Add a caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: primaryViolet), // Applied primaryViolet on focus
                ),
                prefixIcon: const Icon(Icons.description, color: primaryViolet), // Applied primaryViolet
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // ➕ Pick Video Button
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: Text(
                _videoFile == null ? 'Select Reel Video' : 'Change Video',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryViolet, // Applied primaryViolet
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 15),

            // ⬆️ Upload Button
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet)) // Applied primaryViolet
                : ElevatedButton.icon(
              onPressed: _uploadReel,
              icon: const Icon(Icons.cloud_upload, color: primaryViolet), // Applied primaryViolet
              label: const Text(
                'Upload Reel',
                style: TextStyle(fontSize: 16, color: primaryViolet), // Applied primaryViolet
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryViolet.withOpacity(0.05), // A light shade of primaryViolet
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: primaryViolet), // Applied primaryViolet
              ),
            ),
          ],
        ),
      ),
    );
  }
}