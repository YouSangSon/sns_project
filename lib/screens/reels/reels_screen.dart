import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/reel_model.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  List<ReelModel> _reels = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    _databaseService.getReelsFeed(limit: 50).listen((reels) {
      if (mounted) {
        setState(() {
          _reels = reels;
        });
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Track view when user views a reel
    if (index < _reels.length) {
      _databaseService.incrementReelViews(_reels[index].reelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _reels.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: _reels.length,
              itemBuilder: (context, index) {
                return ReelPlayerWidget(
                  reel: _reels[index],
                  isActive: index == _currentIndex,
                );
              },
            ),
    );
  }
}

class ReelPlayerWidget extends ConsumerStatefulWidget {
  final ReelModel reel;
  final bool isActive;

  const ReelPlayerWidget({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  ConsumerState<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends ConsumerState<ReelPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _likes = widget.reel.likes;
    _checkIfLiked();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(ReelPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _videoPlayerController?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _videoPlayerController?.pause();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _checkIfLiked() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser != null) {
      final liked = await _databaseService.hasLikedReel(widget.reel.reelId, currentUser.uid);
      if (mounted) {
        setState(() {
          _isLiked = liked;
        });
      }
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.isActive,
      looping: true,
      showControls: false,
      aspectRatio: 9 / 16,
      autoInitialize: true,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await _databaseService.likeReel(widget.reel.reelId, currentUser.uid);
      } else {
        await _databaseService.unlikeReel(widget.reel.reelId, currentUser.uid);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        _likes += _isLiked ? 1 : -1;
      });
    }
  }

  void _shareReel() {
    Share.share(
      'Check out this reel by ${widget.reel.username}!\n\n${widget.reel.caption}',
      subject: 'Amazing Reel',
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

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        Center(
          child: Chewie(controller: _chewieController!),
        ),

        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        // User Info and Caption
        Positioned(
          bottom: 80,
          left: 16,
          right: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.reel.userPhotoUrl.isNotEmpty
                        ? NetworkImage(widget.reel.userPhotoUrl)
                        : null,
                    child: widget.reel.userPhotoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.reel.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Follow user logic
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                    ),
                    child: const Text('Follow'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Caption
              Text(
                widget.reel.caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Audio Info
              if (widget.reel.audioName != null)
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.reel.audioName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Action Buttons (Right Side)
        Positioned(
          bottom: 80,
          right: 16,
          child: Column(
            children: [
              // Like Button
              _ActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(_likes),
                color: _isLiked ? Colors.red : Colors.white,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 24),

              // Comment Button
              _ActionButton(
                icon: Icons.comment,
                label: _formatCount(widget.reel.comments),
                onTap: () {
                  // Show comments bottom sheet
                },
              ),
              const SizedBox(height: 24),

              // Share Button
              _ActionButton(
                icon: Icons.share,
                label: _formatCount(widget.reel.shares),
                onTap: _shareReel,
              ),
              const SizedBox(height: 24),

              // More Button
              _ActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () {
                  _showMoreOptions(context);
                },
              ),
            ],
          ),
        ),

        // Stats Overlay (Top)
        Positioned(
          top: 100,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatCount(widget.reel.views),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Report logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Not interested'),
              onTap: () {
                Navigator.pop(context);
                // Not interested logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save'),
              onTap: () {
                Navigator.pop(context);
                // Save logic
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
