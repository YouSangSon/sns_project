/// API 엔드포인트 정의
abstract class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Users
  static const String users = '/users';
  static String user(String id) => '/users/$id';
  static String userProfile(String id) => '/users/$id/profile';
  static String userPosts(String id) => '/users/$id/posts';
  static const String searchUsers = '/users/search';
  static String follow(String id) => '/users/$id/follow';
  static String unfollow(String id) => '/users/$id/unfollow';

  // Posts
  static const String posts = '/posts';
  static const String feed = '/posts/feed';
  static String post(String id) => '/posts/$id';
  static String likePost(String id) => '/posts/$id/like';
  static String unlikePost(String id) => '/posts/$id/unlike';
  static String postComments(String id) => '/posts/$id/comments';

  // Comments
  static const String comments = '/comments';
  static String comment(String id) => '/comments/$id';

  // Messages
  static const String conversations = '/messages/conversations';
  static String conversation(String id) => '/messages/conversations/$id';
  static String messages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static const String sendMessage = '/messages';
  static String markAsRead(String id) => '/messages/conversations/$id/read';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Portfolios (Investment)
  static const String portfolios = '/portfolios';
  static String portfolio(String id) => '/portfolios/$id';
  static String portfolioHoldings(String id) => '/portfolios/$id/holdings';

  // Stories
  static const String stories = '/stories';
  static String story(String id) => '/stories/$id';
  static String userStories(String userId) => '/stories/user/$userId';
}
