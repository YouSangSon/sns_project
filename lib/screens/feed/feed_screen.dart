import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/story_circle.dart';
import '../stories/create_story_screen.dart';
import '../messages/messages_screen.dart';

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
      _loadStories();
    });
  }

  Future<void> _loadFeed() async {
    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user != null) {
      await postProvider.loadFeedPosts(authProvider.user!.uid);
    }
  }

  Future<void> _loadStories() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();

    if (authProvider.user != null) {
      await storyProvider.loadStories(authProvider.user!.uid);
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessagesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadFeed();
          await _loadStories();
        },
        child: Consumer2<PostProvider, StoryProvider>(
          builder: (context, postProvider, storyProvider, child) {
            if (postProvider.isLoading && storyProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                // Stories section
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Consumer2<StoryProvider, AuthProvider>(
                      builder: (context, storyProvider, authProvider, child) {
                        final userStories = storyProvider.userStories;
                        final currentUser = authProvider.userModel;

                        if (currentUser == null) {
                          return const SizedBox.shrink();
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: userStories.length + 1,
                          itemBuilder: (context, index) {
                            // Own story / Create story
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateStoryScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 2),
                                            ),
                                            child: CircleAvatar(
                                              radius: 34,
                                              backgroundImage:
                                                  currentUser.photoUrl.isNotEmpty
                                                      ? NetworkImage(
                                                          currentUser.photoUrl)
                                                      : null,
                                              child: currentUser.photoUrl.isEmpty
                                                  ? const Icon(Icons.person,
                                                      size: 30)
                                                  : null,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                              ),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Your story',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final userStoryData = userStories[index - 1];
                            final user = userStoryData['user'];
                            final stories = userStoryData['stories'];

                            return StoryCircle(
                              user: user,
                              stories: stories,
                              isOwnStory: false,
                              hasNewStory: true,
                              userIndex: index - 1,
                              allUserStories: userStories,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Posts section
                if (postProvider.feedPosts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
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
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return PostCard(post: postProvider.feedPosts[index]);
                      },
                      childCount: postProvider.feedPosts.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
