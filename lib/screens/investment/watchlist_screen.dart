import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/investment/watchlist.dart';
import '../../services/investment_service.dart';
import '../../services/realtime_price_service.dart';
import '../../services/market_data_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final InvestmentService _investmentService = InvestmentService();
  final RealtimePriceService _realtimePriceService = RealtimePriceService();
  final MarketDataService _marketDataService = MarketDataService();

  final Map<String, Stream<PriceUpdate>> _priceStreams = {};

  @override
  void dispose() {
    // Cleanup subscriptions
    for (var symbol in _priceStreams.keys) {
      _realtimePriceService.unsubscribeFromStock(symbol);
      _realtimePriceService.unsubscribeFromCrypto(symbol);
    }
    super.dispose();
  }

  Stream<PriceUpdate> _subscribeToPriceUpdates(
      String symbol, AssetType assetType) {
    if (!_priceStreams.containsKey(symbol)) {
      if (assetType == AssetType.crypto) {
        _priceStreams[symbol] =
            _realtimePriceService.subscribeToCrypto(symbol);
      } else {
        _priceStreams[symbol] = _realtimePriceService.subscribeToStock(symbol);
      }
    }
    return _priceStreams[symbol]!;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관심 종목'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to asset search
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('로그인이 필요합니다'));
          }

          return StreamBuilder<List<WatchList>>(
            stream: _investmentService.getUserWatchlist(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('오류: ${snapshot.error}'));
              }

              final watchlist = snapshot.data ?? [];

              if (watchlist.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  final item = watchlist[index];
                  return _WatchlistCard(
                    item: item,
                    priceStream: _subscribeToPriceUpdates(
                      item.assetSymbol,
                      item.assetType,
                    ),
                    onTap: () {
                      context.push(
                        '/investment/asset/${item.assetSymbol}',
                        extra: item.assetType,
                      );
                    },
                    onDelete: () async {
                      await _investmentService
                          .removeFromWatchlist(item.watchlistId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('관심 종목에서 제거되었습니다'),
                          ),
                        );
                      }
                    },
                    onSetAlert: () {
                      _showAlertDialog(context, item);
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류: $error')),
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
              Icons.star_border,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '관심 종목이 없습니다',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '관심있는 종목을 추가해보세요',
            style: TextStyle(color: AppTheme.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context, WatchList item) {
    final targetPriceController = TextEditingController(
      text: item.targetPrice?.toString() ?? '',
    );
    AlertCondition? selectedCondition = item.alertCondition;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${item.assetSymbol} 가격 알림'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AlertCondition>(
                  value: selectedCondition,
                  decoration: const InputDecoration(
                    labelText: '조건',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    AlertCondition.above,
                    AlertCondition.below,
                    AlertCondition.change,
                  ].map((condition) {
                    String label;
                    switch (condition) {
                      case AlertCondition.above:
                        label = '이상';
                        break;
                      case AlertCondition.below:
                        label = '이하';
                        break;
                      case AlertCondition.change:
                        label = '변동률';
                        break;
                    }
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCondition = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetPriceController,
                  decoration: const InputDecoration(
                    labelText: '목표 가격',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCondition != null &&
                    targetPriceController.text.isNotEmpty) {
                  final updatedItem = item.copyWith(
                    targetPrice: double.tryParse(targetPriceController.text),
                    alertCondition: selectedCondition,
                    alertEnabled: true,
                  );

                  await _investmentService.updateWatchlistItem(updatedItem);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('가격 알림이 설정되었습니다')),
                    );
                  }
                }
              },
              child: const Text('설정'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final WatchList item;
  final Stream<PriceUpdate> priceStream;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSetAlert;

  const _WatchlistCard({
    required this.item,
    required this.priceStream,
    required this.onTap,
    required this.onDelete,
    required this.onSetAlert,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<PriceUpdate>(
            stream: priceStream,
            builder: (context, snapshot) {
              final priceUpdate = snapshot.data;
              final currentPrice = priceUpdate?.price ?? item.addedPrice;
              final priceChange = currentPrice - item.addedPrice;
              final priceChangePercent =
                  (priceChange / item.addedPrice) * 100;
              final isPositive = priceChange >= 0;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getAssetColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.assetSymbol.substring(0, 1),
                          style: TextStyle(
                            color: _getAssetColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.assetSymbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (snapshot.connectionState ==
                                    ConnectionState.active)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              item.assetName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(currentPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 14,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                              Text(
                                '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (item.alertEnabled && item.targetPrice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '알림: ${currencyFormat.format(item.targetPrice)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onSetAlert,
                        icon: const Icon(Icons.alarm, size: 16),
                        label: const Text('알림 설정'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('삭제'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getAssetColor() {
    switch (item.assetType) {
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
