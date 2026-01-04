import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// 검색 페이지
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '검색',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.backgroundGray,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _isSearching = value.isNotEmpty;
              _searchQuery = value;
            });
          },
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildExploreGrid(),
    );
  }

  Widget _buildExploreGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        // Mix of regular and featured posts
        final isFeatured = index % 10 == 0;
        return GestureDetector(
          onTap: () => context.push('/post/explore_$index'),
          child: Container(
            color: Colors.grey[300],
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Icon(Icons.image, color: Colors.grey),
                if (index % 5 == 0)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.video_collection,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '인기'),
              Tab(text: '계정'),
              Tab(text: '오디오'),
              Tab(text: '태그'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Top results
                _buildTopResults(),
                // Accounts
                _buildAccountResults(),
                // Audio (placeholder)
                const Center(child: Text('오디오 검색 결과')),
                // Tags
                _buildTagResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopResults() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text('user_$index'),
          subtitle: Text('User $index • 팔로워 ${index * 100}명'),
          trailing: OutlinedButton(
            onPressed: () {},
            child: const Text('팔로우'),
          ),
          onTap: () => context.push('/user/user_$index'),
        );
      },
    );
  }

  Widget _buildAccountResults() {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Row(
            children: [
              Text('search_user_$index'),
              if (index % 3 == 0) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 16, color: AppColors.primary),
              ],
            ],
          ),
          subtitle: Text('Name $index'),
          trailing: OutlinedButton(
            onPressed: () {},
            child: const Text('팔로우'),
          ),
          onTap: () => context.push('/user/search_user_$index'),
        );
      },
    );
  }

  Widget _buildTagResults() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tag),
          ),
          title: Text('#${_searchQuery}_$index'),
          subtitle: Text('게시물 ${(index + 1) * 1000}개'),
          onTap: () {
            // TODO: Navigate to tag page
          },
        );
      },
    );
  }
}
