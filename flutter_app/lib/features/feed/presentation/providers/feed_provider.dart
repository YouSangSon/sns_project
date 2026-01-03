import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../shared/models/post_model.dart';

// Mock Data
final List<Post> mockPosts = [
  Post(
    postId: 'post-001',
    userId: 'user-001',
    username: 'john_doe',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    imageUrls: ['https://picsum.photos/seed/post1/600/600'],
    caption: '오늘 날씨가 정말 좋네요! ☀️',
    location: 'Seoul, Korea',
    likes: 128,
    comments: 24,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Post(
    postId: 'post-002',
    userId: 'user-002',
    username: 'jane_smith',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
    imageUrls: [
      'https://picsum.photos/seed/post2a/600/600',
      'https://picsum.photos/seed/post2b/600/600',
    ],
    caption: '맛있는 브런치 🍳',
    location: 'Gangnam, Seoul',
    likes: 256,
    comments: 42,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Post(
    postId: 'post-003',
    userId: 'user-003',
    username: 'travel_lover',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=travel',
    imageUrls: ['https://picsum.photos/seed/post3/600/600'],
    caption: '제주도 여행 중입니다 🏝️',
    location: 'Jeju Island',
    likes: 512,
    comments: 88,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Post(
    postId: 'post-004',
    userId: 'user-004',
    username: 'foodie_korea',
    userPhotoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=foodie',
    imageUrls: ['https://picsum.photos/seed/post4/600/600'],
    caption: '오늘의 저녁 메뉴는 삼겹살! 🥓',
    likes: 89,
    comments: 15,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// Feed State
class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

// Feed Notifier
class FeedNotifier extends StateNotifier<FeedState> {
  final ApiService _apiService;

  FeedNotifier(this._apiService) : super(const FeedState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Dev mode - use mock data
      if (AppConfig.isDev) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(
          posts: mockPosts,
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final response = await _apiService.get(
        ApiEndpoints.feed,
        queryParameters: {
          'page': state.currentPage,
          'limit': AppConfig.postsPageSize,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final posts = data.map((json) => Post.fromJson(json)).toList();

      state = state.copyWith(
        posts: [...state.posts, ...posts],
        isLoading: false,
        hasMore: posts.length >= AppConfig.postsPageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      // Fallback to mock data
      state = state.copyWith(
        posts: mockPosts,
        isLoading: false,
        hasMore: false,
      );
    }
  }

  Future<void> refreshPosts() async {
    state = state.copyWith(isRefreshing: true, currentPage: 1);

    try {
      if (AppConfig.isDev) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = FeedState(
          posts: mockPosts,
          isRefreshing: false,
          hasMore: false,
        );
        return;
      }

      final response = await _apiService.get(
        ApiEndpoints.feed,
        queryParameters: {
          'page': 1,
          'limit': AppConfig.postsPageSize,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final posts = data.map((json) => Post.fromJson(json)).toList();

      state = FeedState(
        posts: posts,
        isRefreshing: false,
        hasMore: posts.length >= AppConfig.postsPageSize,
        currentPage: 2,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh feed',
      );
    }
  }

  void likePost(String postId) {
    final posts = state.posts.map((post) {
      if (post.postId == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: posts);
  }

  void bookmarkPost(String postId) {
    final posts = state.posts.map((post) {
      if (post.postId == postId) {
        return post.copyWith(isBookmarked: !post.isBookmarked);
      }
      return post;
    }).toList();

    state = state.copyWith(posts: posts);
  }
}

// Providers
final feedStateProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FeedNotifier(apiService);
});
