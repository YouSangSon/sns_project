import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../models/story_model.dart';
import '../screens/stories/stories_screen.dart';

class StoryCircle extends StatelessWidget {
  final UserModel user;
  final List<StoryModel> stories;
  final bool isOwnStory;
  final bool hasNewStory;
  final int userIndex;
  final List<Map<String, dynamic>> allUserStories;

  const StoryCircle({
    super.key,
    required this.user,
    required this.stories,
    this.isOwnStory = false,
    this.hasNewStory = true,
    required this.userIndex,
    required this.allUserStories,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoriesScreen(
              userStories: allUserStories,
              initialIndex: userIndex,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                // Story circle with gradient border
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasNewStory
                        ? const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF405DE6),
                              Color(0xFF5851DB),
                              Color(0xFF833AB4),
                              Color(0xFFC13584),
                              Color(0xFFE1306C),
                              Color(0xFFFD1D1D),
                            ],
                          )
                        : null,
                    border: !hasNewStory
                        ? Border.all(color: Colors.grey[300]!, width: 2)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: user.photoUrl.isNotEmpty
                            ? CachedNetworkImageProvider(user.photoUrl)
                            : null,
                        child: user.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                    ),
                  ),
                ),

                // Add button for own story
                if (isOwnStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                isOwnStory ? 'Your story' : user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
