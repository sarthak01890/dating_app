// // File: users.dart
// import 'package:dating_app/screens/chatscreen/personalchat.dart'; // नया Import
// import 'package:flutter/material.dart';
// import 'package:dating_app/main.dart';
//
// class UsersScreen extends StatelessWidget {
//   const UsersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Users'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               supabase.auth.signOut();
//             },
//             icon: const Icon(Icons.exit_to_app),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         future: supabase.from('users').select(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData) {
//             return const Center(child: Text('No users found.'));
//           }
//
//           final users = snapshot.data as List<dynamic>;
//           final currentUserId = supabase.auth.currentUser!.id;
//
//           final otherUsers = users.where((user) => user['id'] != currentUserId).toList();
//
//           if (otherUsers.isEmpty) {
//             return const Center(child: Text('No other users found.'));
//           }
//
//           return ListView.builder(
//             itemCount: otherUsers.length,
//             itemBuilder: (context, index) {
//               final user = otherUsers[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage(user['image_url']),
//                 ),
//                 title: Text(user['username']),
//                 onTap: () {
//                   // ✅ Fix: PersonalChatScreen पर नेविगेट करें
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => PersonalChatScreen(otherUser: user),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }