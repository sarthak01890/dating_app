// lib/screens/buttomscreen/likepage.dart file

import 'package:dating_app/screens/chatscreen/PersonalChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback के लिए
import 'package:supabase_flutter/supabase_flutter.dart';

// Zaroori Imports
import '../../models/user_model.dart';

// --- Global Color Definitions ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet (वायलेट रंग)
const Color accentPurple = Color(0xFF9370DB); // Medium Purple (एक्सेंट रंग)

class LikesPage extends StatefulWidget {
  final bool isDemoUser;
  const LikesPage({super.key,required this.isDemoUser});

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  final supabase = Supabase.instance.client;
  late Future<List<UserModel>> _likedUsersFuture;

  @override
  void initState() {
    super.initState();
    _markLikesAsSeen();
    _likedUsersFuture = _fetchLikedUsers();
  }

  // --- Data Fetching ---
  Future<List<UserModel>> _fetchLikedUsers() async {
    final currentUserId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('likes')
        .select('swiper_id')
        .eq('target_id', currentUserId);

    if (response.isEmpty) return [];

    final likedUserIds = response.map((e) => e['swiper_id'] as String).toList();
    final idsString = likedUserIds.join(',');

    // TODO: सुनिश्चित करें कि आप 'users' टेबल के बजाय 'search_profiles' या
    // उस टेबल का उपयोग कर रहे हैं जहाँ आपका यूज़र डेटा है।
    final usersResponse = await supabase
        .from('users')
        .select()
        .filter('id', 'in', '($idsString)');

    if (usersResponse.isEmpty) return [];

    return List<Map<String, dynamic>>.from(usersResponse)
        .map((map) => UserModel.fromJson(map))
        .toList();
  }

  // --- Notification Handling ---
  Future<void> _markLikesAsSeen() async {
    final currentUserId = supabase.auth.currentUser!.id;

    try {
      await supabase
          .from('likes')
          .update({'is_new': false})
          .eq('target_id', currentUserId)
          .eq('is_new', true);

      print('✅ All new likes marked as seen.');
    } catch (e) {
      print('🚨 Error marking likes as seen: $e');
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // थीम कलर को सपोर्ट करने के लिए
    final themeColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        // 🌟 'Notification' को लेफ्ट साइड में और बड़ा करने के लिए बदलाव
        centerTitle: false, // टाइटल को सेंटर से हटाएँ
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0), // हल्का सा इंडेंट
          child: Text(
            "Notifications", // नाम Likes से बदलकर Notifications किया गया
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900, // एक्स्ट्रा बोल्ड
              fontSize: 28, // टाइटल को बड़ा करें
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: primaryViolet), // 💜 Back Icon को वायलेट करें
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _likedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 💜 CircularProgressIndicator को वायलेट करें
            return const Center(child: CircularProgressIndicator(color: primaryViolet));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading likes: ${snapshot.error}"));
          }

          final likedUsers = snapshot.data ?? [];

          if (likedUsers.isEmpty) {
            return const Center(
              child: Text("Nobody has liked you yet. Keep swiping!"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            itemCount: likedUsers.length,
            itemBuilder: (context, index) {
              final user = likedUsers[index];
              return _buildProfessionalUserListTile(user);
            },
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // 💎 मॉडिफाइड: प्रोफेशनल लिस्ट टाइल विजेट (Message Icon के साथ)
  // ------------------------------------------------------------------

  Widget _buildProfessionalUserListTile(UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 1, // शैडो को 2 से 1 किया गया (अधिक सूक्ष्मता के लिए)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // कॉर्नर को 12 से 15 किया गया
        ),
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            HapticFeedback.lightImpact(); // 👆 हल्का वाइब्रेशन
            // 💬 Chat Screen पर navigate करें
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalChatScreen(
                  otherUser: {
                    'id': user.id.toString(),
                    'username': user.username.toString(),
                  }, isDemoUser: widget.isDemoUser,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Row(
              children: [
                // 🖼️ लीडिंग: प्रोफाइल पिक्चर
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.imageUrl.toString()),
                  backgroundColor: Colors.grey.shade100, // लोडिंग के लिए हल्का रंग
                ),
                const SizedBox(width: 15),

                // 📝 टाइटल और सबटाइटल एरिया
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, // W800 से W700 थोड़ा सॉफ्ट
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4), // स्पेसिंग बढ़ाई गई
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: primaryViolet, size: 14), // 💜 Icon को वायलेट करें
                          const SizedBox(width: 4),
                          Text(
                            user.country.toString(),
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

                // ➡️ ट्रेलिंग: Message Icon Button
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: primaryViolet, // 💜 Background को Primary Violet करें
                    shape: BoxShape.circle,
                    boxShadow: [ // हल्का शैडो जोड़ा गया
                      BoxShadow(
                        color: primaryViolet.withOpacity(0.3), // 💜 Shadow को वायलेट करें
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact(); // 👆 मध्यम वाइब्रेशन
                      // 💬 Chat Screen पर navigate करें
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalChatScreen(
                            otherUser: {
                              'id': user.id.toString(),
                              'username': user.username.toString(),
                            }, isDemoUser: widget.isDemoUser,
                          ),
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