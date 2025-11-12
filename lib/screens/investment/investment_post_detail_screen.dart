import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/investment/investment_post.dart';
import '../../models/comment_model.dart';
import '../../services/investment_service.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class InvestmentPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const InvestmentPostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<InvestmentPostDetailScreen> createState() =>
      _InvestmentPostDetailScreenState();
}

class _InvestmentPostDetailScreenState
    extends ConsumerState<InvestmentPostDetailScreen> {
  final InvestmentService _investmentService = InvestmentService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _commentController = TextEditingController();

  bool _isLiked = false;
  bool _isFollowing = false;
  bool? _userVote; // null = no vote, true = bullish, false = bearish
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserInteractions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInteractions() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      final liked =
          await _investmentService.hasLikedPost(widget.postId, currentUser.uid);
      final vote =
          await _investmentService.getUserVote(widget.postId, currentUser.uid);

      setState(() {
        _isLiked = liked;
        _userVote = vote;
      });
    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }

  Future<void> _toggleLike() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      await _investmentService.likeInvestmentPost(
        widget.postId,
        currentUser.uid,
      );

      setState(() {
        _isLiked = !_isLiked;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _vote(bool isBullish) async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      await _investmentService.voteOnPost(
        widget.postId,
        currentUser.uid,
        isBullish,
      );

      setState(() {
        if (_userVote == isBullish) {
          _userVote = null; // Toggle off
        } else {
          _userVote = isBullish;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _toggleFollow(String userId) async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      if (_isFollowing) {
        await _databaseService.unfollowUser(currentUser.uid, userId);
      } else {
        await _databaseService.followUser(currentUser.uid, userId);
      }

      setState(() {
        _isFollowing = !_isFollowing;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      final comment = CommentModel(
        commentId: '',
        postId: widget.postId,
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _databaseService.addComment(comment);

      _commentController.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 작성되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: StreamBuilder<InvestmentPost?>(
        stream: _investmentService.getInvestmentPostById(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }

          final post = snapshot.data;

          if (post == null) {
            return const Center(child: Text('게시물을 찾을 수 없습니다'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPostHeader(post),
                    const SizedBox(height: 16),
                    _buildPostContent(post),
                    const SizedBox(height: 16),
                    if (post.relatedAssets.isNotEmpty) ...[
                      _buildRelatedAssets(post),
                      const SizedBox(height: 16),
                    ],
                    if (post.imageUrls.isNotEmpty) ...[
                      _buildImageGallery(post),
                      const SizedBox(height: 16),
                    ],
                    _buildSentimentVoting(post),
                    const SizedBox(height: 16),
                    _buildActions(post),
                    const Divider(height: 32),
                    _buildCommentsSection(),
                  ],
                ),
              ),
              if (currentUserAsync.value != null) _buildCommentInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(InvestmentPost post) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.value;
    final isOwnPost = currentUser?.uid == post.userId;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: post.userPhotoUrl.isNotEmpty
              ? NetworkImage(post.userPhotoUrl)
              : null,
          child: post.userPhotoUrl.isEmpty
              ? Text(post.username.substring(0, 1).toUpperCase())
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPostTypeColor(post.postType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.postType.koreanName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                timeago.format(post.createdAt, locale: 'ko'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!isOwnPost)
          OutlinedButton(
            onPressed: () => _toggleFollow(post.userId),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: BorderSide(
                color: _isFollowing ? Colors.grey : AppTheme.modernBlue,
              ),
            ),
            child: Text(
              _isFollowing ? '팔로잉' : '팔로우',
              style: TextStyle(
                color: _isFollowing ? Colors.grey : AppTheme.modernBlue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostContent(InvestmentPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.content,
          style: const TextStyle(fontSize: 16),
        ),
        if (post.sentiment != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSentimentColor(post.sentiment!).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getSentimentColor(post.sentiment!)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.sentiment!.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.sentiment!.koreanName} 전망',
                  style: TextStyle(
                    color: _getSentimentColor(post.sentiment!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (post.targetPrice != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.flag, size: 20, color: AppTheme.modernBlue),
              const SizedBox(width: 8),
              Text(
                '목표가: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(post.targetPrice)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
        if (post.timeHorizon != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 20, color: AppTheme.modernPurple),
              const SizedBox(width: 8),
              Text(
                _getTimeHorizonText(post.timeHorizon!),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.modernPurple,
                ),
              ),
            ],
          ),
        ],
        if (post.hashtags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.hashtags.map((tag) {
              return InkWell(
                onTap: () {
                  // Navigate to hashtag search
                },
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    color: AppTheme.modernBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedAssets(InvestmentPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '관련 종목',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: post.relatedAssets.map((symbol) {
            return ActionChip(
              avatar: const Icon(Icons.trending_up, size: 18),
              label: Text(symbol),
              onPressed: () {
                // Navigate to asset detail
                context.push('/investment/asset/$symbol');
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageGallery(InvestmentPost post) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrls[index],
                width: 300,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 300,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentimentVoting(InvestmentPost post) {
    final totalVotes = post.bullishCount + post.bearishCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '커뮤니티 투표',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _vote(true),
                  icon: const Icon(Icons.arrow_upward),
                  label: Text('강세 ${post.bullishCount}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _userVote == true ? Colors.white : Colors.green,
                    backgroundColor:
                        _userVote == true ? Colors.green : Colors.transparent,
                    side: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _vote(false),
                  icon: const Icon(Icons.arrow_downward),
                  label: Text('약세 ${post.bearishCount}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _userVote == false ? Colors.white : Colors.red,
                    backgroundColor:
                        _userVote == false ? Colors.red : Colors.transparent,
                    side: BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          if (totalVotes > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: post.bullishCount,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: post.bearishCount,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '강세 ${post.bullishRatio.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '약세 ${post.bearishRatio.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(InvestmentPost post) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : null,
          ),
          onPressed: _toggleLike,
        ),
        Text('${post.likes}'),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.comment_outlined),
          onPressed: () {
            // Scroll to comments
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
        Text('${post.comments}'),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            // TODO: Implement bookmark
          },
        ),
        Text('${post.bookmarks}'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share
          },
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '댓글',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<CommentModel>>(
          future: _databaseService.getComments(widget.postId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('오류: ${snapshot.error}');
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '첫 댓글을 남겨보세요',
                    style: TextStyle(color: AppTheme.lightTextSecondary),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _CommentCard(comment: comment);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
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
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }

  Color _getPostTypeColor(InvestmentPostType type) {
    switch (type) {
      case InvestmentPostType.idea:
        return AppTheme.modernBlue;
      case InvestmentPostType.performance:
        return Colors.green;
      case InvestmentPostType.trade:
        return AppTheme.modernPurple;
      case InvestmentPostType.analysis:
        return Colors.orange;
      case InvestmentPostType.question:
        return Colors.teal;
      case InvestmentPostType.news:
        return Colors.indigo;
      case InvestmentPostType.portfolio:
        return Colors.pink;
    }
  }

  Color _getSentimentColor(MarketSentiment sentiment) {
    switch (sentiment) {
      case MarketSentiment.bullish:
        return Colors.green;
      case MarketSentiment.bearish:
        return Colors.red;
      case MarketSentiment.neutral:
        return Colors.grey;
    }
  }

  String _getTimeHorizonText(String horizon) {
    switch (horizon) {
      case 'short':
        return '단기 투자 (< 3개월)';
      case 'medium':
        return '중기 투자 (3-12개월)';
      case 'long':
        return '장기 투자 (> 12개월)';
      default:
        return horizon;
    }
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.userPhotoUrl.isNotEmpty
                ? NetworkImage(comment.userPhotoUrl)
                : null,
            child: comment.userPhotoUrl.isEmpty
                ? Text(comment.username.substring(0, 1).toUpperCase())
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
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt, locale: 'ko'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Like comment
                      },
                      icon: const Icon(Icons.favorite_border, size: 16),
                      label: Text('${comment.likes}'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        // TODO: Reply to comment
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('답글'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
