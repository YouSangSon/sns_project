import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock conversations
final mockConversations = [
  Conversation(
    conversationId: 'conv-001',
    participantId: 'user-002',
    participantUsername: 'jane_smith',
    participantPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
    lastMessage: Message(
      messageId: 'm1',
      conversationId: 'conv-001',
      senderId: 'user-002',
      receiverId: 'dev-user-001',
      text: '안녕하세요! 사진 너무 잘 찍으셨어요',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    unreadCount: 2,
    updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Conversation(
    conversationId: 'conv-002',
    participantId: 'user-003',
    participantUsername: 'travel_lover',
    participantPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=travel',
    lastMessage: Message(
      messageId: 'm2',
      conversationId: 'conv-002',
      senderId: 'dev-user-001',
      receiverId: 'user-003',
      text: '제주도 어디가 제일 좋았어요?',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    unreadCount: 0,
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Conversation(
    conversationId: 'conv-003',
    participantId: 'user-004',
    participantUsername: 'foodie_korea',
    participantPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=foodie',
    lastMessage: Message(
      messageId: 'm3',
      conversationId: 'conv-003',
      senderId: 'user-004',
      receiverId: 'dev-user-001',
      text: '맛집 추천해주실 수 있어요?',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    unreadCount: 1,
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ),
        ],
      ),
      body: mockConversations.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No messages yet',
              subtitle: 'Start a conversation with your friends',
            )
          : ListView.builder(
              itemCount: mockConversations.length,
              itemBuilder: (context, index) {
                final conversation = mockConversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  onTap: () => context.push('/chat/${conversation.conversationId}'),
                );
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        imageUrl: conversation.participantPhotoUrl,
        radius: 28,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.participantUsername,
              style: TextStyle(
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            timeago.format(conversation.updatedAt, locale: 'en_short'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage?.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: conversation.unreadCount > 0
                    ? AppColors.text
                    : AppColors.textSecondary,
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
