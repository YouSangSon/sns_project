import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConfig.appName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () => context.push('/messages'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedStateProvider.notifier).refreshPosts(),
        color: AppColors.primary,
        child: feedState.isLoading && feedState.posts.isEmpty
            ? const CenteredLoading()
            : feedState.posts.isEmpty
                ? EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: 'No posts yet',
                    subtitle: 'Follow users to see their posts here',
                    actionText: 'Find users',
                    onAction: () => context.go('/search'),
                  )
                : ListView.builder(
                    itemCount: feedState.posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == feedState.posts.length) {
                        if (feedState.hasMore) {
                          // Load more
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(feedStateProvider.notifier).loadPosts();
                          });
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: LoadingIndicator(size: 24),
                            ),
                          );
                        }
                        return const SizedBox(height: 20);
                      }

                      final post = feedState.posts[index];
                      return PostCard(
                        post: post,
                        onLike: () {
                          ref.read(feedStateProvider.notifier).likePost(post.postId);
                        },
                        onComment: () {
                          context.push('/post/${post.postId}');
                        },
                        onShare: () {
                          // Share functionality
                        },
                        onBookmark: () {
                          ref.read(feedStateProvider.notifier).bookmarkPost(post.postId);
                        },
                        onUserTap: () {
                          context.push('/user/${post.userId}');
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
