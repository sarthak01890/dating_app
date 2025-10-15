import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color primaryMediumPurple = Color(0xFF9370DB);

class Comment {
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({required this.userId, required this.text, required this.timestamp});

  factory Comment.fromSupabase(Map<String, dynamic> json, String username) {
    return Comment(
      userId: username,
      text: json['comment_text'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CommentSheet extends StatefulWidget {
  final String reelId;
  final String currentUsername;

  const CommentSheet({
    super.key,
    required this.reelId,
    required this.currentUsername,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final supabase = Supabase.instance.client;
  String? _currentUserId;

  List<Comment> _comments = [];
  bool _isFetching = true;
  Map<String, String> _userIdToUsername = {};

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    if (!mounted) return;
    setState(() => _isFetching = true);

    try {
      final List<dynamic> commentData = await supabase
          .from('comments')
          .select('id, created_at, user_id, comment_text')
          .eq('reel_id', widget.reelId)
          .order('created_at', ascending: false);

      final Set<String> userIds = commentData.map((c) => c['user_id'] as String).toSet();

      final List<dynamic> profileData = await supabase
          .from('users') // ✅ same as ProfilePage
          .select('id, username')
          .filter('id', 'in', userIds.toList());

      _userIdToUsername = Map.fromIterable(
        profileData,
        key: (p) => p['id'] as String,
        value: (p) =>
        (p['username'] as String?)?.isNotEmpty == true ? p['username'] : 'User',
      );

      final fetchedComments = commentData.map((json) {
        final userId = json['user_id'] as String;
        final username = _userIdToUsername[userId] ?? "User";
        return Comment.fromSupabase(json, username);
      }).toList();

      if (mounted) {
        setState(() {
          _comments = fetchedComments;
          _isFetching = false;
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    final displayName = widget.currentUsername.isNotEmpty
        ? widget.currentUsername
        : (supabase.auth.currentUser?.email ?? "User");

    final newComment = Comment(
      userId: displayName,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
    });
    _commentController.clear();

    try {
      await supabase.from('comments').insert({
        'user_id': _currentUserId,
        'reel_id': widget.reelId,
        'comment_text': text,
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _comments.removeAt(0);
        });
      }
      print('Failed to post comment: $e');
    }
  }

  String _formatTime(DateTime timestamp) {
    final duration = DateTime.now().difference(timestamp);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Comments (${_comments.length})',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Expanded(
              child: _isFetching
                  ? const Center(
                  child: CircularProgressIndicator(color: primaryMediumPurple))
                  : ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryMediumPurple,
                      child: Text(comment.userId[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(
                      comment.userId,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      comment.text,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      _formatTime(comment.timestamp),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Comment as ${widget.currentUsername}...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: primaryMediumPurple),
                    onPressed: _postComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
