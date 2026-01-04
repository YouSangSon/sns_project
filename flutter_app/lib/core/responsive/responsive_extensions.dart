import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// BuildContext 반응형 확장
extension ResponsiveContext on BuildContext {
  /// 화면 너비
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 화면 높이
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 현재 디바이스 타입
  DeviceType get deviceType => getDeviceType(screenWidth);

  /// 모바일인지 확인
  bool get isMobile => deviceType == DeviceType.mobile;

  /// 태블릿인지 확인
  bool get isTablet => deviceType == DeviceType.tablet;

  /// 데스크톱인지 확인
  bool get isDesktop =>
      deviceType == DeviceType.desktop ||
      deviceType == DeviceType.largeDesktop;

  /// 대형 데스크톱인지 확인
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  /// 모바일 또는 태블릿인지 확인
  bool get isMobileOrTablet => isMobile || isTablet;

  /// 사이드바를 표시해야 하는지 확인
  bool get shouldShowSidebar => isDesktop;

  /// 하단 네비게이션을 표시해야 하는지 확인
  bool get shouldShowBottomNav => !isDesktop;

  /// 콘텐츠 패딩 (반응형)
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// 반응형 값 반환
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
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
  }
}

/// 반응형 수치 헬퍼
extension ResponsiveDouble on double {
  /// 화면 너비 비율로 변환
  double widthPercent(BuildContext context) {
    return context.screenWidth * (this / 100);
  }

  /// 화면 높이 비율로 변환
  double heightPercent(BuildContext context) {
    return context.screenHeight * (this / 100);
  }
}
