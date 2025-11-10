import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
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

    final userProvider = context.read<UserProvider>();
    await userProvider.searchUsers(query);

    setState(() {
      _searchResults = userProvider.searchResults;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return _buildExploreGrid();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(user.photoUrl)
                : null,
            child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.displayName),
          trailing: Text(
            '${user.followers} followers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          onTap: () {
            context.push('/profile/${user.uid}');
          },
        );
      },
    );
  }

  Widget _buildExploreGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 30, // Placeholder
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.image,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
        );
      },
    );
  }
}
