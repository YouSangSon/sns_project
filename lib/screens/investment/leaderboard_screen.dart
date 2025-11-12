import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/investment/investment_portfolio.dart';
import '../../services/investment_service.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

enum LeaderboardType {
  allTime,
  weekly,
  followers,
}

extension LeaderboardTypeExtension on LeaderboardType {
  String get displayName {
    switch (this) {
      case LeaderboardType.allTime:
        return '전체 순위';
      case LeaderboardType.weekly:
        return '주간 순위';
      case LeaderboardType.followers:
        return '인기 투자자';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardType.allTime:
        return Icons.emoji_events;
      case LeaderboardType.weekly:
        return Icons.trending_up;
      case LeaderboardType.followers:
        return Icons.people;
    }
  }
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final InvestmentService _investmentService = InvestmentService();
  final DatabaseService _databaseService = DatabaseService();

  late TabController _tabController;
  int? _userRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserRank();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRank() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return;

    try {
      final rank = await _investmentService.getUserRank(currentUser.uid);
      setState(() {
        _userRank = rank;
      });
    } catch (e) {
      print('Error loading user rank: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 랭킹'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(LeaderboardType.allTime.icon),
              text: LeaderboardType.allTime.displayName,
            ),
            Tab(
              icon: Icon(LeaderboardType.weekly.icon),
              text: LeaderboardType.weekly.displayName,
            ),
            Tab(
              icon: Icon(LeaderboardType.followers.icon),
              text: LeaderboardType.followers.displayName,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_userRank != null) _buildUserRankBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTimeLeaderboard(),
                _buildWeeklyLeaderboard(),
                _buildFollowersLeaderboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankBanner() {
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.modernBlue, AppTheme.modernPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$_userRank',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나의 순위',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  currentUser.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildAllTimeLeaderboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _investmentService.getTopPerformers(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final leaderboard = snapshot.data ?? [];

        if (leaderboard.isEmpty) {
          return _buildEmptyState('아직 랭킹 데이터가 없습니다');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final portfolio = entry['portfolio'] as InvestmentPortfolio;
            final username = entry['username'] as String;
            final userPhotoUrl = entry['userPhotoUrl'] as String;
            final followers = entry['followers'] as int;

            return _LeaderboardCard(
              rank: index + 1,
              username: username,
              userPhotoUrl: userPhotoUrl,
              portfolio: portfolio,
              followers: followers,
              onTap: () {
                // Navigate to portfolio detail
                context.push('/investment/portfolio/${portfolio.portfolioId}');
              },
              onFollowToggle: () async {
                // TODO: Implement follow toggle
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyLeaderboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _investmentService.getWeeklyTopPerformers(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final leaderboard = snapshot.data ?? [];

        if (leaderboard.isEmpty) {
          return _buildEmptyState('이번 주 랭킹 데이터가 없습니다');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final portfolio = entry['portfolio'] as InvestmentPortfolio;
            final username = entry['username'] as String;
            final userPhotoUrl = entry['userPhotoUrl'] as String;
            final followers = entry['followers'] as int;

            return _LeaderboardCard(
              rank: index + 1,
              username: username,
              userPhotoUrl: userPhotoUrl,
              portfolio: portfolio,
              followers: followers,
              isWeekly: true,
              onTap: () {
                context.push('/investment/portfolio/${portfolio.portfolioId}');
              },
              onFollowToggle: () async {
                // TODO: Implement follow toggle
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFollowersLeaderboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _investmentService.getTopInvestorsByFollowers(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final leaderboard = snapshot.data ?? [];

        if (leaderboard.isEmpty) {
          return _buildEmptyState('아직 인기 투자자가 없습니다');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final portfolio = entry['portfolio'] as InvestmentPortfolio;
            final username = entry['username'] as String;
            final userPhotoUrl = entry['userPhotoUrl'] as String;
            final followers = entry['followers'] as int;

            return _LeaderboardCard(
              rank: index + 1,
              username: username,
              userPhotoUrl: userPhotoUrl,
              portfolio: portfolio,
              followers: followers,
              showFollowers: true,
              onTap: () {
                context.push('/investment/portfolio/${portfolio.portfolioId}');
              },
              onFollowToggle: () async {
                // TODO: Implement follow toggle
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.leaderboard,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final String username;
  final String userPhotoUrl;
  final InvestmentPortfolio portfolio;
  final int followers;
  final bool isWeekly;
  final bool showFollowers;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  const _LeaderboardCard({
    required this.rank,
    required this.username,
    required this.userPhotoUrl,
    required this.portfolio,
    required this.followers,
    this.isWeekly = false,
    this.showFollowers = false,
    required this.onTap,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final percentFormat = NumberFormat.percentPattern();

    final isTopThree = rank <= 3;
    final medalColor = rank == 1
        ? const Color(0xFFFFD700) // Gold
        : rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : const Color(0xFFCD7F32); // Bronze

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTopThree ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isTopThree ? medalColor : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: isTopThree
                      ? [
                          BoxShadow(
                            color: medalColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isTopThree
                      ? Icon(
                          rank == 1
                              ? Icons.emoji_events
                              : Icons.workspace_premium,
                          color: Colors.white,
                          size: 28,
                        )
                      : Text(
                          '#$rank',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // User Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    userPhotoUrl.isNotEmpty ? NetworkImage(userPhotoUrl) : null,
                child: userPhotoUrl.isEmpty
                    ? Text(username.substring(0, 1).toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isTopThree) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: medalColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showFollowers) ...[
                          const Icon(
                            Icons.people,
                            size: 14,
                            color: AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${NumberFormat.compact().format(followers)} 팔로워',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightTextSecondary,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 14,
                            color: AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currencyFormat.format(portfolio.totalValue),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isWeekly) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '주간 핫',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Return Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: portfolio.returnPercentage >= 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: portfolio.returnPercentage >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          portfolio.returnPercentage >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: portfolio.returnPercentage >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${portfolio.returnPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: portfolio.returnPercentage >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(portfolio.totalReturn),
                    style: TextStyle(
                      fontSize: 12,
                      color: portfolio.totalReturn >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
