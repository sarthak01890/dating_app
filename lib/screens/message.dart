import 'package:dating_app/screens/chatscreen/PersonalChat.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MessageScreen extends StatefulWidget {
  final String? otherUserid;
  final bool isDemoUser;
  const MessageScreen({super.key,required this.otherUserid,required this.isDemoUser});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final supabase = Supabase.instance.client;
      // final currentUserId = supabase.auth.currentUser!.id;
         final currentUserId = widget.isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    // Handle the case when there is no logged-in user
    return ;
  }

      final data = await supabase
          .from('users')
          .select()
          .neq('id', currentUserId);

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['image_url']),
            ),
            title: Text(user['username']),
            subtitle: Text(user['email']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalChatScreen(
                    otherUser: user,
                    isDemoUser:widget.isDemoUser
                    
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
