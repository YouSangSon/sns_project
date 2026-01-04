/// 테스트용 Mock 데이터
class TestData {
  // User Data
  static const String testUserId = 'test-user-id-123';
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123!@#';
  static const String testUsername = 'testuser';
  static const String testDisplayName = 'Test User';
  static const String testBio = 'This is a test bio';
  static const String testProfileImage = 'https://example.com/avatar.jpg';

  // Post Data
  static const String testPostId = 'test-post-id-456';
  static const String testPostCaption = 'This is a test post';
  static const List<String> testPostImages = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
  ];

  // Comment Data
  static const String testCommentId = 'test-comment-id-789';
  static const String testCommentText = 'This is a test comment';

  // Token Data
  static const String testAccessToken = 'test-access-token-xyz';
  static const String testRefreshToken = 'test-refresh-token-abc';

  // API Response
  static Map<String, dynamic> get mockUserJson => {
        'id': testUserId,
        'email': testEmail,
        'user_name': testUsername,
        'display_name': testDisplayName,
        'bio': testBio,
        'profile_image_url': testProfileImage,
        'followers_count': 100,
        'following_count': 50,
        'posts_count': 25,
        'created_at': '2024-01-01T00:00:00Z',
      };

  static Map<String, dynamic> get mockLoginResponseJson => {
        'access_token': testAccessToken,
        'refresh_token': testRefreshToken,
        'user': mockUserJson,
      };

  static Map<String, dynamic> get mockPostJson => {
        'id': testPostId,
        'user_id': testUserId,
        'caption': testPostCaption,
        'image_urls': testPostImages,
        'likes_count': 10,
        'comments_count': 5,
        'is_liked': false,
        'is_bookmarked': false,
        'created_at': '2024-01-01T00:00:00Z',
        'user': mockUserJson,
      };

  static Map<String, dynamic> get mockCommentJson => {
        'id': testCommentId,
        'post_id': testPostId,
        'user_id': testUserId,
        'text': testCommentText,
        'created_at': '2024-01-01T00:00:00Z',
        'user': mockUserJson,
      };

  static List<Map<String, dynamic>> get mockPostsListJson => [
        mockPostJson,
        {
          ...mockPostJson,
          'id': 'test-post-id-2',
          'caption': 'Second test post',
        },
      ];
}
