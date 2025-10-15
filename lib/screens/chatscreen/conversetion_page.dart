// import 'package:dating_app/screens/chatscreen/chatviewmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
//
// class ConversationsPage extends StatelessWidget {
//   const ConversationsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//         final supabase = Supabase.instance.client;
//     return Scaffold(
//       appBar: AppBar(
//           title: Row(
//         children: [
//           const Text('Conversations'),
//
//
//         ]
//
//
//       )),
// body: StreamBuilder<List<Map<String, dynamic>>>(
//   stream: supabase
//       .from('conversations')
//       .stream(primaryKey: ['id']), // ✅ remove .execute() and .order()
//   builder: (context, snapshot) {
//     if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//
//     // Sort conversations by created_at descending (latest first)
//     final conversations = snapshot.data!
//       ..sort((a, b) => (b['created_at'] as String)
//           .compareTo(a['created_at'] as String));
//
//     return ListView.builder(
//       itemCount: conversations.length,
//       itemBuilder: (context, index) {
//         final conv = conversations[index];
//         return ListTile(
//           title: Text('Conversation: ${conv['id']}'),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => ChatPage(conversationId: conv['id'])),
//             );
//           },
//         );
//       },
//     );
//   },
// ),
//
//
//     );
//   }
// }
//
//
//
// class ChatPage extends StatefulWidget {
//   final String conversationId;
//   const ChatPage({super.key, required this.conversationId});
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//     final supabase = Supabase.instance.client;
//     void sendMessage() async {
//       final text = _controller.text.trim();
//       if (text.isEmpty) return;
//       await supabase.from('messages').insert({
//         'conversation_id': widget.conversationId,
//         'sender_id': supabase.auth.currentUser!.id,
//         'text': text,
//       });
//       _controller.clear();
//     }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Chat'),
//
//
//             ],
//           )),
//       body: Column(
//         children: [
//         Expanded(
//   child: StreamBuilder<List<Map<String, dynamic>>>(
//   //  stream: supabase
//    stream: supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('conversation_id', widget.conversationId),
//         // .from('messages')
//         // .stream(primaryKey: ['id'])
//         // .eq('conversation_id', widget.conversationId) // ✅ filter properly
//         // .order('created_at'),// ✅ no .order()
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//
//       // Sort messages by created_at ascending
//       final messages = snapshot.data!
//         ..sort((a, b) => (a['created_at'] as String)
//             .compareTo(b['created_at'] as String));
//
//       return ListView.builder(
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           final msg = messages[index];
//           final isMe = msg['sender_id'] == supabase.auth.currentUser!.id;
//           return ListTile(
//             title: Align(
//               alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: isMe ? Colors.blue : Colors.grey,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(msg['text'], style: const TextStyle(color: Colors.white)),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   ),
// ),
//
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(controller: _controller),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: ()async{
//                   setState(() {
//
//                   });
//                      final text = _controller.text.trim();
//                     if (text.isEmpty) return;
//
//                     // 🔹 Call provider function
//                     await context.read<ChatViewModel>().sendMessage(text);
//
//                     // 🔹 Clear input
//                     _controller.clear();
//
//                     // 🔹 Optional: force fetch messages (backup)
//                     await context.read<ChatViewModel>().fetchMessages();
//                 },
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
