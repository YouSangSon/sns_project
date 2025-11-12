import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../providers/auth_provider_riverpod.dart';
import '../core/theme/app_theme.dart';

class CommentThreadWidget extends ConsumerStatefulWidget {
  final String postId;
  final CommentModel comment;
  final VoidCallback? onReplyAdded;

  const CommentThreadWidget({
    super.key,
    required this.postId,
    required this.comment,
    this.onReplyAdded,
  });

  @override
  ConsumerState<CommentThreadWidget> createState() => _CommentThreadWidgetState();
}

class _CommentThreadWidgetState extends ConsumerState<CommentThreadWidget> {
  bool _showReplies = false;
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      await _databaseService.addReply(
        postId: widget.postId,
        parentCommentId: widget.comment.commentId,
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        text: _replyController.text.trim(),
      );

      _replyController.clear();
      setState(() {
        _isReplying = false;
        _showReplies = true;
      });

      widget.onReplyAdded?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment
        _CommentTile(
          comment: widget.comment,
          onReplyTap: () {
            setState(() {
              _isReplying = !_isReplying;
            });
          },
          onViewRepliesTap: widget.comment.repliesCount > 0
              ? () {
                  setState(() {
                    _showReplies = !_showReplies;
                  });
                }
              : null,
        ),

        // Reply input field
        if (_isReplying)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Reply to ${widget.comment.username}...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppTheme.lightTextSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.modernBlue),
                  onPressed: _submitReply,
                ),
              ],
            ),
          ),

        // Replies list
        if (_showReplies)
          StreamBuilder<List<CommentModel>>(
            stream: _databaseService.getReplies(widget.comment.commentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: SizedBox(
                    height: 30,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                children: snapshot.data!.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: _CommentTile(
                      comment: reply,
                      isReply: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final VoidCallback? onReplyTap;
  final VoidCallback? onViewRepliesTap;

  const _CommentTile({
    required this.comment,
    this.isReply = false,
    this.onReplyTap,
    this.onViewRepliesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 16 : 18,
            backgroundImage: comment.userPhotoUrl.isNotEmpty
                ? CachedNetworkImageProvider(comment.userPhotoUrl)
                : null,
            child: comment.userPhotoUrl.isEmpty
                ? Icon(Icons.person, size: isReply ? 16 : 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${comment.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (comment.likes > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${comment.likes} ${comment.likes == 1 ? 'like' : 'likes'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (!isReply && onReplyTap != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onReplyTap,
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (!isReply && comment.repliesCount > 0 && onViewRepliesTap != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onViewRepliesTap,
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 12,
                              color: AppTheme.modernBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.repliesCount} ${comment.repliesCount == 1 ? 'reply' : 'replies'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.modernBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              comment.likes > 0 ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.likes > 0 ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              // Like comment functionality
              // TODO: Implement like comment
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
