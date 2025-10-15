import 'dart:io';
import 'dart:typed_data';
import 'package:dating_app/screens/buttomscreen/discover_page.dart';
import 'package:dating_app/screens/main_container.dart';
import 'package:dating_app/screens/profilescreen/demouser.dart';
import 'package:dating_app/widgets/chatwidgets/user_image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Global Color Definition ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating = false;
  bool _isPasswordVisible = false;

  String _enteredEmail = '';
  String _enteredUsername = '';
  String _enteredPassword = '';
  File? _selectedImage;
  Uint8List? _selectedImageBytes;

  // 💜 Updated colors to match 0xFF8A2BE2 theme
  final Color _primaryColor = primaryViolet;
  final Color _secondaryColor = primaryViolet.withOpacity(0.3); // Light accent for borders

  // --- EXISTING LOGIC (Unchanged) ---
  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    // Validate image only on signup and if running on web or mobile
    if (!isValid || (!_isLogin && (_selectedImage == null && _selectedImageBytes == null))) {
      if (!_isLogin && (_selectedImage == null && _selectedImageBytes == null)) {
        // Show a message if image is missing during signup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image for your profile.')),
        );
      }
      return;
    }

    _form.currentState!.save();
    final supabase = Supabase.instance.client;
    Uint8List? fileBytes;
    String? fileExtension;

    // Image logic for Signup
    if (!_isLogin) {
      if (kIsWeb) {
        if (_selectedImageBytes == null) return;
        fileBytes = _selectedImageBytes!;
        fileExtension = 'png'; // Default for web uploads
      } else {
        if (_selectedImage == null) return;
        fileBytes = await _selectedImage!.readAsBytes();
        fileExtension = _selectedImage!.path.split('.').last;
      }
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        // Login Logic: Check if input is email or username
        final isEmail = _enteredEmail.contains('@');
        String emailToLogin;

        if (isEmail) {
          emailToLogin = _enteredEmail;
        } else {
          // Find email by username
          final List<dynamic> response = await supabase
              .from('users')
              .select('email')
              .eq('username', _enteredEmail.toLowerCase().trim()) // Use toLowerCase/trim for robust search
              .limit(1);

          if (response.isEmpty) throw 'User not found';
          emailToLogin = response[0]['email'];
        }

        await supabase.auth.signInWithPassword(
          email: emailToLogin,
          password: _enteredPassword,
        );
        // Successful login: Navigate to MainContainer
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const MainContainer(isDemoUser: false,)),
                (route) => false,
          );
        }
      } else {
        // Signup Logic
        final AuthResponse res = await supabase.auth.signUp(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Check if signup was successful and we have an image
        if (res.user != null && fileBytes != null) {
          final userId = res.user!.id;

          // 1. Upload Image to Supabase Storage
          // NOTE: Supabase storage bucket name is hardcoded to 'chatimages' here.
          final imagePath = 'user_images/$userId.$fileExtension';
          await supabase.storage.from('chatimages').uploadBinary(
            imagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
          final publicUrl = supabase.storage.from('chatimages').getPublicUrl(imagePath);

          // 2. Insert user data into 'users' table
          await supabase.from("users").insert({
            "id": userId,
            "username": _enteredUsername.trim(), // Trim username
            "email": _enteredEmail.trim(), // Trim email
            "image_url": publicUrl,
            "created_at": DateTime.now().toIso8601String(),
          });

          // Successful signup: Show success message and switch to login
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "✅ Your account has been created successfully. Please log in to continue.",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: primaryViolet, // 💜 Snack Bar
                duration: Duration(seconds: 3),
              ),
            );

            setState(() {
              _isLogin = true; // switch back to login mode
              _enteredEmail = ''; // Clear fields for new login
              _enteredPassword = '';
              _enteredUsername = '';
              _selectedImage = null;
              _selectedImageBytes = null;
            });
          }
        }
      }
    } on AuthException catch (e) {
      // Handle Supabase Auth errors (e.g., duplicate email)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication Error: ${e.message}')),
      );
    } catch (error) {
      // Handle other errors (e.g., storage, database, user not found)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${error.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }
  void _demoLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (ctx) => const MainContainer(isDemoUser: true), // 👈 Demo flag
        ),
            (route) => false,
      );
    }
  }

  // --- END EXISTING LOGIC ---

  // 💅 Professional Input Decoration Style
  InputDecoration _getInputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: _primaryColor),
      prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _secondaryColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _secondaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primaryColor, width: 2.0), // 💜 Active focus highlight
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              // 📐 Subtle, modern card style
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: _primaryColor.withOpacity(0.1), // 💜 Violet shadow
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and App Name
                      Image.asset("assets/images/splash5.png", width: 80),
                      const SizedBox(height: 10),
                      Text(
                        _isLogin ? "Ruready" : "Create Your Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _primaryColor, // 💜 Violet Title
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? "Welcome back, matchmaker."
                            : "Join the fun and find your next date.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // User Image picker for signup
                      if (!_isLogin)
                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            if (kIsWeb) {
                              _selectedImageBytes = pickedImage;
                              _selectedImage = null;
                            } else {
                              _selectedImage = pickedImage;
                              _selectedImageBytes = null;
                            }
                          },
                        ),
                      if (!_isLogin) const SizedBox(height: 20),

                      // Email / Username
                      TextFormField(
                        decoration: _getInputDecoration(
                          labelText: _isLogin ? 'Email or Username' : 'Email Address',
                          icon: Icons.alternate_email,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a valid value';
                          }
                          if (!_isLogin && !value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => _enteredEmail = value!,
                      ),
                      const SizedBox(height: 15),

                      // Username field for signup
                      if (!_isLogin)
                        TextFormField(
                          decoration: _getInputDecoration(
                              labelText: 'Public Username', icon: Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'Minimum 4 characters required';
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredUsername = value!,
                        ),
                      if (!_isLogin) const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        decoration: _getInputDecoration(labelText: 'Password', icon: Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: _primaryColor.withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        onSaved: (value) => _enteredPassword = value!,
                      ),

                      const SizedBox(height: 30),

                      // Primary Button (Login/Sign Up)
                      if (_isAuthenticating)
                        const CircularProgressIndicator(color: primaryViolet) // 💜 Violet loading
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor, // 💜 Violet Button
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              _isLogin ? 'LOG IN' : 'SIGN UP',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white), // White text on purple
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Secondary Actions

                      // 1. Switch login/signup
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            // Reset form fields when switching modes
                            _form.currentState!.reset();
                            _enteredEmail = '';
                            _enteredUsername = '';
                            _enteredPassword = '';
                            _selectedImage = null;
                            _selectedImageBytes = null;
                            _isPasswordVisible = false;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? "New here? Create an account"
                              : "Already a member? Log in",
                          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold), // 💜 Violet Link
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Demo User Button (Use OutlinedButton for secondary action)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _demoLogin,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _primaryColor, width: 2), // 💜 Violet Border
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Continue as Demo User",
                            style: TextStyle(fontSize: 16, color: _primaryColor), // 💜 Violet Text
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}