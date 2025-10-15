// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'SignInpage.dart'; // Login page import karo
//
// class LogoutPage extends StatelessWidget {
//   const LogoutPage({super.key});
//
//   Future<void> _logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();
//
//     // Logout ke baad login page pe bhej do
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (ctx) => const SignInPage()),
//           (route) => false, // purane pages hata de
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Logout"),
//       ),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.exit_to_app),
//           label: const Text("Logout"),
//           onPressed: () => _logout(context),
//         ),
//       ),
//     );
//   }
// }
