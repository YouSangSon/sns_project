import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock reels
final mockReels = [
  Reel(
    reelId: 'reel-001',
    userId: 'user-001',
    username: 'creator_one',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=creator1',
    videoUrl: 'https://example.com/video1.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel1/400/700',
    caption: '오늘의 일상 브이로그 #daily #vlog',
    audioName: 'Original Audio',
    likes: 1234,
    comments: 56,
    shares: 12,
    views: 5678,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Reel(
    reelId: 'reel-002',
    userId: 'user-002',
    username: 'creator_two',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=creator2',
    videoUrl: 'https://example.com/video2.mp4',
    thumbnailUrl: 'https://picsum.photos/seed/reel2/400/700',
    caption: '여행 하이라이트 ✈️ #travel',
    audioName: 'Trending Sound',
    likes: 9876,
    comments: 234,
    shares: 45,
    views: 45678,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: mockReels.length,
        itemBuilder: (context, index) {
          return _ReelItem(reel: mockReels[index]);
        },
      ),
    );
  }
}

class _ReelItem extends StatefulWidget {
  final Reel reel;

  const _ReelItem({required this.reel});

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> {
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video/Thumbnail
        GestureDetector(
          onDoubleTap: () {
            setState(() => _isLiked = true);
          },
          child: CachedImage(
            imageUrl: widget.reel.thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ),

        // Play Button (for thumbnail mode)
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _ActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(widget.reel.likes),
                color: _isLiked ? AppColors.like : Colors.white,
                onTap: () => setState(() => _isLiked = !_isLiked),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatCount(widget.reel.comments),
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.send_outlined,
                label: _formatCount(widget.reel.shares),
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                onTap: () => setState(() => _isBookmarked = !_isBookmarked),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () {},
              ),
            ],
          ),
        ),

        // Bottom Info
        Positioned(
          left: 12,
          right: 60,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    imageUrl: widget.reel.userPhotoUrl,
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.reel.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.reel.caption != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.reel.caption!,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (widget.reel.audioName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.reel.audioName!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
