import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/investment/investment_portfolio.dart';
import '../../models/investment/asset_holding.dart';
import '../../services/investment_service.dart';
import '../../services/market_data_service.dart';
import '../../core/theme/app_theme.dart';

class PortfolioDetailScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const PortfolioDetailScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<PortfolioDetailScreen> createState() =>
      _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends ConsumerState<PortfolioDetailScreen>
    with SingleTickerProviderStateMixin {
  final InvestmentService _investmentService = InvestmentService();
  final MarketDataService _marketDataService = MarketDataService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshPrices(List<AssetHolding> holdings) async {
    for (final holding in holdings) {
      MarketData? marketData;
      if (holding.assetType == AssetType.crypto) {
        marketData = await _marketDataService.getCryptoQuote(holding.symbol);
      } else {
        marketData = await _marketDataService.getStockQuote(holding.symbol);
      }

      if (marketData != null && marketData.price != holding.currentPrice) {
        final updatedHolding = holding.copyWith(
          currentPrice: marketData.price,
          totalValue: holding.quantity * marketData.price,
          updatedAt: DateTime.now(),
        );
        await _investmentService.updateHolding(updatedHolding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<InvestmentPortfolio?>(
        stream: _investmentService.getPortfolioStream(widget.portfolioId),
        builder: (context, portfolioSnapshot) {
          if (portfolioSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final portfolio = portfolioSnapshot.data;
          if (portfolio == null) {
            return const Center(child: Text('포트폴리오를 찾을 수 없습니다'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(portfolio.portfolioName),
                    background: _buildHeaderGradient(portfolio),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share portfolio
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showPortfolioOptions(context, portfolio),
                    ),
                  ],
                ),
              ];
            },
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.modernBlue,
                  tabs: const [
                    Tab(text: '보유'),
                    Tab(text: '차트'),
                    Tab(text: '거래내역'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHoldingsTab(portfolio),
                      _buildChartsTab(portfolio),
                      _buildTradesTab(portfolio),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAssetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('자산 추가'),
      ),
    );
  }

  Widget _buildHeaderGradient(InvestmentPortfolio portfolio) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isProfit = portfolio.totalReturn >= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.modernBlue, AppTheme.modernPurple],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyFormat.format(portfolio.totalValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isProfit ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${currencyFormat.format(portfolio.totalReturn)} (${portfolio.returnRate.toStringAsFixed(2)}%)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

  Widget _buildHoldingsTab(InvestmentPortfolio portfolio) {
    return StreamBuilder<List<AssetHolding>>(
      stream: _investmentService.getPortfolioHoldings(widget.portfolioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final holdings = snapshot.data ?? [];

        if (holdings.isEmpty) {
          return _buildEmptyHoldings();
        }

        return RefreshIndicator(
          onRefresh: () => _refreshPrices(holdings),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAssetAllocation(holdings),
              const SizedBox(height: 24),
              const Text(
                '보유 자산',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...holdings.map((holding) => _HoldingCard(holding: holding)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetAllocation(List<AssetHolding> holdings) {
    if (holdings.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '자산 배분',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: holdings.map((holding) {
                  final percentage =
                      (holding.totalValue / holding.totalValue) * 100;
                  return PieChartSectionData(
                    value: holding.totalValue,
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: _getColorForIndex(holdings.indexOf(holding)),
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: holdings.map((holding) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForIndex(holdings.indexOf(holding)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    holding.symbol,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab(InvestmentPortfolio portfolio) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceChart(portfolio),
          const SizedBox(height: 24),
          _buildStatistics(portfolio),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(InvestmentPortfolio portfolio) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수익률 추이',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateMockData(),
                    isCurved: true,
                    gradient: AppTheme.modernGradient,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.modernBlue.withOpacity(0.3),
                          AppTheme.modernBlue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(InvestmentPortfolio portfolio) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '통계',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: '투자금',
            value: currencyFormat.format(portfolio.totalCost),
          ),
          _StatRow(
            label: '현재가치',
            value: currencyFormat.format(portfolio.totalValue),
          ),
          _StatRow(
            label: '총 수익',
            value: currencyFormat.format(portfolio.totalReturn),
            valueColor:
                portfolio.totalReturn >= 0 ? Colors.green : Colors.red,
          ),
          _StatRow(
            label: '수익률',
            value: '${portfolio.returnRate.toStringAsFixed(2)}%',
            valueColor: portfolio.returnRate >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTradesTab(InvestmentPortfolio portfolio) {
    return StreamBuilder(
      stream: _investmentService.getPortfolioTrades(widget.portfolioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trades = snapshot.data ?? [];

        if (trades.isEmpty) {
          return const Center(
            child: Text('거래 내역이 없습니다'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            final currencyFormat =
                NumberFormat.currency(symbol: '\$', decimalDigits: 2);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: trade.tradeType == TradeType.buy
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    trade.tradeType == TradeType.buy
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: trade.tradeType == TradeType.buy
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  '${trade.assetName} (${trade.assetSymbol})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(trade.tradeDate),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(trade.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${trade.quantity} @ ${currencyFormat.format(trade.price)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHoldings() {
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
              Icons.add_chart,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '보유 자산이 없습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 자산을 추가해보세요',
            style: TextStyle(color: AppTheme.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateMockData() {
    return List.generate(30, (index) {
      return FlSpot(index.toDouble(), 100 + (index * 2) + (index % 5 * 3));
    });
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.modernBlue,
      AppTheme.modernPurple,
      AppTheme.modernPink,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  void _showPortfolioOptions(
      BuildContext context, InvestmentPortfolio portfolio) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                // Edit portfolio
              },
            ),
            ListTile(
              leading: Icon(
                portfolio.isPublic ? Icons.lock : Icons.public,
              ),
              title: Text(portfolio.isPublic ? '비공개로 전환' : '공개로 전환'),
              onTap: () async {
                Navigator.pop(context);
                await _investmentService.updatePortfolio(
                  portfolio.copyWith(isPublic: !portfolio.isPublic),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, portfolio);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InvestmentPortfolio portfolio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포트폴리오 삭제'),
        content: const Text('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await _investmentService.deletePortfolio(portfolio.portfolioId);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog(BuildContext context) {
    context.push('/investment/portfolio/${widget.portfolioId}/add-asset');
  }
}

class _HoldingCard extends StatelessWidget {
  final AssetHolding holding;

  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isProfit = holding.unrealizedGain >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAssetColor().withOpacity(0.1),
          child: Text(
            holding.symbol.substring(0, 1),
            style: TextStyle(
              color: _getAssetColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          holding.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${holding.quantity} ${holding.assetType.koreanName}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(holding.totalValue),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '${isProfit ? '+' : ''}${currencyFormat.format(holding.unrealizedGain)} (${holding.unrealizedGainPercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                color: isProfit ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to asset detail
        },
      ),
    );
  }

  Color _getAssetColor() {
    switch (holding.assetType) {
      case AssetType.stock:
        return AppTheme.modernBlue;
      case AssetType.crypto:
        return AppTheme.modernPurple;
      case AssetType.etf:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.lightTextSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
