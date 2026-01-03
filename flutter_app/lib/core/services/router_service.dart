import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/post/presentation/screens/post_detail_screen.dart';
import '../../features/post/presentation/screens/create_post_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/messages/presentation/screens/conversations_screen.dart';
import '../../features/messages/presentation/screens/chat_screen.dart';
import '../../features/investment/presentation/screens/portfolio_list_screen.dart';
import '../../features/investment/presentation/screens/portfolio_detail_screen.dart';
import '../../features/investment/presentation/screens/create_portfolio_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/stories/presentation/screens/stories_screen.dart';
import '../../features/stories/presentation/screens/create_story_screen.dart';
import '../../features/reels/presentation/screens/reels_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/create-post',
            name: 'createPost',
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: '/investment',
            name: 'investment',
            builder: (context, state) => const PortfolioListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Post Routes
      GoRoute(
        path: '/post/:postId',
        name: 'postDetail',
        builder: (context, state) => PostDetailScreen(
          postId: state.pathParameters['postId']!,
        ),
      ),

      // Profile Routes
      GoRoute(
        path: '/user/:userId',
        name: 'userProfile',
        builder: (context, state) => ProfileScreen(
          userId: state.pathParameters['userId'],
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Message Routes
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),

      // Investment Routes
      GoRoute(
        path: '/portfolio/:portfolioId',
        name: 'portfolioDetail',
        builder: (context, state) => PortfolioDetailScreen(
          portfolioId: state.pathParameters['portfolioId']!,
        ),
      ),
      GoRoute(
        path: '/create-portfolio',
        name: 'createPortfolio',
        builder: (context, state) => const CreatePortfolioScreen(),
      ),

      // Bookmarks Route
      GoRoute(
        path: '/bookmarks',
        name: 'bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),

      // Stories Routes
      GoRoute(
        path: '/stories/:userId',
        name: 'stories',
        builder: (context, state) => StoriesScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),
      GoRoute(
        path: '/create-story',
        name: 'createStory',
        builder: (context, state) => const CreateStoryScreen(),
      ),

      // Reels Route
      GoRoute(
        path: '/reels',
        name: 'reels',
        builder: (context, state) => const ReelsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
