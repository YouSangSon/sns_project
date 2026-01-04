import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// 반응형 위젯 빌더
///
/// 화면 크기에 따라 다른 위젯을 렌더링합니다.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// 모바일 레이아웃 (필수)
  final Widget mobile;

  /// 태블릿 레이아웃 (선택)
  final Widget? tablet;

  /// 데스크톱 레이아웃 (선택)
  final Widget? desktop;

  /// 대형 데스크톱 레이아웃 (선택)
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = getDeviceType(width);

        switch (deviceType) {
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}

/// 반응형 가시성 위젯
///
/// 특정 디바이스 타입에서만 표시합니다.
class ResponsiveVisibility extends StatelessWidget {
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.visibleOnLargeDesktop = true,
    this.replacement = const SizedBox.shrink(),
  });

  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final bool visibleOnLargeDesktop;
  final Widget replacement;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = getDeviceType(width);

        bool isVisible;
        switch (deviceType) {
          case DeviceType.mobile:
            isVisible = visibleOnMobile;
            break;
          case DeviceType.tablet:
            isVisible = visibleOnTablet;
            break;
          case DeviceType.desktop:
            isVisible = visibleOnDesktop;
            break;
          case DeviceType.largeDesktop:
            isVisible = visibleOnLargeDesktop;
            break;
        }

        return isVisible ? child : replacement;
      },
    );
  }
}

/// 반응형 그리드 아이템 개수
class ResponsiveGrid {
  ResponsiveGrid._();

  /// 화면 너비에 따른 그리드 컬럼 수 반환
  static int getColumnCount(double width, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop;
    }
  }

  /// 프로필 그리드 컬럼 수
  static int getProfileGridColumns(double width) {
    return getColumnCount(
      width,
      mobile: 3,
      tablet: 4,
      desktop: 5,
      largeDesktop: 6,
    );
  }

  /// 검색 결과 그리드 컬럼 수
  static int getSearchGridColumns(double width) {
    return getColumnCount(
      width,
      mobile: 3,
      tablet: 4,
      desktop: 5,
      largeDesktop: 6,
    );
  }
}
