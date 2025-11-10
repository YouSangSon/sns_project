import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    // Placeholder - In a real app, this would fetch from Firestore
    final notifications = <Map<String, dynamic>>[];

    if (notifications.isEmpty) {
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

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: notification['userPhotoUrl'] != null
            ? CachedNetworkImageProvider(notification['userPhotoUrl'])
            : null,
        child: notification['userPhotoUrl'] == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '${notification['username']} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: notification['text']),
          ],
        ),
      ),
      subtitle: Text(
        timeago.format(notification['createdAt'] as DateTime),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: notification['postImageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: notification['postImageUrl'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : notification['type'] == 'follow'
              ? ElevatedButton(
                  onPressed: () {
                    // Follow back functionality
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Follow'),
                )
              : null,
      onTap: () {
        // Navigate to post or profile based on notification type
      },
    );
  }
}
