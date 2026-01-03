import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock users for search
final mockUsers = [
  User(
    userId: 'user-001',
    username: 'john_doe',
    email: 'john@example.com',
    displayName: 'John Doe',
    photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    bio: 'Photographer & Traveler',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  User(
    userId: 'user-002',
    username: 'jane_smith',
    email: 'jane@example.com',
    displayName: 'Jane Smith',
    photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
    bio: 'Food lover 🍕',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  User(
    userId: 'user-003',
    username: 'travel_lover',
    email: 'travel@example.com',
    displayName: 'Travel Lover',
    photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=travel',
    bio: 'Exploring the world ✈️',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = mockUsers
              .where((user) =>
                  user.username.toLowerCase().contains(query.toLowerCase()) ||
                  user.displayName.toLowerCase().contains(query.toLowerCase()))
              .toList();
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.backgroundGray,
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const CenteredLoading()
                : _searchController.text.isEmpty
                    ? _buildEmptySearch()
                    : _searchResults.isEmpty
                        ? EmptyState(
                            icon: Icons.person_search,
                            title: 'No results found',
                            subtitle: 'Try searching for a different username',
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return _UserTile(
                                user: _searchResults[index],
                                onTap: () => context.push(
                                  '/user/${_searchResults[index].userId}',
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return EmptyState(
      icon: Icons.search,
      title: 'Search for users',
      subtitle: 'Find friends and discover new accounts',
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        imageUrl: user.photoUrl,
        radius: 24,
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.displayName),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }
}
