import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // photo
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              user.imageUrl.toString(),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),

          // flag + lang + level
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                const Icon(Icons.flag, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(user.country.toString(), style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(user.language.toString(), style: const TextStyle(fontSize: 12)),
                const Spacer(),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                //   decoration: BoxDecoration(
                //     color: Colors.purple[100],
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Text("Lv${user.level}",
                //       style: const TextStyle(fontSize: 10, color: Colors.purple)),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 2),

          // tagline
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 6),
          //   child: Text(user.tagline,
          //       style: const TextStyle(fontSize: 12, color: Colors.grey)),
          // ),
        ],
      ),
    );
  }
}
