import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeed();
    });
  }

  Future<void> _loadFeed() async {
    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user != null) {
      await postProvider.loadFeedPosts(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF405DE6),
              Color(0xFFC13584),
              Color(0xFFE1306C),
            ],
          ).createShader(bounds),
          child: const Text(
            'SNS App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Navigate to messages
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: Consumer<PostProvider>(
          builder: (context, postProvider, child) {
            if (postProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (postProvider.feedPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Follow people to see their posts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: postProvider.feedPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: postProvider.feedPosts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
