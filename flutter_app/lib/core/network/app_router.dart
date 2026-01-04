import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/post/presentation/pages/create_post_page.dart';
import '../../features/post/presentation/pages/post_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/investment/presentation/pages/portfolio_page.dart';
import '../../shared/widgets/adaptive_navigation_shell.dart';

/// 라우트 이름 정의
abstract class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String signup = '/signup';

  // Main tabs
  static const String feed = '/';
  static const String search = '/search';
  static const String explore = '/explore';
  static const String reels = '/reels';
  static const String createPost = '/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Post
  static const String postDetail = '/post/:id';

  // Profile
  static const String userProfile = '/user/:id';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String saved = '/saved';

  // Messages
  static const String conversations = '/messages';
  static const String chat = '/messages/:id';

  // Investment
  static const String portfolio = '/portfolio';
}

/// 라우터 Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.feed,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      // TODO: 인증 상태에 따른 리다이렉트 로직
      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),

      // Main navigation shell (적응형: 웹에서는 사이드바, 모바일에서는 하단 네비게이션)
      ShellRoute(
        builder: (context, state, child) => AdaptiveNavigationShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          // 피드 (홈)
          GoRoute(
            path: AppRoutes.feed,
            name: 'feed',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FeedPage(),
            ),
          ),
          // 검색
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchPage(),
            ),
          ),
          // 탐색 (웹 전용)
          GoRoute(
            path: AppRoutes.explore,
            name: 'explore',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchPage(), // 탐색 페이지로 대체 가능
            ),
          ),
          // 릴스 (웹 전용)
          GoRoute(
            path: AppRoutes.reels,
            name: 'reels',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FeedPage(), // 릴스 페이지로 대체 가능
            ),
          ),
          // 알림
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const NotificationsPage(),
            ),
          ),
          // 프로필
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
          // 메시지 (채팅 목록)
          GoRoute(
            path: AppRoutes.conversations,
            name: 'conversations',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ConversationsPage(),
            ),
          ),
          // 포트폴리오
          GoRoute(
            path: AppRoutes.portfolio,
            name: 'portfolio',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PortfolioPage(),
            ),
          ),
        ],
      ),

      // Standalone routes (모달 또는 전체 화면)
      GoRoute(
        path: AppRoutes.createPost,
        name: 'createPost',
        pageBuilder: (context, state) {
          // 웹에서는 다이얼로그, 모바일에서는 전체 화면
          if (kIsWeb && MediaQuery.of(context).size.width >= 600) {
            return DialogPage(
              builder: (context) => Dialog(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    maxHeight: 700,
                  ),
                  child: const CreatePostPage(),
                ),
              ),
            );
          }
          return MaterialPage(
            key: state.pageKey,
            child: const CreatePostPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.postDetail,
        name: 'postDetail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailPage(postId: postId);
        },
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['id']!;
          return ProfilePage(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return ChatPage(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('설정')),
        ),
      ),
      GoRoute(
        path: AppRoutes.saved,
        name: 'saved',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('저장됨')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.feed),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// 다이얼로그 페이지 (웹용)
class DialogPage<T> extends Page<T> {
  const DialogPage({
    required this.builder,
    super.key,
    super.name,
  });

  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
    );
  }
}
