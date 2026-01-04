import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_feed_usecase.dart';

part 'feed_provider.freezed.dart';

/// 피드 상태
@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    @Default([]) List<PostEntity> posts,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(1) int currentPage,
    String? error,
  }) = _FeedState;
}

/// 피드 Provider
class FeedNotifier extends StateNotifier<FeedState> {
  final GetFeedUseCase _getFeedUseCase;

  FeedNotifier({required GetFeedUseCase getFeedUseCase})
      : _getFeedUseCase = getFeedUseCase,
        super(const FeedState()) {
    loadFeed();
  }

  /// 피드 로드
  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getFeedUseCase(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.errorMessage,
      ),
      (posts) => state = state.copyWith(
        isLoading: false,
        posts: posts,
        currentPage: 1,
        hasMore: posts.length >= 10,
      ),
    );
  }

  /// 피드 새로고침
  Future<void> refreshFeed() async {
    final result = await _getFeedUseCase(page: 1);

    result.fold(
      (failure) => state = state.copyWith(error: failure.errorMessage),
      (posts) => state = state.copyWith(
        posts: posts,
        currentPage: 1,
        hasMore: posts.length >= 10,
      ),
    );
  }

  /// 더 불러오기
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _getFeedUseCase(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(isLoadingMore: false),
      (posts) => state = state.copyWith(
        isLoadingMore: false,
        posts: [...state.posts, ...posts],
        currentPage: nextPage,
        hasMore: posts.length >= 10,
      ),
    );
  }

  /// 게시물 좋아요 업데이트
  void updatePostLike(String postId, bool isLiked, int likesCount) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isLiked: isLiked, likesCount: likesCount);
        }
        return post;
      }).toList(),
    );
  }

  /// 게시물 삭제
  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );
  }
}
