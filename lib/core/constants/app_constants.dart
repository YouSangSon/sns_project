class AppConstants {
  // App Info
  static const String appName = 'SNS App';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followsCollection = 'follows';
  static const String storiesCollection = 'stories';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String storyImagesPath = 'story_images';
  static const String messageMediaPath = 'message_media';

  // Limits
  static const int maxPostImages = 10;
  static const int maxCaptionLength = 2200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  static const int maxCommentLength = 500;
  static const int maxMessageLength = 1000;

  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;
  static const int usersPerPage = 20;

  // Story Duration
  static const int storyDurationHours = 24;

  // Image Quality
  static const int imageQuality = 80;
  static const int thumbnailQuality = 60;

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';
  static const String authError = 'Authentication error. Please login again.';
  static const String uploadError = 'Failed to upload. Please try again.';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String usernameRequired = 'Username is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String usernameTooShort = 'Username must be at least 3 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Success Messages
  static const String postCreated = 'Post created successfully';
  static const String postDeleted = 'Post deleted successfully';
  static const String commentAdded = 'Comment added';
  static const String profileUpdated = 'Profile updated successfully';
  static const String storyAdded = 'Story added';
}
