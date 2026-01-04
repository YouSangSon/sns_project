import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/responsive/breakpoints.dart';

/// 웹 사이드바 네비게이션
class WebSidebar extends StatelessWidget {
  const WebSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isLargeDesktop = MediaQuery.of(context).size.width >= Breakpoints.largeDesktop;

    return Container(
      width: isLargeDesktop ? Breakpoints.sidebarWidth : 72,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 로고
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeDesktop ? 24 : 16,
                vertical: 24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (isLargeDesktop) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'SNS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
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
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeDesktop ? 12 : 8,
                ),
                children: [
                  _SidebarItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: '홈',
                    isSelected: currentIndex == 0,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(0),
                  ),
                  _SidebarItem(
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search,
                    label: '검색',
                    isSelected: currentIndex == 1,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(1),
                  ),
                  _SidebarItem(
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore,
                    label: '탐색',
                    isSelected: currentIndex == 2,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(2),
                  ),
                  _SidebarItem(
                    icon: Icons.movie_outlined,
                    selectedIcon: Icons.movie,
                    label: '릴스',
                    isSelected: currentIndex == 3,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(3),
                  ),
                  _SidebarItem(
                    icon: Icons.chat_bubble_outline,
                    selectedIcon: Icons.chat_bubble,
                    label: '메시지',
                    isSelected: currentIndex == 4,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(4),
                  ),
                  _SidebarItem(
                    icon: Icons.favorite_border,
                    selectedIcon: Icons.favorite,
                    label: '알림',
                    isSelected: currentIndex == 5,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(5),
                  ),
                  _SidebarItem(
                    icon: Icons.add_box_outlined,
                    selectedIcon: Icons.add_box,
                    label: '만들기',
                    isSelected: currentIndex == 6,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(6),
                  ),
                  _SidebarItem(
                    icon: Icons.show_chart,
                    selectedIcon: Icons.show_chart,
                    label: '포트폴리오',
                    isSelected: currentIndex == 7,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(7),
                  ),
                  _SidebarItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: '프로필',
                    isSelected: currentIndex == 8,
                    isExpanded: isLargeDesktop,
                    onTap: () => onTap(8),
                  ),
                ],
              ),
            ),
            // 더보기 메뉴
            Padding(
              padding: EdgeInsets.all(isLargeDesktop ? 12 : 8),
              child: _SidebarItem(
                icon: Icons.menu,
                selectedIcon: Icons.menu,
                label: '더 보기',
                isSelected: false,
                isExpanded: isLargeDesktop,
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
                // TODO: 테마 전환 구현
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 로그아웃 구현
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
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
                widget.isSelected ? widget.selectedIcon : widget.icon,
                size: 26,
                color: widget.isSelected ? Colors.black : Colors.grey.shade700,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        widget.isSelected ? Colors.black : Colors.grey.shade700,
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
