// lib/screens/buttomscreen/new_users_page.dart


import 'package:dating_app/screens/buttomscreen/userprofiledetail.dart';
import 'package:dating_app/widgets/top_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Zaroori Imports
import '../../models/user_model.dart';


class NewUsersPage extends StatefulWidget {
  final bool isDemoUser;
  const NewUsersPage({Key? key,required this.isDemoUser}) : super(key: key);

  @override
  State<NewUsersPage> createState() => _NewUsersPageState();
}

class _NewUsersPageState extends State<NewUsersPage> {
  final supabase = Supabase.instance.client;
  late Future<List<UserModel>> _usersFuture;

  // 🔍 Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchNewUsers();

    // Listen to search bar changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Data Fetching ---
  Future<List<UserModel>> _fetchNewUsers() async {
    // final currentUserId = supabase.auth.currentUser!.id;
      final currentUserId = widget.isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    // Handle the case when there is no logged-in user
    return [];
  }

    final response = await supabase
        .from('users')
        .select()
        .neq('id', currentUserId) // exclude self
        .order('created_at', ascending: false); // newest first

    if (response == null) return [];

    return List<Map<String, dynamic>>.from(response)
        .map((map) => UserModel.fromJson(map))
        .toList();
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            "New Faces",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Top Search Bar
          TopSearchBar(
            searchController: _searchController,
            hintText: "Search users by name...",
          ),

          // 📋 User List
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.purple));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                var users = snapshot.data ?? [];

                // 🔎 Filter by search query
                if (_searchQuery.isNotEmpty) {
                  users = users
                      .where((u) =>
                  u.username != null &&
                      u.username!.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildNewUserListTile(context, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // 💎 प्रोफेशनल यूज़र लिस्ट टाइल विजेट
  // ------------------------------------------------------------------

  Widget _buildNewUserListTile(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileDetailPage(user: user)
              ),
            );
          },
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Row(
              children: [
                // 🖼️ प्रोफाइल पिक्चर
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.imageUrl.toString()),
                  backgroundColor: Colors.grey.shade100,
                ),
                const SizedBox(width: 15),

                // 📝 नाम और लोकेशन
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.purple, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${user.city ?? ''}${user.country != null ? ' • ${user.country!}' : ''}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ➡️ ट्रेलिंग बटन
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileDetailPage(user: user),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

