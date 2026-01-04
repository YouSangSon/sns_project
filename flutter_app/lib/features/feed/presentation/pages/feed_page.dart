import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/app_router.dart';
import '../../../../shared/widgets/post_card.dart';
import '../../../stories/presentation/widgets/stories_bar.dart';

/// 피드 페이지
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // TODO: Load more posts
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SNS App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push(AppRoutes.conversations),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh feed
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stories bar
            const SliverToBoxAdapter(
              child: StoriesBar(),
            ),

            // Divider
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),

            // Posts list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // TODO: Replace with actual posts
                  return PostCard(
                    postId: 'post_$index',
                    authorName: 'user_$index',
                    authorUsername: '@user_$index',
                    authorAvatarUrl: null,
                    imageUrls: [],
                    content: 'This is a sample post content #$index',
                    likesCount: index * 10,
                    commentsCount: index * 2,
                    isLiked: index % 2 == 0,
                    createdAt: DateTime.now().subtract(Duration(hours: index)),
                    onLike: () {},
                    onComment: () => context.push('/post/post_$index'),
                    onShare: () {},
                    onBookmark: () {},
                    onProfileTap: () => context.push('/user/user_$index'),
                  );
                },
                childCount: 10,
              ),
            ),

            // Loading indicator
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
