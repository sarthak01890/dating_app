import 'dart:io'; // dart:io for File, required for mobile
import 'dart:typed_data'; // dart:typed_data for Uint8List, required for web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Import this to check for web platform

class UserImagePicker extends StatefulWidget {
  // The callback now takes Uint8List, which works for both web and mobile.
  final void Function(dynamic pickedImage) onPickImage;

  const UserImagePicker({super.key, required this.onPickImage});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  // Use 'dynamic' or nullable types to handle both File and Uint8List
  dynamic _pickedImage;
  Uint8List? _pickedImageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Handle web platform
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImage = bytes;
        });
        widget.onPickImage(bytes);
      } else {
        // Handle mobile/desktop platforms
        final File file = File(pickedFile.path);
        setState(() {
          _pickedImage = file;
          _pickedImageBytes = null;
        });
        widget.onPickImage(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (kIsWeb && _pickedImageBytes != null) {
      imageProvider = MemoryImage(_pickedImageBytes!);
    } else if (!kIsWeb && _pickedImage is File) {
      imageProvider = FileImage(_pickedImage as File);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: imageProvider,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text("Add Image"),
        ),
      ],
    );
  }
}
