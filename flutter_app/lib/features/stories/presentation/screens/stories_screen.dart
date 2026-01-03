import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class StoriesScreen extends ConsumerStatefulWidget {
  final String userId;

  const StoriesScreen({super.key, required this.userId});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  int _currentIndex = 0;
  final _pageController = PageController();

  // Mock stories
  final List<Map<String, dynamic>> _stories = [
    {
      'imageUrl': 'https://picsum.photos/seed/story1/400/700',
      'username': 'devuser',
      'userPhotoUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
      'timeAgo': '2h',
    },
    {
      'imageUrl': 'https://picsum.photos/seed/story2/400/700',
      'username': 'devuser',
      'userPhotoUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
      'timeAgo': '4h',
    },
    {
      'imageUrl': 'https://picsum.photos/seed/story3/400/700',
      'username': 'devuser',
      'userPhotoUrl': 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
      'timeAgo': '6h',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Story Content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTapUp: (details) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    if (details.globalPosition.dx < screenWidth / 2) {
                      _previousStory();
                    } else {
                      _nextStory();
                    }
                  },
                  child: CachedImage(
                    imageUrl: _stories[index]['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),

            // Progress Indicators
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(_stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 2,
                      decoration: BoxDecoration(
                        color: index <= _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  const CircleAvatar(
                    imageUrl:
                        'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stories[_currentIndex]['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stories[_currentIndex]['timeAgo'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),

            // Reply Input
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Reply...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.white),
                    onPressed: () {},
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
