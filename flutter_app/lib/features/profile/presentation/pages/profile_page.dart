import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/app_router.dart';

/// 프로필 페이지
class ProfilePage extends ConsumerStatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get isMyProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: isMyProfile ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('username'),
        actions: [
          if (isMyProfile) ...[
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () => context.push(AppRoutes.createPost),
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showSettingsSheet(context),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile header
                    Row(
                      children: [
                        // Avatar
                        const CircleAvatar(
                          radius: 42,
                          child: Icon(Icons.person, size: 42),
                        ),
                        const SizedBox(width: 24),

                        // Stats
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('게시물', '128'),
                              _buildStatColumn('팔로워', '1.2K'),
                              _buildStatColumn('팔로잉', '456'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name and bio
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('This is a sample bio for the profile page.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        if (isMyProfile)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  context.push(AppRoutes.editProfile),
                              child: const Text('프로필 편집'),
                            ),
                          )
                        else ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('팔로우'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('메시지'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.textPrimary,
                  tabs: [
                    const Tab(icon: Icon(Icons.grid_on)),
                    const Tab(icon: Icon(Icons.person_pin_outlined)),
                    if (isMyProfile) const Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts grid
            _buildPostsGrid(),
            // Tagged posts
            _buildPostsGrid(),
            // Saved posts (only for my profile)
            if (isMyProfile) _buildPostsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push('/post/post_$index'),
          child: Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('설정'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('활동'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('QR 코드'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('저장됨'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('포트폴리오'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.portfolio);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('로그아웃',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Logout
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
