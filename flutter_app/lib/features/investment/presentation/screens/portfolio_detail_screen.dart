import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';

// Mock holdings
final mockHoldings = [
  Holding(
    holdingId: 'h1',
    portfolioId: 'port-001',
    symbol: 'AAPL',
    name: 'Apple Inc.',
    quantity: 10,
    averagePrice: 150,
    currentPrice: 180,
    totalValue: 1800,
    profit: 300,
    profitRate: 20,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Holding(
    holdingId: 'h2',
    portfolioId: 'port-001',
    symbol: 'GOOGL',
    name: 'Alphabet Inc.',
    quantity: 5,
    averagePrice: 140,
    currentPrice: 155,
    totalValue: 775,
    profit: 75,
    profitRate: 10.71,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Holding(
    holdingId: 'h3',
    portfolioId: 'port-001',
    symbol: 'TSLA',
    name: 'Tesla Inc.',
    quantity: 8,
    averagePrice: 250,
    currentPrice: 220,
    totalValue: 1760,
    profit: -240,
    profitRate: -12,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

class PortfolioDetailScreen extends ConsumerWidget {
  final String portfolioId;

  const PortfolioDetailScreen({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the portfolio (in real app, fetch from API)
    final portfolio = Portfolio(
      portfolioId: portfolioId,
      userId: 'dev-user-001',
      name: '장기 투자 포트폴리오',
      description: '10년 이상 장기 보유 목적',
      currency: 'USD',
      totalValue: 4335,
      totalProfit: 135,
      totalProfitRate: 3.21,
      followers: 25,
      isPublic: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    );

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final profitColor =
        portfolio.totalProfitRate >= 0 ? AppColors.profit : AppColors.loss;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(portfolio.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 자산',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(portfolio.totalValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${portfolio.totalProfitRate >= 0 ? '+' : ''}${portfolio.totalProfitRate.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormat.format(portfolio.totalProfit),
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Holdings Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '보유 종목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('종목 추가'),
                  ),
                ],
              ),
            ),

            // Holdings List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockHoldings.length,
              itemBuilder: (context, index) {
                return _HoldingTile(holding: mockHoldings[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  final Holding holding;

  const _HoldingTile({required this.holding});

  @override
  Widget build(BuildContext context) {
    final profitColor =
        holding.profitRate >= 0 ? AppColors.profit : AppColors.loss;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundGray,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          holding.symbol.substring(0, min(holding.symbol.length, 2)),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  holding.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(holding.totalValue),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${holding.profitRate >= 0 ? '+' : ''}${holding.profitRate.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: profitColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Text(
              '${holding.quantity}주',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '평균 ${currencyFormat.format(holding.averagePrice)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '현재 ${currencyFormat.format(holding.currentPrice)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
