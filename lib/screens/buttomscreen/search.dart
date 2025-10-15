import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

const Color primaryPurple = Color(0xFF8A2BE2); // DiscoverPage का कलर

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // पेज लोड होने पर कोई प्रारंभिक डेटा लोड नहीं करते, यूज़र के टाइप करने का इंतज़ार करते हैं।
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Debounce Logic (बेहतर परफॉर्मेंस के लिए) ---
  // यहाँ आप Debouncing Logic जोड़ सकते हैं, पर सरलता के लिए अभी हर चेंज पर सर्च करते हैं।
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2 || query.isEmpty) { // 2 अक्षर के बाद सर्च शुरू करें
      _searchUsers(query);
    }
  }

  // --- Supabase से यूज़र्स को सर्च करने का मुख्य फंक्शन ---
  Future<void> _searchUsers(String query) async {
    if (!mounted || query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Current Date से 7 दिन पहले की तारीख (या 'New User' की आपकी परिभाषा)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      var queryBuilder = supabase
          .from('search_profiles') // ✅ हमने पिछले जवाब में यह टेबल नाम तय किया था
          .select('id, username, image_url, bio, created_at')
          .neq('id', supabase.auth.currentUser!.id); // खुद को बाहर रखें

      // 💡 केवल 'New Users' में सर्च करने के लिए फिल्टर
      // हम मानते हैं कि 'created_at' कॉलम 'auth.users' या 'search_profiles' में मौजूद है
      // और यह पिछले 7 दिनों का होना चाहिए।
      queryBuilder = queryBuilder.gte('created_at', sevenDaysAgo);

      // 💡 Username से सर्च
      queryBuilder = queryBuilder.ilike('username', '%$query%');

      final List<Map<String, dynamic>> response = await queryBuilder;

      if (mounted) {
        setState(() {
          _searchResults = response;
          _isSearching = false;
        });
      }
    } on PostgrestException catch (e) {
      log('Supabase Search Error: ${e.message}');
      if (mounted) {
        setState(() {
          _errorMessage = "Error: ${e.message}";
          _isSearching = false;
        });
      }
    } catch (e) {
      log('General Search Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "An unknown error occurred.";
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 🛠️ Search Bar सीधे AppBar में
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search New Users by name...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: primaryPurple),
              onPressed: () => _searchController.clear(),
            )
                : null,
          ),
          onChanged: (value) => setState(() {}), // UI अपडेट के लिए
        ),
        iconTheme: const IconThemeData(color: primaryPurple),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: primaryPurple))
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : _searchResults.isEmpty && _searchController.text.isNotEmpty
          ? Center(
        child: Text(
          "No new user found matching '${_searchController.text}'.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final userProfile = _searchResults[index];
          final imageUrl = userProfile['image_url'];
          final username = userProfile['username'] ?? 'User';

          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: primaryPurple.withOpacity(0.1),
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(Icons.person, color: primaryPurple)
                  : null,
            ),
            title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                userProfile['bio'] ?? 'New user in the last 7 days',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // TODO: इस यूज़र की प्रोफाइल पर नेविगेट करें
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing profile of $username')),
              );
            },
          );
        },
      ),
    );
  }
}