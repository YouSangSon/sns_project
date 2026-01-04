import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/post_card.dart';

/// 게시물 상세 페이지
class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendComment() {
    if (_commentController.text.isEmpty) return;

    // TODO: Send comment

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Post
                  PostCard(
                    postId: widget.postId,
                    authorName: 'Sample User',
                    authorUsername: '@sampleuser',
                    authorAvatarUrl: null,
                    imageUrls: [],
                    content: 'Sample post content',
                    likesCount: 100,
                    commentsCount: 25,
                    isLiked: false,
                    createdAt: DateTime.now(),
                    onLike: () {},
                    onComment: () {},
                    onShare: () {},
                    onBookmark: () {},
                    onProfileTap: () {},
                    showFullContent: true,
                  ),

                  const Divider(),

                  // Comments section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '댓글',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Sample comments
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _CommentItem(
                              username: 'user_$index',
                              content: 'This is a sample comment #$index',
                              timeAgo: '${index + 1}시간 전',
                              likesCount: index * 3,
                              onLike: () {},
                              onReply: () {},
                              onProfileTap: () =>
                                  context.push('/user/user_$index'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(8),
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
                    radius: 18,
                    child: Icon(Icons.person, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '댓글 달기...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _handleSendComment,
                    child: const Text('게시'),
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
  final String username;
  final String content;
  final String timeAgo;
  final int likesCount;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onProfileTap;

  const _CommentItem({
    required this.username,
    required this.content,
    required this.timeAgo,
    required this.likesCount,
    required this.onLike,
    required this.onReply,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(content),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Text(
                      '좋아요 $likesCount개',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onReply,
                    child: Text(
                      '답글 달기',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onLike,
          icon: const Icon(Icons.favorite_border, size: 16),
        ),
      ],
    );
  }
}
