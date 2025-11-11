import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/user_provider.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    final authProvider = context.read<AuthProvider>();
    final messageProvider = context.read<MessageProvider>();

    if (authProvider.user != null) {
      await messageProvider.loadConversations(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text(authProvider.userModel?.username ?? 'Messages');
              },
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined),
            onPressed: () {
              // Video call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              _showNewMessageSheet(context);
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Messages',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showNewMessageSheet(context),
                    icon: const Icon(Icons.send),
                    label: const Text('Send Message'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadConversations,
            child: ListView.builder(
              itemCount: messageProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = messageProvider.conversations[index];
                return _ConversationTile(conversation: conversation);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _NewMessageSheet(),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.uid ?? '';

    // Get the other user's ID
    final otherUserId = conversation.participants
        .firstWhere((id) => id != currentUserId, orElse: () => '');

    if (otherUserId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder(
      future: context.read<UserProvider>().loadUser(otherUserId),
      builder: (context, snapshot) {
        // Get cached user from provider
        final userProvider = context.watch<UserProvider>();
        final otherUser = userProvider.currentUser;

        if (otherUser == null) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final unreadCount =
            conversation.unreadCount[currentUserId] ?? 0;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: otherUser.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(otherUser.photoUrl)
                : null,
            child:
                otherUser.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(
            otherUser.username,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              color: unreadCount > 0 ? Colors.black : Colors.grey,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeago.format(conversation.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: unreadCount > 0 ? Colors.blue : Colors.grey,
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  conversationId: conversation.conversationId,
                  otherUser: otherUser,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NewMessageSheet extends StatefulWidget {
  const _NewMessageSheet();

  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final _searchController = TextEditingController();
  List _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final userProvider = context.read<UserProvider>();
    await userProvider.searchUsers(query);

    setState(() {
      _searchResults = userProvider.searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'New Message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('Search for people'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? CachedNetworkImageProvider(user.photoUrl)
                              : null,
                          child: user.photoUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.displayName),
                        onTap: () async {
                          final authProvider = context.read<AuthProvider>();
                          final messageProvider =
                              context.read<MessageProvider>();

                          final conversationId =
                              await messageProvider.createOrGetConversation(
                            currentUserId: authProvider.user!.uid,
                            otherUserId: user.uid,
                          );

                          if (conversationId != null && mounted) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: conversationId,
                                  otherUser: user,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
