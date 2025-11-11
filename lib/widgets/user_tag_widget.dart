import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../core/theme/app_theme.dart';

/// Widget for searching and selecting users to tag
class UserTagSelector extends ConsumerStatefulWidget {
  final List<String> selectedUserIds;
  final Function(List<String>) onUsersSelected;

  const UserTagSelector({
    super.key,
    required this.selectedUserIds,
    required this.onUsersSelected,
  });

  @override
  ConsumerState<UserTagSelector> createState() => _UserTagSelectorState();
}

class _UserTagSelectorState extends ConsumerState<UserTagSelector> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<UserModel> _searchResults = [];
  List<String> _selectedUserIds = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedUserIds = List.from(widget.selectedUserIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final users = await _databaseService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  void _toggleUser(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _saveSelection() {
    widget.onUsersSelected(_selectedUserIds);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag People'),
        actions: [
          TextButton(
            onPressed: _saveSelection,
            child: Text(
              'Done (${_selectedUserIds.length})',
              style: const TextStyle(
                color: AppTheme.modernBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.lightBackground,
              ),
              onChanged: _searchUsers,
            ),
          ),

          // Selected users chips
          if (_selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedUserIds.map((userId) {
                    return FutureBuilder<UserModel?>(
                      future: _databaseService.getUserById(userId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final user = snapshot.data!;
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          label: Text(user.username),
                          onDeleted: () => _toggleUser(userId),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

          const Divider(),

          // Search results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Search for people to tag'
                                  : 'No users found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUserIds.contains(user.uid);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.photoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(user.photoUrl)
                                  : null,
                              child: user.photoUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              user.username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(user.fullName ?? ''),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleUser(user.uid),
                              activeColor: AppTheme.modernBlue,
                            ),
                            onTap: () => _toggleUser(user.uid),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display tagged users on a post
class TaggedUsersDisplay extends StatelessWidget {
  final List<String> taggedUserIds;
  final DatabaseService _databaseService = DatabaseService();

  TaggedUsersDisplay({
    super.key,
    required this.taggedUserIds,
  });

  @override
  Widget build(BuildContext context) {
    if (taggedUserIds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.person_pin, size: 16, color: AppTheme.lightTextSecondary),
          const SizedBox(width: 4),
          Expanded(
            child: FutureBuilder<List<UserModel?>>(
              future: Future.wait(
                taggedUserIds.map((id) => _databaseService.getUserById(id)),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    '${taggedUserIds.length} people',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.lightTextSecondary,
                    ),
                  );
                }

                final users = snapshot.data!.whereType<UserModel>().toList();
                final usernames = users.map((u) => u.username).join(', ');

                return GestureDetector(
                  onTap: () {
                    _showTaggedUsers(context, users);
                  },
                  child: Text(
                    usernames,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.modernBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTaggedUsers(BuildContext context, List<UserModel> users) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tagged People',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...users.map((user) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.fullName ?? ''),
                  onTap: () {
                    // Navigate to user profile
                    Navigator.pop(context);
                    // TODO: Navigate to profile screen
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
