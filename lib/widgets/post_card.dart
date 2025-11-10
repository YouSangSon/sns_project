import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user != null) {
      final isLiked = await postProvider.isPostLiked(
        widget.post.postId,
        authProvider.user!.uid,
      );

      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user == null) return;

    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      await postProvider.likePost(widget.post.postId, authProvider.user!.uid);
    } else {
      await postProvider.unlikePost(widget.post.postId, authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/profile/${widget.post.userId}');
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.post.userPhotoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(widget.post.userPhotoUrl)
                      : null,
                  child: widget.post.userPhotoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/profile/${widget.post.userId}');
                      },
                      child: Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (widget.post.location.isNotEmpty)
                      Text(
                        widget.post.location,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showPostOptions(context);
                },
              ),
            ],
          ),
        ),

        // Image(s)
        if (widget.post.imageUrls.isNotEmpty)
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PageView.builder(
                  itemCount: widget.post.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.post.imageUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    );
                  },
                ),
              ),
              if (widget.post.imageUrls.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                ),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  context.push('/post/${widget.post.postId}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {
                  // Share functionality
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  // Save functionality
                },
              ),
            ],
          ),
        ),

        // Likes count
        if (widget.post.likes > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.post.likes} ${widget.post.likes == 1 ? 'like' : 'likes'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

        // Caption
        if (widget.post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${widget.post.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),

        // View comments
        if (widget.post.comments > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: () {
                context.push('/post/${widget.post.postId}');
              },
              child: Text(
                'View all ${widget.post.comments} comments',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),

        // Time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            timeago.format(widget.post.createdAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),

        const Divider(height: 16),
      ],
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final authProvider = context.read<AuthProvider>();
        final isOwnPost = authProvider.user?.uid == widget.post.userId;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwnPost)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy link'),
                onTap: () {
                  Navigator.pop(context);
                  // Copy link functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Share functionality
                },
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final postProvider = context.read<PostProvider>();
      await postProvider.deletePost(widget.post.postId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    }
  }
}
