import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityForumPage extends StatefulWidget {
  const CommunityForumPage({super.key});

  @override
  State<CommunityForumPage> createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace with actual FirebaseAuth logic. Using a default name for seamless UI testing.
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'local_user_01';
  String get currentUserName => FirebaseAuth.instance.currentUser?.displayName ?? 'Mjeed';

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostSheet(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS system background grey
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        title: const Text(
          "Community Forum",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: CupertinoColors.systemGreen),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: _showCreatePostSheet,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('forum_posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No posts yet. Be the first to start a discussion!",
                  style: TextStyle(color: CupertinoColors.systemGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = snapshot.data!.docs[index];
              return ForumPostCard(
                postDoc: post,
                currentUserId: currentUserId,
                currentUserName: currentUserName,
              );
            },
          );
        },
      ),
    );
  }
}

// --- POST CARD WIDGET ---
class ForumPostCard extends StatelessWidget {
  final DocumentSnapshot postDoc;
  final String currentUserId;
  final String currentUserName;

  const ForumPostCard({
    super.key,
    required this.postDoc,
    required this.currentUserId,
    required this.currentUserName,
  });

  Future<void> _toggleReaction(String type) async {
    final List likes = postDoc['likes'] ?? [];
    final List dislikes = postDoc['dislikes'] ?? [];

    if (type == 'like') {
      if (likes.contains(currentUserId)) {
        await postDoc.reference.update({'likes': FieldValue.arrayRemove([currentUserId])});
      } else {
        await postDoc.reference.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
          'dislikes': FieldValue.arrayRemove([currentUserId]),
        });
      }
    } else {
      if (dislikes.contains(currentUserId)) {
        await postDoc.reference.update({'dislikes': FieldValue.arrayRemove([currentUserId])});
      } else {
        await postDoc.reference.update({
          'dislikes': FieldValue.arrayUnion([currentUserId]),
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      }
    }
  }

  void _deletePost(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post? This cannot be undone."),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () {
              postDoc.reference.delete();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Share Post"),
        message: const Text("Send this post in a private conversation"),
        actions: [
          CupertinoActionSheetAction(
            child: const Text("Send to Connections"),
            onPressed: () => Navigator.pop(context), // Placeholder for routing to chats
          ),
          CupertinoActionSheetAction(
            child: const Text("Copy Link"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        postRef: postDoc.reference,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = postDoc.data() as Map<String, dynamic>;
    final bool isOwner = data['authorId'] == currentUserId;
    final List likes = data['likes'] ?? [];
    final List dislikes = data['dislikes'] ?? [];
    final String? imageUrl = data['imageUrl'];
    final Timestamp? timestamp = data['timestamp'];
    final String timeString = timestamp != null
        ? _formatTimestamp(timestamp.toDate())
        : 'Just now';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: CupertinoColors.systemGreen.withOpacity(0.2),
                  child: Text(data['authorName'][0].toUpperCase(), style: const TextStyle(color: CupertinoColors.systemGreen, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['authorName'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(timeString, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
                    onPressed: () => _deletePost(context),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(data['content'], style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
          const SizedBox(height: 12),

          // Optional Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
            ),

          const Divider(height: 30, color: Color(0xFFE5E5EA)),

          // Interaction Bar
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      icon: likes.contains(currentUserId) ? CupertinoIcons.hand_thumbsup_fill : CupertinoIcons.hand_thumbsup,
                      color: likes.contains(currentUserId) ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                      count: likes.length.toString(),
                      onTap: () => _toggleReaction('like'),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: dislikes.contains(currentUserId) ? CupertinoIcons.hand_thumbsdown_fill : CupertinoIcons.hand_thumbsdown,
                      color: dislikes.contains(currentUserId) ? CupertinoColors.destructiveRed : CupertinoColors.systemGrey,
                      count: dislikes.length.toString(),
                      onTap: () => _toggleReaction('dislike'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: CupertinoIcons.chat_bubble,
                      color: CupertinoColors.systemGrey,
                      count: "Reply",
                      onTap: () => _openComments(context),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: CupertinoIcons.paperplane,
                      color: CupertinoColors.systemGrey,
                      count: "Share",
                      onTap: () => _showShareDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required String count, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(count, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// --- CREATE POST SHEET ---
class CreatePostSheet extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const CreatePostSheet({super.key, required this.currentUserId, required this.currentUserName});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImage == null) return;
    setState(() => _isLoading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      final ref = FirebaseStorage.instance.ref().child('forum_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('forum_posts').add({
      'authorId': widget.currentUserId,
      'authorName': widget.currentUserName,
      'content': _contentController.text.trim(),
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'dislikes': [],
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.xmark, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("New Discussion", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              _isLoading
                  ? const Padding(padding: EdgeInsets.all(16), child: CupertinoActivityIndicator())
                  : CupertinoButton(
                onPressed: _submitPost,
                child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: CupertinoColors.systemGrey2),
                  ),
                ),
                if (_selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.clear_thick_circled, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                        onPressed: () => setState(() => _selectedImage = null),
                      )
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 12, left: 16, right: 16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E5EA)))),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGreen, size: 28),
                  onPressed: _pickImage,
                ),
                const Text("Add Photo", style: TextStyle(color: CupertinoColors.systemGrey, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- COMMENTS SHEET ---
class CommentsSheet extends StatefulWidget {
  final DocumentReference postRef;
  final String currentUserId;
  final String currentUserName;

  const CommentsSheet({super.key, required this.postRef, required this.currentUserId, required this.currentUserName});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    await widget.postRef.collection('comments').add({
      'authorId': widget.currentUserId,
      'authorName': widget.currentUserName,
      'content': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 5, width: 40,
            decoration: BoxDecoration(color: CupertinoColors.systemGrey4, borderRadius: BorderRadius.circular(10)),
          ),
          const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.postRef.collection('comments').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No comments yet.", style: TextStyle(color: CupertinoColors.systemGrey)));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: CupertinoColors.systemGrey5,
                            child: Text(comment['authorName'][0], style: const TextStyle(color: Colors.black, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment['authorName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(comment['content'], style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _commentController,
                      placeholder: "Write a reply...",
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _sendComment,
                    child: const Icon(CupertinoIcons.arrow_up_circle_fill, size: 36, color: CupertinoColors.activeBlue),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}