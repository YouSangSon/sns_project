import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../models/investment/investment_post.dart';
import '../../services/investment_service.dart';
import '../../core/theme/app_theme.dart';

class InvestmentFeedScreen extends ConsumerStatefulWidget {
  const InvestmentFeedScreen({super.key});

  @override
  ConsumerState<InvestmentFeedScreen> createState() =>
      _InvestmentFeedScreenState();
}

class _InvestmentFeedScreenState extends ConsumerState<InvestmentFeedScreen> {
  final InvestmentService _investmentService = InvestmentService();
  InvestmentPostType? _filterType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 피드'),
        actions: [
          PopupMenuButton<InvestmentPostType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('전체'),
              ),
              ...InvestmentPostType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Text(type.koreanName),
                );
              }),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<InvestmentPost>>(
        stream: _filterType == null
            ? _investmentService.getInvestmentFeed(limit: 50)
            : _investmentService.getPostsByType(_filterType!, limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return InvestmentPostCard(post: posts[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/investment/create-post');
        },
        icon: const Icon(Icons.add),
        label: const Text('게시'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppTheme.modernGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '게시물이 없습니다',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 투자 아이디어를 공유해보세요',
            style: TextStyle(color: AppTheme.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}

class InvestmentPostCard extends ConsumerWidget {
  final InvestmentPost post;

  const InvestmentPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.userPhotoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(post.userPhotoUrl)
                      : null,
                  child: post.userPhotoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.postType.koreanName,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getTypeColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {
                    // Show options
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Related Assets Tags
            if (post.relatedAssets.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.relatedAssets.map((symbol) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.modernBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.modernBlue),
                    ),
                    child: Text(
                      '\$$symbol',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.modernBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),

            // Target Price for Ideas
            if (post.postType == InvestmentPostType.idea &&
                post.targetPrice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '목표가: \$${post.targetPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (post.timeHorizon != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.schedule, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeHorizonText(post.timeHorizon!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Images
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrls.first,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Sentiment Indicator
            if (post.sentiment != null) ...[
              Row(
                children: [
                  Text(
                    post.sentiment!.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.sentiment!.koreanName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            const Divider(),

            // Actions
            Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: post.likes.toString(),
                  onTap: () async {
                    await InvestmentService().likeInvestmentPost(
                      post.postId,
                      'userId', // TODO: Get actual user ID
                    );
                  },
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.comments.toString(),
                  onTap: () {
                    // Navigate to comments
                  },
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.bookmark_border,
                  label: post.bookmarks.toString(),
                  onTap: () {
                    // Bookmark post
                  },
                ),
                const Spacer(),
                // Bullish/Bearish Voting
                if (post.bullishCount + post.bearishCount > 0) ...[
                  Row(
                    children: [
                      Text(
                        '🐂 ${post.bullishCount}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '🐻 ${post.bearishCount}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Bullish/Bearish Vote Buttons
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await InvestmentService().voteOnPost(post.postId, true);
                    },
                    icon: const Text('🐂'),
                    label: const Text('강세'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await InvestmentService().voteOnPost(post.postId, false);
                    },
                    icon: const Text('🐻'),
                    label: const Text('약세'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (post.postType) {
      case InvestmentPostType.idea:
        return AppTheme.modernBlue;
      case InvestmentPostType.performance:
        return Colors.green;
      case InvestmentPostType.trade:
        return AppTheme.modernPurple;
      case InvestmentPostType.analysis:
        return Colors.orange;
      case InvestmentPostType.question:
        return AppTheme.modernPink;
      case InvestmentPostType.news:
        return Colors.teal;
      case InvestmentPostType.portfolio:
        return Colors.indigo;
    }
  }

  String _getTimeHorizonText(String horizon) {
    switch (horizon) {
      case 'short':
        return '단기';
      case 'medium':
        return '중기';
      case 'long':
        return '장기';
      default:
        return horizon;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
