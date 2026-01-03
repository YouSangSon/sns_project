import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class CreatePortfolioScreen extends ConsumerStatefulWidget {
  const CreatePortfolioScreen({super.key});

  @override
  ConsumerState<CreatePortfolioScreen> createState() =>
      _CreatePortfolioScreenState();
}

class _CreatePortfolioScreenState extends ConsumerState<CreatePortfolioScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCurrency = 'KRW';
  bool _isPublic = false;
  bool _isCreating = false;

  final _currencies = ['KRW', 'USD', 'EUR', 'JPY'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createPortfolio() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포트폴리오 이름을 입력해주세요')),
      );
      return;
    }

    setState(() => _isCreating = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포트폴리오가 생성되었습니다')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('새 포트폴리오'),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createPortfolio,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('생성'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: '포트폴리오 이름',
              hintText: '예: 장기 투자 포트폴리오',
              controller: _nameController,
              prefixIcon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: '설명 (선택)',
              hintText: '포트폴리오에 대한 설명을 입력하세요',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            const Text(
              '통화',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('공개 포트폴리오'),
              subtitle: Text(
                _isPublic
                    ? '다른 사용자들이 이 포트폴리오를 볼 수 있습니다'
                    : '나만 볼 수 있습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
