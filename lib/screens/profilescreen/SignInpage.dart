import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: const Center(
        child: Text("This is the Sign In Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
