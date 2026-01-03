import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../features/feed/presentation/providers/feed_provider.dart';
import '../../../../features/feed/presentation/widgets/post_card.dart';

// Mock comments
final mockComments = [
  Comment(
    commentId: 'c1',
    postId: 'post-001',
    userId: 'user-005',
    username: 'commenter1',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=c1',
    text: '정말 멋진 사진이네요! 👍',
    likes: 12,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Comment(
    commentId: 'c2',
    postId: 'post-001',
    userId: 'user-006',
    username: 'commenter2',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=c2',
    text: '어디서 찍으셨어요?',
    likes: 5,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Comment(
    commentId: 'c3',
    postId: 'post-001',
    userId: 'user-007',
    username: 'commenter3',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=c3',
    text: '저도 가보고 싶어요 ㅠㅠ',
    likes: 3,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _comments = mockComments;
      _isLoading = false;
    });
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      commentId: 'c${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.postId,
      userId: 'current-user',
      username: 'devuser',
      userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments = [newComment, ..._comments];
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedStateProvider);
    final post = feedState.posts.firstWhere(
      (p) => p.postId == widget.postId,
      orElse: () => feedState.posts.first,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  PostCard(
                    post: post,
                    onLike: () {
                      ref.read(feedStateProvider.notifier).likePost(post.postId);
                    },
                    onComment: () {},
                    onShare: () {},
                    onBookmark: () {
                      ref.read(feedStateProvider.notifier).bookmarkPost(post.postId);
                    },
                    onUserTap: () => context.push('/user/${post.userId}'),
                  ),
                  const Divider(height: 1),
                  // Comments Section
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: LoadingIndicator(size: 24),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _CommentItem(comment: _comments[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(
                    imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitComment,
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            imageUrl: comment.userPhotoUrl,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${comment.username} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (comment.likes > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${comment.likes} likes',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.isLiked ? AppColors.like : AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
