import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/widgets.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock bookmarked posts
    final bookmarkedPosts = List.generate(
      6,
      (i) => 'https://picsum.photos/seed/bookmark$i/300/300',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Saved'),
      ),
      body: bookmarkedPosts.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border,
              title: 'No saved posts',
              subtitle: 'Save posts to see them here',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: bookmarkedPosts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.push('/post/post-00$index'),
                  child: CachedImage(
                    imageUrl: bookmarkedPosts[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
