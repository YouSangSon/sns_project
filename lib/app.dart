import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider_riverpod.dart';
import 'providers/theme_provider_riverpod.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/post/post_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/notifications/notifications_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: authState.value != null ? '/home' : '/login',
      redirect: (context, state) {
        final isAuthenticated = authState.value != null;
        final isLoginRoute = state.matchedLocation == '/login' ||
                             state.matchedLocation == '/signup';

        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoginRoute) {
          return '/home';
        }

        return null;
      },
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (context, state) => const SignupScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/create-post',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) {
                final postId = state.pathParameters['postId']!;
                return PostDetailScreen(postId: postId);
              },
            ),
            GoRoute(
              path: '/profile/:userId',
              builder: (context, state) {
                final userId = state.pathParameters['userId']!;
                return ProfileScreen(userId: userId);
              },
            ),
            GoRoute(
              path: '/edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        );

    return MaterialApp.router(
      title: 'SNS App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
