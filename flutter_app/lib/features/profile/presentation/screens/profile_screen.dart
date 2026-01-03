import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  // Mock user posts
  final List<String> _userPosts = List.generate(
    12,
    (i) => 'https://picsum.photos/seed/profile$i/300/300',
  );

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
    final currentUser = ref.watch(currentUserProvider);
    final isOwnProfile = widget.userId == null || widget.userId == currentUser?.userId;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridItemSize = screenWidth / 3;

    // Use current user for own profile, otherwise mock data
    final user = isOwnProfile
        ? currentUser
        : User(
            userId: widget.userId!,
            username: 'other_user',
            email: 'other@example.com',
            displayName: 'Other User',
            photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=${widget.userId}',
            bio: 'This is another user profile',
            followerCount: 500,
            followingCount: 300,
            postCount: 25,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    if (user == null) {
      return const Scaffold(body: CenteredLoading());
    }

    return Scaffold(
      appBar: AppBar(
        leading: isOwnProfile
            ? IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        title: Text('@${user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          imageUrl: user.photoUrl,
                          radius: 44,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Posts', user.postCount),
                              _buildStatColumn('Followers', user.followerCount),
                              _buildStatColumn('Following', user.followingCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(user.bio!),
                        ],
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (isOwnProfile) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/edit-profile'),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _isFollowing = !_isFollowing);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing
                                    ? AppColors.backgroundGray
                                    : AppColors.primary,
                                foregroundColor: _isFollowing
                                    ? AppColors.text
                                    : AppColors.textLight,
                              ),
                              child: Text(_isFollowing ? 'Following' : 'Follow'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Message'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.text,
                    labelColor: AppColors.text,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.video_collection_outlined)),
                      Tab(icon: Icon(Icons.person_pin_outlined)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Grid Posts
            GridView.builder(
              padding: const EdgeInsets.all(1),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                return CachedImage(
                  imageUrl: _userPosts[index],
                  width: gridItemSize,
                  height: gridItemSize,
                  fit: BoxFit.cover,
                );
              },
            ),

            // Reels
            EmptyState(
              icon: Icons.video_collection_outlined,
              title: 'No reels yet',
              subtitle: 'Share your first reel',
            ),

            // Tagged
            EmptyState(
              icon: Icons.person_pin_outlined,
              title: 'No tagged posts',
              subtitle: 'Photos and videos where you\'re tagged will appear here',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
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

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved'),
              onTap: () {
                Navigator.pop(context);
                context.push('/bookmarks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
