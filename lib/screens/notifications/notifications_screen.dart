import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    if (authProvider.user != null) {
      await notificationProvider.loadNotifications(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    if (authProvider.user != null) {
                      await notificationProvider.markAllAsRead(
                        authProvider.user!.uid,
                      );
                    }
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: authProvider.user == null
          ? const Center(child: Text('Please login'))
          : StreamBuilder<List<NotificationModel>>(
              stream: context
                  .read<NotificationProvider>()
                  .getNotificationsStream(authProvider.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You'll see activity here when it happens",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notifications = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _NotificationTile(
                        notification: notifications[index],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  String _getNotificationText() {
    switch (notification.type) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a comment';
      default:
        return notification.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.read<NotificationProvider>();
    final userProvider = context.read<UserProvider>();

    return Container(
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: notification.fromUserPhotoUrl.isNotEmpty
              ? CachedNetworkImageProvider(notification.fromUserPhotoUrl)
              : null,
          child: notification.fromUserPhotoUrl.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: '${notification.fromUsername} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: _getNotificationText()),
            ],
          ),
        ),
        subtitle: Text(
          timeago.format(notification.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: notification.postImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: notification.postImageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : notification.type == 'follow'
                ? FutureBuilder<bool>(
                    future: userProvider.isFollowing(
                      context.read<AuthProvider>().user!.uid,
                      notification.fromUserId,
                    ),
                    builder: (context, snapshot) {
                      final isFollowing = snapshot.data ?? false;

                      return ElevatedButton(
                        onPressed: () async {
                          if (isFollowing) {
                            await userProvider.unfollowUser(
                              context.read<AuthProvider>().user!.uid,
                              notification.fromUserId,
                            );
                          } else {
                            await userProvider.followUser(
                              context.read<AuthProvider>().user!.uid,
                              notification.fromUserId,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor:
                              isFollowing ? Colors.grey : Colors.blue,
                        ),
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      );
                    },
                  )
                : null,
        onTap: () async {
          // Mark as read
          if (!notification.isRead) {
            await notificationProvider.markAsRead(notification.notificationId);
          }

          // Navigate based on type
          if (notification.type == 'follow') {
            context.push('/profile/${notification.fromUserId}');
          } else if (notification.postId != null) {
            context.push('/post/${notification.postId}');
          }
        },
      ),
    );
  }
}
