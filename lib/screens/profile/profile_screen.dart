import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/post_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final postProvider = context.read<PostProvider>();
    final authProvider = context.read<AuthProvider>();

    // Load user data
    await userProvider.loadUser(widget.userId);
    _user = userProvider.currentUser;

    // Load user posts
    await postProvider.loadUserPosts(widget.userId);
    _posts = postProvider.userPosts;

    // Check if following
    if (authProvider.user != null && widget.userId != authProvider.user!.uid) {
      _isFollowing = await userProvider.isFollowing(
        authProvider.user!.uid,
        widget.userId,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user == null) return;

    setState(() {
      _isFollowing = !_isFollowing;
    });

    if (_isFollowing) {
      await userProvider.followUser(authProvider.user!.uid, widget.userId);
    } else {
      await userProvider.unfollowUser(authProvider.user!.uid, widget.userId);
    }

    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isOwnProfile = authProvider.user?.uid == widget.userId;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showProfileMenu(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile picture
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _user!.photoUrl.isNotEmpty
                              ? CachedNetworkImageProvider(_user!.photoUrl)
                              : null,
                          child: _user!.photoUrl.isEmpty
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 24),

                        // Stats
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Posts', _user!.posts),
                              _buildStatColumn('Followers', _user!.followers),
                              _buildStatColumn('Following', _user!.following),
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
                          _user!.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (_user!.bio.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_user!.bio),
                        ],
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (isOwnProfile)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/edit-profile'),
                              child: const Text('Edit Profile'),
                            ),
                          )
                        else ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _toggleFollow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing
                                    ? Colors.grey[300]
                                    : Theme.of(context).primaryColor,
                                foregroundColor:
                                    _isFollowing ? Colors.black : Colors.white,
                              ),
                              child: Text(_isFollowing ? 'Following' : 'Follow'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Message functionality
                              },
                              child: const Text('Message'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(),

                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
                ],
              ),
            ),

            // Grid of posts
            SliverPadding(
              padding: const EdgeInsets.all(2),
              sliver: _posts.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Posts Yet',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isOwnProfile) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Share your first photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = _posts[index];
                          return GestureDetector(
                            onTap: () => context.push('/post/${post.postId}'),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                        childCount: _posts.length,
                      ),
                    ),
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
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
