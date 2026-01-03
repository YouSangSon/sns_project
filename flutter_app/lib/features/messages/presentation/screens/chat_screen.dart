import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock messages
final mockMessages = [
  Message(
    messageId: 'm1',
    conversationId: 'conv-001',
    senderId: 'user-002',
    receiverId: 'dev-user-001',
    text: '안녕하세요!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Message(
    messageId: 'm2',
    conversationId: 'conv-001',
    senderId: 'dev-user-001',
    receiverId: 'user-002',
    text: '안녕하세요! 반갑습니다 😊',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
  ),
  Message(
    messageId: 'm3',
    conversationId: 'conv-001',
    senderId: 'user-002',
    receiverId: 'dev-user-001',
    text: '사진 너무 잘 찍으셨어요! 어디서 찍으신 거예요?',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
  ),
  Message(
    messageId: 'm4',
    conversationId: 'conv-001',
    senderId: 'dev-user-001',
    receiverId: 'user-002',
    text: '감사합니다! 제주도에서 찍었어요 🏝️',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
  ),
  Message(
    messageId: 'm5',
    conversationId: 'conv-001',
    senderId: 'user-002',
    receiverId: 'dev-user-001',
    text: '와 저도 제주도 가보고 싶어요!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Message> _messages = [];
  final String _currentUserId = 'dev-user-001';

  @override
  void initState() {
    super.initState();
    _messages.addAll(mockMessages.reversed);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      messageId: 'm${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: _currentUserId,
      receiverId: 'user-002',
      text: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
              radius: 18,
            ),
            const SizedBox(width: 12),
            const Text('jane_smith'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _currentUserId;

                return _MessageBubble(
                  message: message,
                  isMe: isMe,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewPadding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image_outlined, color: AppColors.primary),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundGray,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _sendMessage,
                  child: const Text(
                    'Send',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.myMessageBubble : AppColors.otherMessageBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Text(
          message.text ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}
