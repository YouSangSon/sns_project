import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// 알림 페이지
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          final type = index % 4;
          return _NotificationItem(
            avatarUrl: null,
            username: 'user_$index',
            type: type,
            postThumbnail: type == 0 || type == 1 ? '' : null,
            time: '${index + 1}시간 전',
            isRead: index > 5,
            onTap: () {
              if (type == 0 || type == 1) {
                context.push('/post/post_$index');
              } else {
                context.push('/user/user_$index');
              }
            },
            onFollow: type == 2
                ? () {
                    // TODO: Follow back
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final int type; // 0: like, 1: comment, 2: follow, 3: mention
  final String? postThumbnail;
  final String time;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onFollow;

  const _NotificationItem({
    required this.avatarUrl,
    required this.username,
    required this.type,
    this.postThumbnail,
    required this.time,
    required this.isRead,
    required this.onTap,
    this.onFollow,
  });

  String get _message {
    switch (type) {
      case 0:
        return '님이 회원님의 게시물을 좋아합니다.';
      case 1:
        return '님이 댓글을 남겼습니다: "좋아요!"';
      case 2:
        return '님이 회원님을 팔로우하기 시작했습니다.';
      case 3:
        return '님이 댓글에서 회원님을 언급했습니다.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? null : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _message),
                    TextSpan(
                      text: ' $time',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Trailing
            if (onFollow != null)
              ElevatedButton(
                onPressed: onFollow,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text('팔로우'),
              )
            else if (postThumbnail != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
