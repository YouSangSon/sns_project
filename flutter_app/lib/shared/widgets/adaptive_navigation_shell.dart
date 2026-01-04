import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive.dart';
import '../../core/constants/colors.dart';

/// 적응형 네비게이션 셸
///
/// - 데스크톱: 사이드바 네비게이션 + 우측 패널
/// - 태블릿: 축소된 사이드바 + 콘텐츠
/// - 모바일: 하단 네비게이션 바
class AdaptiveNavigationShell extends StatelessWidget {
  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  int get _currentIndex {
    switch (currentPath) {
      case '/':
        return 0;
      case '/search':
        return 1;
      case '/explore':
        return 2;
      case '/reels':
        return 3;
      case '/messages':
        return 4;
      case '/notifications':
        return 5;
      case '/create':
        return 6;
      case '/portfolio':
        return 7;
      case '/profile':
        return 8;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _MobileLayout(
        currentIndex: _currentIndex,
        child: child,
      ),
      tablet: _TabletLayout(
        currentIndex: _currentIndex,
        child: child,
      ),
      desktop: _DesktopLayout(
        currentIndex: _currentIndex,
        child: child,
      ),
    );
  }
}

/// 모바일 레이아웃: 하단 네비게이션 바
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 모바일에서는 5개 탭만 표시 (홈, 검색, 만들기, 알림, 프로필)
    final mobileIndex = switch (currentIndex) {
      0 => 0, // 홈
      1 || 2 => 1, // 검색, 탐색
      6 => 2, // 만들기
      5 => 3, // 알림
      8 => 4, // 프로필
      _ => 0, // 기타는 홈으로
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: mobileIndex,
        onTap: (index) {
          final routes = ['/', '/search', '/create', '/notifications', '/profile'];
          context.go(routes[index]);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
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
      ),
    );
  }
}

/// 태블릿 레이아웃: 축소된 사이드바
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 축소된 사이드바 (아이콘만)
          _CompactSidebar(
            currentIndex: currentIndex,
          ),
          // 메인 콘텐츠
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 데스크톱 레이아웃: 전체 사이드바 + 우측 패널
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLargeDesktop = context.isLargeDesktop;

    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          _ExpandedSidebar(
            currentIndex: currentIndex,
            isExpanded: isLargeDesktop,
          ),
          // 메인 콘텐츠 (중앙 정렬)
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeDesktop
                      ? Breakpoints.maxFeedWidth
                      : Breakpoints.maxFeedWidth + 100,
                ),
                child: child,
              ),
            ),
          ),
          // 우측 패널 (대형 데스크톱에서만)
          if (isLargeDesktop)
            SizedBox(
              width: Breakpoints.rightPanelWidth,
              child: const _RightPanel(),
            ),
        ],
      ),
    );
  }
}

/// 축소된 사이드바 (태블릿용)
class _CompactSidebar extends StatelessWidget {
  const _CompactSidebar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 로고
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 24),
            // 네비게이션 아이템
            Expanded(
              child: ListView(
                children: [
                  _NavItem(icon: Icons.home, isSelected: currentIndex == 0, onTap: () => context.go('/')),
                  _NavItem(icon: Icons.search, isSelected: currentIndex == 1, onTap: () => context.go('/search')),
                  _NavItem(icon: Icons.explore, isSelected: currentIndex == 2, onTap: () => context.go('/explore')),
                  _NavItem(icon: Icons.movie, isSelected: currentIndex == 3, onTap: () => context.go('/reels')),
                  _NavItem(icon: Icons.chat_bubble, isSelected: currentIndex == 4, onTap: () => context.go('/messages')),
                  _NavItem(icon: Icons.favorite, isSelected: currentIndex == 5, onTap: () => context.go('/notifications')),
                  _NavItem(icon: Icons.add_box, isSelected: currentIndex == 6, onTap: () => context.go('/create')),
                  _NavItem(icon: Icons.show_chart, isSelected: currentIndex == 7, onTap: () => context.go('/portfolio')),
                  _NavItem(icon: Icons.person, isSelected: currentIndex == 8, onTap: () => context.go('/profile')),
                ],
              ),
            ),
            // 더보기
            _NavItem(icon: Icons.menu, isSelected: false, onTap: () {}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 확장된 사이드바 (데스크톱용)
class _ExpandedSidebar extends StatelessWidget {
  const _ExpandedSidebar({
    required this.currentIndex,
    required this.isExpanded,
  });

  final int currentIndex;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? Breakpoints.sidebarWidth : 72.0;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로고
            Padding(
              padding: EdgeInsets.all(isExpanded ? 24 : 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'SNS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 네비게이션 아이템
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 8),
                children: [
                  _SidebarItem(icon: Icons.home, label: '홈', isSelected: currentIndex == 0, isExpanded: isExpanded, onTap: () => context.go('/')),
                  _SidebarItem(icon: Icons.search, label: '검색', isSelected: currentIndex == 1, isExpanded: isExpanded, onTap: () => context.go('/search')),
                  _SidebarItem(icon: Icons.explore, label: '탐색', isSelected: currentIndex == 2, isExpanded: isExpanded, onTap: () => context.go('/explore')),
                  _SidebarItem(icon: Icons.movie, label: '릴스', isSelected: currentIndex == 3, isExpanded: isExpanded, onTap: () => context.go('/reels')),
                  _SidebarItem(icon: Icons.chat_bubble, label: '메시지', isSelected: currentIndex == 4, isExpanded: isExpanded, onTap: () => context.go('/messages')),
                  _SidebarItem(icon: Icons.favorite, label: '알림', isSelected: currentIndex == 5, isExpanded: isExpanded, onTap: () => context.go('/notifications')),
                  _SidebarItem(icon: Icons.add_box, label: '만들기', isSelected: currentIndex == 6, isExpanded: isExpanded, onTap: () => context.go('/create')),
                  _SidebarItem(icon: Icons.show_chart, label: '포트폴리오', isSelected: currentIndex == 7, isExpanded: isExpanded, onTap: () => context.go('/portfolio')),
                  _SidebarItem(icon: Icons.person, label: '프로필', isSelected: currentIndex == 8, isExpanded: isExpanded, onTap: () => context.go('/profile')),
                ],
              ),
            ),
            // 더보기
            Padding(
              padding: EdgeInsets.all(isExpanded ? 12 : 8),
              child: _SidebarItem(
                icon: Icons.menu,
                label: '더 보기',
                isSelected: false,
                isExpanded: isExpanded,
                onTap: () => _showMoreMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('저장됨'),
              onTap: () {
                Navigator.pop(context);
                context.push('/saved');
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round_outlined),
              title: const Text('모드 전환'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 네비게이션 아이템 (아이콘만)
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 26,
            color: widget.isSelected ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

/// 사이드바 아이템 (아이콘 + 라벨)
class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 12 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 26,
                color: widget.isSelected ? Colors.black : Colors.grey.shade700,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: widget.isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 우측 패널 (추천 사용자, 트렌드 등)
class _RightPanel extends StatelessWidget {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내 프로필
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'username',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '이름',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '전환',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 추천 사용자
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '회원님을 위한 추천',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  '모두 보기',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 추천 사용자 목록
          ...List.generate(5, (index) => _buildSuggestedUser(index)),
          const Spacer(),
          // 푸터
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _footerLink('소개'),
              _footerLink('도움말'),
              _footerLink('홍보 센터'),
              _footerLink('API'),
              _footerLink('채용 정보'),
              _footerLink('개인정보처리방침'),
              _footerLink('약관'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 SNS FROM FLUTTER',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUser(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('user_$index', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  '회원님을 팔로우합니다',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: const Text(
              '팔로우',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(
      '$text · ',
      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
    );
  }
}
