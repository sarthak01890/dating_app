// File: new_message.dart
import 'dart:developer';

import 'package:dating_app/screens/chatscreen/chatviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewMessage extends StatefulWidget {
  final String? otherUserId; 
  final bool isDemoUser;// recipient user ID

  const NewMessage({super.key, this.otherUserId,required this.isDemoUser});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  final supabase = Supabase.instance.client;
  var _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

//   Future<void> _submitMessage() async {
//     final enteredMessage = _messageController.text.trim();

//     if (enteredMessage.isEmpty) return;

    // FocusScope.of(context).unfocus();
    // _messageController.clear();

//     setState(() {
//       _isSending = true;
//     });

//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text("You must be logged in to send a message.")),
//         );
//         return;
//       }

  //     // fetch sender details
  //     final userData = await supabase
  //         .from('users')
  //         .select('username, image_url')
  //         .eq('id', user.id)
  //         .single();

  //  final messageData = {
  // 'text': enteredMessage,
  // 'user_id': user.id,
  // 'username': userData['username'],
  // 'user_image': userData['image_url'],
  // 'created_at': DateTime.now(),
  // 'recipient_id': widget.otherUserId,
// };


//       await supabase.from('messages').insert(messageData);
//       print("data-=-=");
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: $error')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSending = false;
//         });
//       }
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration:
                  const InputDecoration(labelText: "Send a message..."),
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              onPressed: (){
                  
                  // Send message via ChatViewModel
     context.read<ChatViewModel>().sendMessage(_messageController.text,widget.isDemoUser);
         FocusScope.of(context).unfocus();
    _messageController.clear();
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
