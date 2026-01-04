import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/responsive/responsive.dart';
import 'web_sidebar.dart';
import 'web_right_panel.dart';

/// 웹 앱 셸 레이아웃
///
/// 데스크톱에서는 사이드바 + 콘텐츠 + 우측 패널 레이아웃
/// 모바일/태블릿에서는 하단 네비게이션 + 콘텐츠 레이아웃
class WebAppShell extends StatefulWidget {
  const WebAppShell({
    super.key,
    required this.child,
    this.showRightPanel = true,
  });

  final Widget child;
  final bool showRightPanel;

  @override
  State<WebAppShell> createState() => _WebAppShellState();
}

class _WebAppShellState extends State<WebAppShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/feed',
    '/search',
    '/explore',
    '/reels',
    '/messages',
    '/notifications',
    '/create',
    '/portfolio',
    '/profile',
  ];

  void _onNavTap(int index) {
    if (index < _routes.length) {
      setState(() => _currentIndex = index);
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  /// 모바일 레이아웃: 하단 네비게이션
  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// 태블릿 레이아웃: 축소된 사이드바 + 콘텐츠
  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 72,
            child: WebSidebar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// 데스크톱 레이아웃: 사이드바 + 콘텐츠 + 우측 패널
  Widget _buildDesktopLayout() {
    final isLargeDesktop = context.isLargeDesktop;

    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          WebSidebar(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
          // 메인 콘텐츠
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Breakpoints.maxFeedWidth,
                ),
                child: widget.child,
              ),
            ),
          ),
          // 우측 패널 (대형 데스크톱에서만)
          if (widget.showRightPanel && isLargeDesktop)
            const SizedBox(
              width: Breakpoints.rightPanelWidth,
              child: WebRightPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
      onTap: (index) {
        // 모바일에서는 5개 탭만 표시
        final mobileRoutes = ['/feed', '/search', '/create', '/notifications', '/profile'];
        if (index < mobileRoutes.length) {
          setState(() => _currentIndex = index);
          context.go(mobileRoutes[index]);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: '검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          activeIcon: Icon(Icons.add_box),
          label: '만들기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: '알림',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  }
}
