/// 반응형 브레이크포인트 정의
class Breakpoints {
  Breakpoints._();

  /// 모바일: 0 - 599
  static const double mobile = 0;

  /// 태블릿: 600 - 1023
  static const double tablet = 600;

  /// 데스크톱: 1024 - 1439
  static const double desktop = 1024;

  /// 대형 데스크톱: 1440+
  static const double largeDesktop = 1440;

  /// 최대 콘텐츠 너비 (중앙 정렬 레이아웃용)
  static const double maxContentWidth = 1200;

  /// 피드 최대 너비
  static const double maxFeedWidth = 600;

  /// 사이드바 너비
  static const double sidebarWidth = 280;

  /// 우측 패널 너비 (데스크톱)
  static const double rightPanelWidth = 320;
}

/// 디바이스 타입
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 화면 크기에 따른 디바이스 타입 반환
DeviceType getDeviceType(double width) {
  if (width >= Breakpoints.largeDesktop) {
    return DeviceType.largeDesktop;
  } else if (width >= Breakpoints.desktop) {
    return DeviceType.desktop;
  } else if (width >= Breakpoints.tablet) {
    return DeviceType.tablet;
  } else {
    return DeviceType.mobile;
  }
}
