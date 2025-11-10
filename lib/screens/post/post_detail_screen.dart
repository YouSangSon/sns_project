import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostAndComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostAndComments() async {
    final postProvider = context.read<PostProvider>();
    await postProvider.loadPost(widget.postId);
    await postProvider.loadComments(widget.postId);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user != null && authProvider.userModel != null) {
      await postProvider.addComment(
        postId: widget.postId,
        userId: authProvider.user!.uid,
        username: authProvider.userModel!.username,
        userPhotoUrl: authProvider.userModel!.photoUrl,
        text: _commentController.text.trim(),
      );

      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = postProvider.currentPost;
          if (post == null) {
            return const Center(child: Text('Post not found'));
          }

          return Column(
            children: [
              // Post preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userPhotoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(post.userPhotoUrl)
                          : null,
                      child: post.userPhotoUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(post.caption),
                          const SizedBox(height: 4),
                          Text(
                            timeago.format(post.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (post.imageUrls.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrls.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),

              // Comments list
              Expanded(
                child: postProvider.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: postProvider.comments.length,
                        itemBuilder: (context, index) {
                          return _CommentTile(
                            comment: postProvider.comments[index],
                          );
                        },
                      ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                authProvider.userModel?.photoUrl.isNotEmpty ==
                                        true
                                    ? CachedNetworkImageProvider(
                                        authProvider.userModel!.photoUrl)
                                    : null,
                            child:
                                authProvider.userModel?.photoUrl.isEmpty ?? true
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      TextButton(
                        onPressed: _addComment,
                        child: const Text(
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.userPhotoUrl.isNotEmpty
                ? CachedNetworkImageProvider(comment.userPhotoUrl)
                : null,
            child: comment.userPhotoUrl.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${comment.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (comment.likes > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${comment.likes} ${comment.likes == 1 ? 'like' : 'likes'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              comment.likes > 0 ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.likes > 0 ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              // Like comment functionality
            },
          ),
        ],
      ),
    );
  }
}
