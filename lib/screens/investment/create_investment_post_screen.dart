import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/investment/investment_post.dart';
import '../../services/investment_service.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

class CreateInvestmentPostScreen extends ConsumerStatefulWidget {
  const CreateInvestmentPostScreen({super.key});

  @override
  ConsumerState<CreateInvestmentPostScreen> createState() =>
      _CreateInvestmentPostScreenState();
}

class _CreateInvestmentPostScreenState
    extends ConsumerState<CreateInvestmentPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _symbolsController = TextEditingController();
  final _targetPriceController = TextEditingController();

  final InvestmentService _investmentService = InvestmentService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  InvestmentPostType _selectedType = InvestmentPostType.idea;
  MarketSentiment? _selectedSentiment;
  String? _timeHorizon;
  List<String> _selectedImagePaths = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _symbolsController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImagePaths.clear();
          for (var image in images.take(4)) {
            _selectedImagePaths.add(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }

  Future<void> _createPost() async {
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
      // Upload images if any
      List<String> imageUrls = [];
      if (_selectedImagePaths.isNotEmpty) {
        imageUrls = await _storageService.uploadPostImages(
          _selectedImagePaths,
          currentUser.uid,
        );
      }

      // Extract symbols and hashtags
      final symbols = _symbolsController.text
          .split(',')
          .map((s) => s.trim().toUpperCase())
          .where((s) => s.isNotEmpty)
          .toList();

      final hashtags = RegExp(r'#\w+')
          .allMatches(_contentController.text)
          .map((m) => m.group(0)!.substring(1))
          .toList();

      // Create post
      final post = InvestmentPost(
        postId: '',
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        postType: _selectedType,
        content: _contentController.text.trim(),
        relatedAssets: symbols,
        imageUrls: imageUrls,
        sentiment: _selectedSentiment,
        targetPrice: _targetPriceController.text.isEmpty
            ? null
            : double.tryParse(_targetPriceController.text),
        timeHorizon: _timeHorizon,
        hashtags: hashtags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _investmentService.createInvestmentPost(post);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 작성되었습니다')),
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
        title: const Text('투자 게시물'),
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
              onPressed: _createPost,
              child: const Text(
                '게시',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Post Type Selection
            const Text(
              '게시물 유형',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InvestmentPostType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.koreanName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                  selectedColor: AppTheme.modernBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                hintText: '투자 아이디어, 분석, 의견을 공유하세요...\n#해시태그를 사용하세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력하세요';
                }
                if (value.trim().length < 10) {
                  return '최소 10자 이상 입력하세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Related Symbols
            TextFormField(
              controller: _symbolsController,
              decoration: const InputDecoration(
                labelText: '관련 종목 (선택)',
                hintText: '예: AAPL, TSLA, BTC',
                helperText: '쉼표로 구분하여 입력',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 16),

            // Sentiment Selection
            const Text(
              '시장 감정 (선택)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: MarketSentiment.values.map((sentiment) {
                final isSelected = _selectedSentiment == sentiment;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedSentiment =
                              isSelected ? null : sentiment;
                        });
                      },
                      icon: Text(
                        sentiment.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      label: Text(sentiment.koreanName),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            isSelected ? AppTheme.modernBlue.withOpacity(0.1) : null,
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.modernBlue
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Investment Idea Specific Fields
            if (_selectedType == InvestmentPostType.idea) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetPriceController,
                decoration: const InputDecoration(
                  labelText: '목표가 (선택)',
                  hintText: '예: 150.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _timeHorizon,
                decoration: const InputDecoration(
                  labelText: '투자 기간 (선택)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: const [
                  DropdownMenuItem(value: 'short', child: Text('단기 (< 3개월)')),
                  DropdownMenuItem(value: 'medium', child: Text('중기 (3-12개월)')),
                  DropdownMenuItem(value: 'long', child: Text('장기 (> 12개월)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _timeHorizon = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            // Images
            if (_selectedImagePaths.isEmpty)
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('차트 및 이미지 추가'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedImagePaths.length}개 이미지 선택됨',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.edit),
                        label: const Text('변경'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImagePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImagePaths[index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImagePaths.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        '작성 팁',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• 근거있는 분석을 공유하세요\n'
                    '• 차트나 데이터를 첨부하면 좋아요\n'
                    '• #해시태그로 주제를 분류하세요\n'
                    '• 다른 투자자들과 활발히 소통하세요',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
