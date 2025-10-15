
import 'package:dating_app/widgets/chatwidgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.messages,
    required this.isDemoUser
  });

  final List<Map<String, dynamic>> messages;
  final bool isDemoUser;

  @override
  Widget build(BuildContext context) {
    // final currentUserId = Supabase.instance.client.auth.currentUser!.id;
       final currentUserId = isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : Supabase.instance.client.auth.currentUser?.id;
print(">>>$currentUserId");
    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.only(
        bottom: 40,
        left: 13,
        right: 13,
      ),
      itemCount: messages.length,
      itemBuilder: (ctx, index) {
        final chatMessage = messages[index];
        final nextChatMessage = index + 1 < messages.length
            ? messages[index + 1]
            : null;
        final currentMessageUserId = chatMessage['user_id'];
        final nextMessageUserId =
        nextChatMessage != null ? nextChatMessage['user_id'] : null;
        final nextUserIsSame = nextMessageUserId == currentMessageUserId;
print("nextUserIsSame>>>$nextUserIsSame");
        if (nextUserIsSame) {
          return 
          MessageBubble.next(
            message: chatMessage['text'],
            isMe: currentUserId == currentMessageUserId,
          );
        } else {
          return MessageBubble.first(
            userImage: chatMessage['user_image'],
            username: chatMessage['username'],
            message: chatMessage['text'],
            isMe: currentUserId == currentMessageUserId,
          );
        }
      },
    );
  }
}
