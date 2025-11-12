import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/bookmark_model.dart';
import '../../services/bookmark_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen>
    with SingleTickerProviderStateMixin {
  final BookmarkService _bookmarkService = BookmarkService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('저장됨')),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('저장됨'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '모든 게시물'),
            Tab(text: '일반 게시물'),
            Tab(text: '투자 아이디어'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllBookmarks(currentUser.uid),
          _buildBookmarksByType(currentUser.uid, BookmarkType.post),
          _buildBookmarksByType(currentUser.uid, BookmarkType.investmentPost),
        ],
      ),
    );
  }

  Widget _buildAllBookmarks(String userId) {
    return StreamBuilder<List<BookmarkModel>>(
      stream: _bookmarkService.getUserBookmarks(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return _buildBookmarkCard(bookmark);
          },
        );
      },
    );
  }

  Widget _buildBookmarksByType(String userId, BookmarkType type) {
    return StreamBuilder<List<BookmarkModel>>(
      stream: _bookmarkService.getUserBookmarks(userId, type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return _buildBookmarkCard(bookmark);
          },
        );
      },
    );
  }

  Widget _buildBookmarkCard(BookmarkModel bookmark) {
    return GestureDetector(
      onTap: () {
        _navigateToContent(bookmark);
      },
      onLongPress: () {
        _showBookmarkOptions(bookmark);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Content image
          if (bookmark.contentImageUrl != null && bookmark.contentImageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: bookmark.contentImageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            )
          else
            Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  _getTypeIcon(bookmark.type),
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
            ),

          // Type badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(bookmark.type),
                    size: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Author info
          if (bookmark.authorUsername != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  bookmark.authorUsername!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(BookmarkType type) {
    switch (type) {
      case BookmarkType.post:
        return Icons.image;
      case BookmarkType.investmentPost:
        return Icons.trending_up;
      case BookmarkType.reel:
        return Icons.play_circle;
    }
  }

  void _navigateToContent(BookmarkModel bookmark) {
    switch (bookmark.type) {
      case BookmarkType.post:
        context.push('/post/${bookmark.contentId}');
        break;
      case BookmarkType.investmentPost:
        context.push('/investment/post/${bookmark.contentId}');
        break;
      case BookmarkType.reel:
        // Navigate to reel
        break;
    }
  }

  void _showBookmarkOptions(BookmarkModel bookmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('열기'),
              onTap: () {
                Navigator.pop(context);
                _navigateToContent(bookmark);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_remove, color: Colors.red),
              title: const Text('저장 취소', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _removeBookmark(bookmark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeBookmark(BookmarkModel bookmark) async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      await _bookmarkService.removeBookmark(
        currentUser.uid,
        bookmark.contentId,
        bookmark.type,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장이 취소되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '저장된 게시물이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '마음에 드는 게시물을 저장해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
