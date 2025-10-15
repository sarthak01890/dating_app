import 'package:flutter/material.dart';
import '../../models/user_model.dart';

// --- Global Color Definitions ---
const Color primaryViolet = Color(0xFF8A2BE2); // Primary Violet
const Color accentPurple = Color(0xFF9370DB); // Accent Purple

class UserProfileDetailPage extends StatelessWidget {
  final UserModel user;

  const UserProfileDetailPage({Key? key, required this.user}) : super(key: key);

  // --- Utility Widget: Profile Detail Section ---
  Widget _buildSection(String title, String? content) {
    // Agar content null ya empty hai to kuch nahi dikhana
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryViolet, // Title ko primaryViolet color diya
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const Divider(height: 20, color: Color(0x10000000)), // Subtle divider
        ],
      ),
    );
  }

  // --- Utility Widget: Info Row (e.g., Age, Location) ---
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryViolet.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryViolet),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: primaryViolet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {

    // User data ko null check ke saath use karein
    final String displayName = user.fullName ?? user.username;
    final String displayLocation =
    (user.city != null && user.country != null)
        ? "${user.city}, ${user.country}"
        : user.city ?? user.country ?? 'Unknown Location';

    return Scaffold(
      backgroundColor: Colors.white,

      // 🌟 Modern UI: CustomScrollView with SliverAppBar
      body: CustomScrollView(
        slivers: <Widget>[
          // 🖼️ Collapsing Header (Profile Picture)
          SliverAppBar(
            expandedHeight: 400.0, // Profile photo ki height
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            // Header jab collapse hota hai, tab naam dikhta hai
            title: Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 20, right: 20),
                child: Text(
                  displayName,
                  // Title style tab dikhega jab expanded ho
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              background: user.imageUrl != null && user.imageUrl!.isNotEmpty
                  ? Image.network(
                user.imageUrl!,
                fit: BoxFit.cover,
                // Gradient Overlay for readability of title/back button
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
              )
                  : Container(color: primaryViolet.withOpacity(0.8)), // Fallback color
            ),
          ),

          // 📝 Details Body
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Primary Info Row (Age, Location) ---
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: [
                          if (user.age != null)
                            _buildInfoChip(Icons.cake, "${user.age} Yrs"),

                          _buildInfoChip(Icons.location_on, displayLocation),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- About Section ---
                      _buildSection("About Me", user.bio),

                      // --- Language Section ---
                      _buildSection("Language Spoken", user.language),

                      // --- Contact (Optional/Private) ---
                      // Agar aap phone number dikhana chahte hain to:
                      // _buildSection("Contact Number", user.number),

                      // Spacer at the bottom
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}