import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// --- Global Color Definition ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController(); // New bio controller

  String? _selectedCountry;
  String? _selectedLanguage;
  File? _pickedImage;

  final List<String> _countries = ["India", "USA", "UK", "Canada", "Australia"];
  final List<String> _languages = [
    "English", "Hindi", "Tamil", "Telugu", "Bengali",
    "Marathi", "Gujarati", "Punjabi", "Kannada", "Malayalam",
  ];
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUserId = supabase.auth.currentUser!.id;

    // TODO: 'users' के बजाय सही टेबल नाम का उपयोग सुनिश्चित करें
    final response = await supabase.from('users').select().eq('id', currentUserId).single();

    if (response != null && mounted) {
      _nameController.text = response['username'] ?? '';
      _ageController.text = response['age']?.toString() ?? '';
      _numberController.text = response['number'] ?? '';
      _cityController.text = response['city'] ?? '';
      _selectedCountry = response['country'];
      _selectedLanguage = response['language'];
      _bioController.text = response['bio'] ?? ''; // Load bio
      setState(() {
        userImageUrl = response['image_url'] as String?;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
    // TODO: यहाँ पर इमेज अपलोड और `userImageUrl` अपडेट करने का लॉजिक जोड़ें।
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUserId = supabase.auth.currentUser!.id;

      // TODO: Image upload logic before saving profile data
      String? newImageUrl = userImageUrl;
      if (_pickedImage != null) {
        // Example logic for image upload (needs proper implementation)
        // final uploadUrl = await _uploadImageToStorage(_pickedImage!);
        // newImageUrl = uploadUrl;
      }

      final profileData = {
        "id": currentUserId,
        "username": _nameController.text,
        "age": int.tryParse(_ageController.text) ?? 0,
        "number": _numberController.text,
        "city": _cityController.text,
        "country": _selectedCountry,
        "language": _selectedLanguage,
        "bio": _bioController.text, // Save bio
        "image_url": newImageUrl, // Save new image URL
      };

      try {
        await supabase.from('users').upsert(profileData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
      }
    }
  }

  // 📝 TextField विजेट (Violet Theme)
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryViolet),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryViolet, width: 2), // 💜 Focused Border
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? "Enter your $label" : null,
    );
  }

  // 🔽 Dropdown विजेट (Violet Theme)
  Widget _buildDropdown(
      String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryViolet),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryViolet, width: 2), // 💜 Focused Border
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Select a $label" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Scaffold बैकग्राउंड को थीम से अलग रखने के लिए
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryViolet, // 💜 AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) // 🖼️ Picked image
                          : (userImageUrl != null && userImageUrl!.isNotEmpty
                          ? NetworkImage(userImageUrl!) as ImageProvider
                          : const NetworkImage("https://picsum.photos/200?random=20")
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: primaryViolet, // 💜 Edit Icon Background
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Name"),
              const SizedBox(height: 12),
              _buildTextField(_ageController, "Age", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_numberController, "Phone Number", keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_cityController, "City"),
              const SizedBox(height: 12),
              _buildDropdown("Country", _selectedCountry, _countries, (val) => setState(() => _selectedCountry = val)),
              const SizedBox(height: 12),
              _buildDropdown("Language", _selectedLanguage, _languages, (val) => setState(() => _selectedLanguage = val)),
              const SizedBox(height: 12),
              _buildTextField(_bioController, "Bio", maxLines: 4), // New bio field
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryViolet, // 💜 Save Button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Profile", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}