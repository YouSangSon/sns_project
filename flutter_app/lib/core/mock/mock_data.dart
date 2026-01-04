import 'dart:math';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/feed/domain/entities/post_entity.dart';

/// Mock 데이터 제공자
/// enable_mock_data가 true일 때 실제 API 대신 사용됩니다.
class MockData {
  static final Random _random = Random();

  // ========== Users ==========

  static List<UserEntity> get users => [
        UserEntity(
          id: '1',
          email: 'alice@example.com',
          username: 'alice',
          displayName: 'Alice Johnson',
          bio: 'Travel enthusiast 🌍 | Coffee lover ☕',
          profileImageUrl: 'https://i.pravatar.cc/150?img=1',
          followersCount: 1234,
          followingCount: 567,
          postsCount: 89,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        ),
        UserEntity(
          id: '2',
          email: 'bob@example.com',
          username: 'bob',
          displayName: 'Bob Smith',
          bio: 'Photographer 📷 | Nature lover 🌿',
          profileImageUrl: 'https://i.pravatar.cc/150?img=2',
          followersCount: 5678,
          followingCount: 890,
          postsCount: 234,
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
        ),
        UserEntity(
          id: '3',
          email: 'charlie@example.com',
          username: 'charlie',
          displayName: 'Charlie Davis',
          bio: 'Foodie 🍕 | Chef in training 👨‍🍳',
          profileImageUrl: 'https://i.pravatar.cc/150?img=3',
          followersCount: 3456,
          followingCount: 234,
          postsCount: 156,
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
        ),
        UserEntity(
          id: '4',
          email: 'test@example.com',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'This is a test account for development',
          profileImageUrl: 'https://i.pravatar.cc/150?img=4',
          followersCount: 100,
          followingCount: 50,
          postsCount: 25,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

  /// 현재 로그인된 사용자 (테스트 계정)
  static UserEntity get currentUser => users[3];

  /// ID로 사용자 찾기
  static UserEntity? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== Posts ==========

  static List<PostEntity> get posts => [
        PostEntity(
          id: '1',
          userId: '1',
          caption: 'Beautiful sunset at the beach 🌅 #sunset #beach #nature',
          imageUrls: [
            'https://picsum.photos/seed/1/800/600',
            'https://picsum.photos/seed/2/800/600',
          ],
          likesCount: 234,
          commentsCount: 12,
          isLiked: false,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          user: users[0],
        ),
        PostEntity(
          id: '2',
          userId: '2',
          caption: 'Morning coffee ritual ☕️ #coffee #morning',
          imageUrls: [
            'https://picsum.photos/seed/3/800/600',
          ],
          likesCount: 567,
          commentsCount: 34,
          isLiked: true,
          isBookmarked: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          user: users[1],
        ),
        PostEntity(
          id: '3',
          userId: '3',
          caption:
              'Homemade pizza night 🍕 Recipe in bio! #foodie #homemade #pizza',
          imageUrls: [
            'https://picsum.photos/seed/4/800/600',
            'https://picsum.photos/seed/5/800/600',
            'https://picsum.photos/seed/6/800/600',
          ],
          likesCount: 892,
          commentsCount: 67,
          isLiked: false,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          user: users[2],
        ),
        PostEntity(
          id: '4',
          userId: '1',
          caption: 'Exploring new trails 🥾 #hiking #adventure',
          imageUrls: [
            'https://picsum.photos/seed/7/800/600',
          ],
          likesCount: 445,
          commentsCount: 23,
          isLiked: true,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          user: users[0],
        ),
        PostEntity(
          id: '5',
          userId: '2',
          caption: 'Golden hour photography 📸 #photography #goldenhour',
          imageUrls: [
            'https://picsum.photos/seed/8/800/600',
            'https://picsum.photos/seed/9/800/600',
          ],
          likesCount: 1023,
          commentsCount: 89,
          isLiked: false,
          isBookmarked: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          user: users[1],
        ),
      ];

  /// 페이지네이션된 게시물 가져오기
  static List<PostEntity> getPostsByPage({
    required int page,
    required int limit,
  }) {
    final allPosts = posts;
    final startIndex = page * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= allPosts.length) {
      return [];
    }

    return allPosts.sublist(
      startIndex,
      endIndex > allPosts.length ? allPosts.length : endIndex,
    );
  }

  /// 사용자별 게시물
  static List<PostEntity> getPostsByUserId(String userId) {
    return posts.where((post) => post.userId == userId).toList();
  }

  // ========== Mock Response Models ==========

  /// 로그인 응답
  static Map<String, dynamic> get loginResponse => {
        'access_token': 'mock-access-token-${_random.nextInt(10000)}',
        'refresh_token': 'mock-refresh-token-${_random.nextInt(10000)}',
        'user': {
          'id': currentUser.id,
          'email': currentUser.email,
          'user_name': currentUser.username,
          'display_name': currentUser.displayName,
          'bio': currentUser.bio,
          'profile_image_url': currentUser.profileImageUrl,
          'followers_count': currentUser.followersCount,
          'following_count': currentUser.followingCount,
          'posts_count': currentUser.postsCount,
          'created_at': currentUser.createdAt.toIso8601String(),
        },
      };

  /// 회원가입 응답
  static Map<String, dynamic> registerResponse({
    required String email,
    required String username,
  }) =>
      {
        'access_token': 'mock-access-token-${_random.nextInt(10000)}',
        'refresh_token': 'mock-refresh-token-${_random.nextInt(10000)}',
        'user': {
          'id': 'new-user-${_random.nextInt(10000)}',
          'email': email,
          'user_name': username,
          'display_name': username,
          'bio': '',
          'profile_image_url': 'https://i.pravatar.cc/150?img=${_random.nextInt(70)}',
          'followers_count': 0,
          'following_count': 0,
          'posts_count': 0,
          'created_at': DateTime.now().toIso8601String(),
        },
      };

  // ========== Utility Methods ==========

  /// 네트워크 지연 시뮬레이션
  static Future<void> delay({
    int minMilliseconds = 300,
    int maxMilliseconds = 1000,
  }) async {
    final delay = minMilliseconds +
        _random.nextInt(maxMilliseconds - minMilliseconds);
    await Future.delayed(Duration(milliseconds: delay));
  }

  /// 랜덤 에러 시뮬레이션 (10% 확률)
  static void randomError() {
    if (_random.nextInt(10) == 0) {
      throw Exception('Mock: Random network error');
    }
  }
}
