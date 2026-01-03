import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// Mock portfolios
final mockPortfolios = [
  Portfolio(
    portfolioId: 'port-001',
    userId: 'dev-user-001',
    name: '장기 투자 포트폴리오',
    description: '10년 이상 장기 보유 목적',
    currency: 'KRW',
    totalValue: 50000000,
    totalProfit: 5000000,
    totalProfitRate: 11.11,
    followers: 25,
    isPublic: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  ),
  Portfolio(
    portfolioId: 'port-002',
    userId: 'dev-user-001',
    name: 'US Tech 포트폴리오',
    description: '미국 기술주 중심',
    currency: 'USD',
    totalValue: 10000,
    totalProfit: -500,
    totalProfitRate: -4.76,
    followers: 15,
    isPublic: true,
    createdAt: DateTime(2024, 3, 1),
    updatedAt: DateTime.now(),
  ),
  Portfolio(
    portfolioId: 'port-003',
    userId: 'dev-user-001',
    name: '배당주 포트폴리오',
    description: '배당 수익 중심',
    currency: 'KRW',
    totalValue: 20000000,
    totalProfit: 1500000,
    totalProfitRate: 8.11,
    followers: 42,
    isPublic: false,
    createdAt: DateTime(2024, 6, 1),
    updatedAt: DateTime.now(),
  ),
];

class PortfolioListScreen extends ConsumerWidget {
  const PortfolioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포트폴리오'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () => context.push('/create-portfolio'),
          ),
        ],
      ),
      body: mockPortfolios.isEmpty
          ? EmptyState(
              icon: Icons.pie_chart_outline,
              title: '포트폴리오가 없습니다',
              subtitle: '새 포트폴리오를 만들어 투자 내역을 관리하세요',
              actionText: '포트폴리오 만들기',
              onAction: () => context.push('/create-portfolio'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockPortfolios.length,
              itemBuilder: (context, index) {
                return _PortfolioCard(
                  portfolio: mockPortfolios[index],
                  onTap: () => context.push(
                    '/portfolio/${mockPortfolios[index].portfolioId}',
                  ),
                );
              },
            ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback onTap;

  const _PortfolioCard({
    required this.portfolio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final profitColor =
        portfolio.totalProfitRate >= 0 ? AppColors.profit : AppColors.loss;
    final currencyFormat = portfolio.currency == 'KRW'
        ? NumberFormat.currency(locale: 'ko_KR', symbol: '₩')
        : NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        portfolio.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (portfolio.isPublic) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.public,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    portfolio.currency,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              if (portfolio.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  portfolio.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      label: '총 자산',
                      value: currencyFormat.format(portfolio.totalValue),
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: '수익률',
                      value:
                          '${portfolio.totalProfitRate >= 0 ? '+' : ''}${portfolio.totalProfitRate.toStringAsFixed(2)}%',
                      valueColor: profitColor,
                    ),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: '수익/손실',
                      value: currencyFormat.format(portfolio.totalProfit),
                      valueColor: profitColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${portfolio.followers} 팔로워',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('yyyy.MM.dd').format(portfolio.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
