import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatViewModel with ChangeNotifier {
  final String otherUserId;
  final bool isDemoUser;
  final supabase = Supabase.instance.client;

  // State
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  // Getters
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatViewModel({required this.otherUserId,required this.isDemoUser}) {
    fetchMessages();
    subscribeToMessages();
  }

  // Fetch existing messages between current user and other user
Future<void> fetchMessages() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final currentUserId = isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      :supabase.auth.currentUser!.id;
log("currentUserId$currentUserId");
    // Fetch all messages where currentUser is either sender (user_id) or recipient
    final data = await supabase
        .from('messages')
        .select()
        .or('user_id.eq.$currentUserId,recipient_id.eq.$currentUserId')
        .order('created_at', ascending: true);

    // Filter for messages between currentUser and otherUser
    final filtered = (data as List<dynamic>).where((msg) {
      final sender = msg['user_id'] as String?;
      final recipient = msg['recipient_id'] as String?;
      if (sender == null || recipient == null) return false;
      return (sender == currentUserId && recipient == otherUserId) ||
             (sender == otherUserId && recipient == currentUserId);
    }).toList();

    _messages = List<Map<String, dynamic>>.from(filtered);
    log("c $_messages");
  } catch (e) {
    _error = e.toString();
    log("Error fetching messages: $_error");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // Real-time subscription
 void subscribeToMessages() {
  _messagesSubscription?.cancel();


  final messageStream = supabase
      .from('messages')
      .stream(primaryKey: ['id']); // No filters here

  _messagesSubscription = messageStream.listen(
  (data) {
    final currentUserId = isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      :supabase.auth.currentUser!.id;
    final newMessages = data.where((msg) {
      final sender = msg['user_id'] as String?;
      final recipient = msg['recipient_id'] as String?;
      if (sender == null || recipient == null) return false;
      return (sender == currentUserId && recipient == otherUserId) ||
             (sender == otherUserId && recipient == currentUserId);
    }).toList();

    // Merge with existing messages without duplicates
    final existingIds = _messages.map((m) => m['id']).toSet();
    for (var msg in newMessages) {
      if (!existingIds.contains(msg['id'])) {
        _messages.add(msg);
      }
    }

    // Sort by created_at
    _messages.sort((a, b) =>
        (a['created_at'] as String).compareTo(b['created_at'] as String));

    notifyListeners();
  },
);

}


  // Send message
Future<void> sendMessage(String text,bool isDemoUser) async {
  if (text.trim().isEmpty) return;
 final currentUserId = isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : supabase.auth.currentUser?.id;
  // final user = supabase.auth.currentUser;
  // if (user == null) return;

  // final currentUserId = user.id;


  // Optimistic UI update
  final optimisticMessage = {
    'text': text,
    'sender_id': currentUserId,
    'recipient_id': otherUserId,
    'created_at': DateTime.now().toIso8601String(),
  };
  _messages = [..._messages];
  notifyListeners();

  try {
    // Fetch sender details safely
    final userData = await supabase
        .from('users')
        .select('username, image_url')
        .eq('id', currentUserId.toString())
        .maybeSingle();

    if (userData == null) {
      log('⚠️ No user found for id: $currentUserId');
      return;
    }

    final messageData = {
      'text': text,
      'recipient_id': otherUserId,
      'username': userData['username'],
      'user_image': userData['image_url'],
      'created_at': DateTime.now().toIso8601String(),
      'user_id': currentUserId,
    };

    await supabase.from('messages').insert(messageData);
  } catch (error) {
    _error = 'Failed to send message: ${error.toString()}';
    _messages = _messages.where((msg) => msg != optimisticMessage).toList();
    notifyListeners();
  }
}


  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
