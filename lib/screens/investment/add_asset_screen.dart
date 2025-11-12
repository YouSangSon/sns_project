import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/investment/asset_holding.dart';
import '../../models/investment/trade_history.dart';
import '../../services/investment_service.dart';
import '../../services/market_data_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const AddAssetScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  final _reasonController = TextEditingController();

  final InvestmentService _investmentService = InvestmentService();
  final MarketDataService _marketDataService = MarketDataService();

  AssetType _selectedAssetType = AssetType.stock;
  TradeType _selectedTradeType = TradeType.buy;
  DateTime _selectedDate = DateTime.now();
  bool _isSearching = false;
  bool _isLoading = false;
  List<Map<String, String>> _searchResults = [];

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _searchAsset(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, String>> results;
      if (_selectedAssetType == AssetType.crypto) {
        results = await _marketDataService.searchCrypto(query);
      } else {
        results = await _marketDataService.searchStocks(query);
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 오류: $e')),
        );
      }
    }
  }

  Future<void> _fetchCurrentPrice() async {
    if (_symbolController.text.isEmpty) return;

    try {
      MarketData? marketData;
      if (_selectedAssetType == AssetType.crypto) {
        marketData = await _marketDataService
            .getCryptoQuote(_symbolController.text);
      } else {
        marketData =
            await _marketDataService.getStockQuote(_symbolController.text);
      }

      if (marketData != null) {
        setState(() {
          _priceController.text = marketData.price.toStringAsFixed(2);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가격 조회 오류: $e')),
        );
      }
    }
  }

  Future<void> _submitTrade() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      final fee = double.parse(_feeController.text);

      // Create trade record
      final trade = TradeHistory(
        tradeId: '',
        userId: currentUser.uid,
        portfolioId: widget.portfolioId,
        assetSymbol: _symbolController.text.toUpperCase(),
        assetName: _nameController.text,
        assetType: _selectedAssetType,
        tradeType: _selectedTradeType,
        quantity: quantity,
        price: price,
        totalAmount: quantity * price,
        fee: fee,
        tradeDate: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        isSharedPublicly: false,
        createdAt: DateTime.now(),
      );

      await _investmentService.addTrade(trade);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('거래가 기록되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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
        title: const Text('거래 기록'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitTrade,
              child: const Text(
                '저장',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trade Type Toggle
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<TradeType>(
                    segments: const [
                      ButtonSegment(
                        value: TradeType.buy,
                        label: Text('매수'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: TradeType.sell,
                        label: Text('매도'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {_selectedTradeType},
                    onSelectionChanged: (Set<TradeType> newSelection) {
                      setState(() {
                        _selectedTradeType = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Asset Type
            DropdownButtonFormField<AssetType>(
              value: _selectedAssetType,
              decoration: const InputDecoration(
                labelText: '자산 유형',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: AssetType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.koreanName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAssetType = value;
                    _searchResults = [];
                    _symbolController.clear();
                    _nameController.clear();
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Symbol Search
            TextFormField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: '종목 코드',
                hintText: '예: AAPL, BTC',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchCurrentPrice,
                  tooltip: '현재가 가져오기',
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '종목 코드를 입력하세요';
                }
                return null;
              },
              onChanged: (value) {
                _searchAsset(value);
              },
            ),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      title: Text(result['symbol'] ?? ''),
                      subtitle: Text(result['name'] ?? ''),
                      onTap: () {
                        setState(() {
                          _symbolController.text = result['symbol'] ?? '';
                          _nameController.text = result['name'] ?? '';
                          _searchResults = [];
                        });
                        _fetchCurrentPrice();
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Asset Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '종목 이름',
                hintText: '예: Apple Inc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '종목 이름을 입력하세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Quantity and Price
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: '수량',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '수량 입력';
                      }
                      if (double.tryParse(value) == null) {
                        return '숫자만';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: '가격',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '가격 입력';
                      }
                      if (double.tryParse(value) == null) {
                        return '숫자만';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Fee
            TextFormField(
              controller: _feeController,
              decoration: const InputDecoration(
                labelText: '수수료',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return '숫자만 입력하세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('거래 일시'),
              subtitle: Text(_selectedDate.toString().split('.')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),

            const Divider(height: 32),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                hintText: '거래에 대한 메모를 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Investment Reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: '투자 논리 (선택)',
                hintText: '왜 이 종목을 매수/매도 하셨나요?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lightbulb),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Total Amount Display
            if (_quantityController.text.isNotEmpty &&
                _priceController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.modernBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.modernBlue),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('총 금액'),
                        Text(
                          '\$${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_feeController.text.isNotEmpty &&
                        double.tryParse(_feeController.text) != null &&
                        double.parse(_feeController.text) > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('수수료 포함'),
                          Text(
                            '\$${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0) + (double.tryParse(_feeController.text) ?? 0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.modernBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
