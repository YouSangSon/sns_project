import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock notifications
final mockNotifications = [
  AppNotification(
    notificationId: 'n1',
    userId: 'dev-user-001',
    type: NotificationType.like,
    message: 'liked your photo',
    actorId: 'user-002',
    actorUsername: 'jane_smith',
    actorPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
    relatedPostId: 'post-001',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  AppNotification(
    notificationId: 'n2',
    userId: 'dev-user-001',
    type: NotificationType.follow,
    message: 'started following you',
    actorId: 'user-003',
    actorUsername: 'travel_lover',
    actorPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=travel',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AppNotification(
    notificationId: 'n3',
    userId: 'dev-user-001',
    type: NotificationType.comment,
    message: 'commented: "정말 멋져요!"',
    actorId: 'user-004',
    actorUsername: 'foodie_korea',
    actorPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=foodie',
    relatedPostId: 'post-002',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AppNotification(
    notificationId: 'n4',
    userId: 'dev-user-001',
    type: NotificationType.mention,
    message: 'mentioned you in a comment',
    actorId: 'user-005',
    actorUsername: 'tech_guy',
    actorPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=tech',
    relatedPostId: 'post-003',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = mockNotifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () {},
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: mockNotifications.isEmpty
          ? EmptyState(
              icon: Icons.notifications_outlined,
              title: 'No notifications yet',
              subtitle:
                  'When someone likes, comments, or follows you, you\'ll see it here',
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                itemCount: mockNotifications.length,
                itemBuilder: (context, index) {
                  return _NotificationTile(
                    notification: mockNotifications[index],
                    onTap: () {
                      final n = mockNotifications[index];
                      if (n.relatedPostId != null) {
                        context.push('/post/${n.relatedPostId}');
                      } else if (n.type == NotificationType.follow &&
                          n.actorId != null) {
                        context.push('/user/${n.actorId}');
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? null : AppColors.backgroundGray,
      child: ListTile(
        onTap: onTap,
        leading: notification.actorPhotoUrl != null
            ? CircleAvatar(
                imageUrl: notification.actorPhotoUrl,
                radius: 24,
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(),
                  color: _getNotificationColor(),
                ),
              ),
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              if (notification.actorUsername != null)
                TextSpan(
                  text: '${notification.actorUsername} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              TextSpan(text: notification.message),
            ],
          ),
        ),
        subtitle: Text(
          timeago.format(notification.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.like:
        return AppColors.like;
      case NotificationType.comment:
        return AppColors.primary;
      case NotificationType.follow:
        return AppColors.primary;
      case NotificationType.mention:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}
