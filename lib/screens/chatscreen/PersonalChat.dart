// File: personal_chat.dart
import 'dart:developer';

import 'package:dating_app/screens/chatscreen/chat_messages.dart';
import 'package:dating_app/screens/chatscreen/vediocall/index.dart';
import 'package:dating_app/widgets/chatwidgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/chatscreen/chatviewmodel.dart';
import 'package:provider/provider.dart';

class PersonalChatScreen extends StatelessWidget {
  const PersonalChatScreen({super.key, required this.otherUser,required this.isDemoUser});

  // otherUser mein kam se kam 'id' (UUID string) aur 'username' hona zaroori hai
  final Map<String, dynamic> otherUser;
  final bool isDemoUser;

  @override
  Widget build(BuildContext context) {
    // Other user ki ID ko ensure karein ki woh String hi ho (agar UUID hai)
    final String otherUserId = otherUser['id'] as String;
    final String otherUsername = otherUser['username'] as String;

    return ChangeNotifierProvider(
      // 🔑 ViewModel ko otherUserId pass karein
      create: (context) => ChatViewModel(otherUserId: otherUserId, isDemoUser: isDemoUser),
      child: Scaffold(
        appBar: AppBar(
          // 💅 AppBar UI Sudhaar: Title aur Actions ko sahi jagah par rakha gaya
          title: Text(otherUsername),
          centerTitle: false, // Title ko left align rakha
          actions: [
            // 📞 Video Call Button
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>  IndexPage()
                ),
                );
              },
              icon: const Icon(Icons.videocam, color: Colors.purple),
            ),
            const SizedBox(width: 8),
            // ℹ️ Optional: Profile/More Options
            IconButton(
              onPressed: () {
                // TODO: User profile ya more options ke liye logic
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, chatViewModel, child) {

                  // ⏳ Loading State
                  if (chatViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.purple));
                  }

                  // 🚨 Error State
                  if (chatViewModel.error != null) {
                    log('Chat Error: ${chatViewModel.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Could not load messages. Please check your network or database policies: ${chatViewModel.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    );
                  }

                  // 💬 Success State: Messages display karein
                  // StreamBuilder hone ki wajah se, messages khud-b-khud update honge
                  return ChatMessages(messages: chatViewModel.messages, isDemoUser: isDemoUser);
                },
              ),
            ),

            // 📩 New Message Input Field
            // Isme bhi otherUserId pass karein
            NewMessage(otherUserId: otherUserId,isDemoUser: isDemoUser),

            // 📱 iOS Bottom Space ke liye SafeArea
            const SafeArea(
              top: false,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}