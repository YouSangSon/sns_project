import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/post_model.dart';
import '../../../../shared/widgets/cached_image.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onUserTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onUserTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: widget.onUserTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  imageUrl: widget.post.userPhotoUrl,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (widget.post.location != null)
                        Text(
                          widget.post.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showOptionsSheet(context),
                ),
              ],
            ),
          ),
        ),

        // Images
        SizedBox(
          width: screenWidth,
          height: screenWidth,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.post.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return CachedImage(
                    imageUrl: widget.post.imageUrls[index],
                    width: screenWidth,
                    height: screenWidth,
                    fit: BoxFit.cover,
                  );
                },
              ),
              // Image Indicator
              if (widget.post.imageUrls.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.post.imageUrls.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentImageIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? AppColors.like : null,
                ),
                iconSize: 28,
                onPressed: widget.onLike,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                iconSize: 26,
                onPressed: widget.onComment,
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                iconSize: 26,
                onPressed: widget.onShare,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  widget.post.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                iconSize: 26,
                onPressed: widget.onBookmark,
              ),
            ],
          ),
        ),

        // Likes Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${_formatNumber(widget.post.likes)} likes',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Caption
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${widget.post.username} ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),

        // Comments
        if (widget.post.comments > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: widget.onComment,
              child: Text(
                'View all ${widget.post.comments} comments',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),

        // Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            timeago.format(widget.post.createdAt),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                widget.onShare?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
