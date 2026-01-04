import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';

/// 게시물 카드 위젯
class PostCard extends StatelessWidget {
  final String postId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final List<String> imageUrls;
  final String? content;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime? createdAt;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onProfileTap;
  final bool showFullContent;

  const PostCard({
    super.key,
    required this.postId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatarUrl,
    required this.imageUrls,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
    required this.onProfileTap,
    this.showFullContent = false,
  });

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
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: authorAvatarUrl != null
                      ? CachedNetworkImageProvider(authorAvatarUrl!)
                      : null,
                  child:
                      authorAvatarUrl == null ? const Icon(Icons.person, size: 18) : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: Text(
                    authorUsername,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showOptionsSheet(context),
              ),
            ],
          ),
        ),

        // Images
        if (imageUrls.isNotEmpty)
          AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.backgroundGray,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundGray,
                    child: const Icon(Icons.error),
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 300,
            color: AppColors.backgroundGray,
            child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.like : null,
                ),
                onPressed: onLike,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: onComment,
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: onShare,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: onBookmark,
              ),
            ],
          ),
        ),

        // Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '좋아요 ${likesCount.abbreviated}개',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Content
        if (content != null && content!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              maxLines: showFullContent ? null : 2,
              overflow: showFullContent ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$authorUsername ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),

        // Comments count
        if (commentsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: onComment,
              child: Text(
                '댓글 ${commentsCount.abbreviated}개 모두 보기',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),

        // Time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            createdAt?.timeAgo ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('공유'),
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('링크 복사'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('신고'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text('이 게시물 숨기기'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
