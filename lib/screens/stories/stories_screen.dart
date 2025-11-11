import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';

class StoriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> userStories;
  final int initialIndex;

  const StoriesScreen({
    super.key,
    required this.userStories,
    this.initialIndex = 0,
  });

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late PageController _pageController;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextUser() {
    if (_currentUserIndex < widget.userStories.length - 1) {
      _currentUserIndex++;
      _currentStoryIndex = 0;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All stories viewed, go back
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_currentUserIndex > 0) {
      _currentUserIndex--;
      _currentStoryIndex = 0;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.userStories.length,
      onPageChanged: (index) {
        setState(() {
          _currentUserIndex = index;
          _currentStoryIndex = 0;
        });
      },
      itemBuilder: (context, index) {
        final userStoryData = widget.userStories[index];
        final user = userStoryData['user'] as UserModel;
        final stories = userStoryData['stories'] as List<StoryModel>;

        return StoryView(
          user: user,
          stories: stories,
          onNext: _nextUser,
          onPrevious: _previousUser,
          onStoryIndexChanged: (storyIndex) {
            setState(() {
              _currentStoryIndex = storyIndex;
            });
          },
        );
      },
    );
  }
}

class StoryView extends StatefulWidget {
  final UserModel user;
  final List<StoryModel> stories;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<int> onStoryIndexChanged;

  const StoryView({
    super.key,
    required this.user,
    required this.stories,
    required this.onNext,
    required this.onPrevious,
    required this.onStoryIndexChanged,
  });

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin {
  late PageController _storyPageController;
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _storyPageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _startStory();
    _markAsViewed();
  }

  @override
  void dispose() {
    _storyPageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward();
  }

  void _markAsViewed() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();

    if (authProvider.user != null) {
      await storyProvider.viewStory(
        widget.stories[_currentIndex].storyId,
        authProvider.user!.uid,
      );
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _storyPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
      _markAsViewed();
      widget.onStoryIndexChanged(_currentIndex);
    } else {
      widget.onNext();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _storyPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
      widget.onStoryIndexChanged(_currentIndex);
    } else {
      widget.onPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _storyPageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];

                return Center(
                  child: CachedNetworkImage(
                    imageUrl: story.mediaUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
                );
              },
            ),

            // Progress indicators
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          double progress = 0;
                          if (index < _currentIndex) {
                            progress = 1;
                          } else if (index == _currentIndex) {
                            progress = _progressController.value;
                          }
                          return LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.user.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(widget.user.photoUrl)
                        : null,
                    child: widget.user.photoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    _getTimeAgo(widget.stories[_currentIndex].createdAt),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom interaction area
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Send message',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
