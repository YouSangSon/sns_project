import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/investment/asset_holding.dart';
import '../../services/market_data_service.dart';
import '../../services/realtime_price_service.dart';
import '../../services/investment_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  final String symbol;
  final AssetType assetType;

  const AssetDetailScreen({
    super.key,
    required this.symbol,
    required this.assetType,
  });

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  final MarketDataService _marketDataService = MarketDataService();
  final RealtimePriceService _realtimePriceService = RealtimePriceService();
  final InvestmentService _investmentService = InvestmentService();

  late TabController _tabController;
  MarketData? _currentData;
  bool _isLoading = true;
  bool _isInWatchlist = false;

  Stream<PriceUpdate>? _priceStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
    _subscribeToRealtimePrice();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (widget.assetType == AssetType.crypto) {
      _realtimePriceService.unsubscribeFromCrypto(widget.symbol);
    } else {
      _realtimePriceService.unsubscribeFromStock(widget.symbol);
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load market data
      if (widget.assetType == AssetType.crypto) {
        _currentData = await _marketDataService.getCryptoQuote(widget.symbol);
      } else {
        _currentData = await _marketDataService.getStockQuote(widget.symbol);
      }

      // Check if in watchlist
      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.value;

      if (currentUser != null) {
        _isInWatchlist = await _investmentService.isInWatchlist(
          currentUser.uid,
          widget.symbol,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 오류: $e')),
        );
      }
    }
  }

  void _subscribeToRealtimePrice() {
    if (widget.assetType == AssetType.crypto) {
      _priceStream = _realtimePriceService.subscribeToCrypto(widget.symbol);
    } else {
      _priceStream = _realtimePriceService.subscribeToStock(widget.symbol);
    }
  }

  Future<void> _toggleWatchlist() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    try {
      if (_isInWatchlist) {
        // Remove from watchlist
        final watchlist = await _investmentService
            .getUserWatchlist(currentUser.uid)
            .first;
        final item = watchlist.firstWhere(
          (w) => w.assetSymbol == widget.symbol,
        );
        await _investmentService.removeFromWatchlist(item.watchlistId);
      } else {
        // Add to watchlist
        final watchlistItem = WatchList(
          watchlistId: '',
          userId: currentUser.uid,
          assetSymbol: widget.symbol,
          assetName: _currentData?.name ?? widget.symbol,
          assetType: widget.assetType,
          addedPrice: _currentData?.price ?? 0,
          addedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _investmentService.addToWatchlist(watchlistItem);
      }

      setState(() {
        _isInWatchlist = !_isInWatchlist;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWatchlist ? '관심 종목에 추가되었습니다' : '관심 종목에서 제거되었습니다',
            ),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: Icon(
              _isInWatchlist ? Icons.star : Icons.star_border,
              color: _isInWatchlist ? Colors.amber : null,
            ),
            onPressed: _toggleWatchlist,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share asset
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPriceHeader(),
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.modernBlue,
                  tabs: const [
                    Tab(text: '차트'),
                    Tab(text: '게시물'),
                    Tab(text: '통계'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChartTab(),
                      _buildPostsTab(),
                      _buildStatsTab(),
                    ],
                  ),
                ),
              ],
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

  Widget _buildPriceHeader() {
    return StreamBuilder<PriceUpdate>(
      stream: _priceStream,
      initialData: _currentData != null
          ? PriceUpdate(
              symbol: widget.symbol,
              price: _currentData!.price,
              change: _currentData!.change,
              changePercent: _currentData!.changePercent,
              volume: _currentData!.volume,
              timestamp: _currentData!.timestamp,
            )
          : null,
      builder: (context, snapshot) {
        final priceUpdate = snapshot.data;
        final isPositive = (priceUpdate?.change ?? 0) >= 0;
        final currencyFormat =
            NumberFormat.currency(symbol: '\$', decimalDigits: 2);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPositive
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.red[400]!, Colors.red[600]!],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentData?.name ?? widget.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.assetType.koreanName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (snapshot.connectionState == ConnectionState.active)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(priceUpdate?.price ?? 0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${currencyFormat.format(priceUpdate?.change ?? 0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${(priceUpdate?.changePercent ?? 0).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PriceInfoItem(
                    label: '시가',
                    value: currencyFormat.format(_currentData?.open ?? 0),
                  ),
                  _PriceInfoItem(
                    label: '고가',
                    value: currencyFormat.format(_currentData?.high ?? 0),
                  ),
                  _PriceInfoItem(
                    label: '저가',
                    value: currencyFormat.format(_currentData?.low ?? 0),
                  ),
                  _PriceInfoItem(
                    label: '거래량',
                    value: NumberFormat.compact()
                        .format(_currentData?.volume ?? 0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Time period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1D', '1W', '1M', '3M', '1Y', 'ALL'].map((period) {
              return ChoiceChip(
                label: Text(period),
                selected: period == '1D',
                onSelected: (selected) {
                  // Load data for period
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Candlestick Chart
          Container(
            height: 400,
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
            child: Candlesticks(
              candles: _generateMockCandles(),
            ),
          ),

          const SizedBox(height: 24),

          // Buy/Sell Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to buy
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('매수'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to sell
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('매도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return StreamBuilder(
      stream: _investmentService.getPostsByAsset(widget.symbol, limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(
            child: Text('이 종목에 대한 게시물이 없습니다'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(posts[index].content, maxLines: 2),
                subtitle: Text(posts[index].username),
                trailing: Text(posts[index].postType.koreanName),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시장 통계',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: '현재가',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(_currentData?.price ?? 0),
          ),
          _StatRow(
            label: '시가',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(_currentData?.open ?? 0),
          ),
          _StatRow(
            label: '고가',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(_currentData?.high ?? 0),
          ),
          _StatRow(
            label: '저가',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(_currentData?.low ?? 0),
          ),
          _StatRow(
            label: '전일 종가',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(_currentData?.previousClose ?? 0),
          ),
          _StatRow(
            label: '거래량',
            value: NumberFormat.decimalPattern()
                .format(_currentData?.volume ?? 0),
          ),
        ],
      ),
    );
  }

  List<Candle> _generateMockCandles() {
    final now = DateTime.now();
    return List.generate(50, (index) {
      final date = now.subtract(Duration(days: 50 - index));
      final open = 100.0 + (index * 2) + (index % 5 * 3);
      final close = open + (index % 2 == 0 ? 5 : -3);
      final high = [open, close].reduce((a, b) => a > b ? a : b) + 2;
      final low = [open, close].reduce((a, b) => a < b ? a : b) - 2;

      return Candle(
        date: date,
        high: high,
        low: low,
        open: open,
        close: close,
        volume: 1000000.0 + (index * 10000),
      );
    });
  }
}

class _PriceInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _PriceInfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
