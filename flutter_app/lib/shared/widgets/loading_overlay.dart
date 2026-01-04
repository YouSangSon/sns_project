import 'package:flutter/material.dart';

/// 로딩 오버레이 위젯
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? color;
  final Widget? loadingWidget;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: color ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: loadingWidget ?? const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

/// 로딩 다이얼로그 표시
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(message ?? '로딩 중...'),
          ],
        ),
      );
    },
  );
}

/// 로딩 다이얼로그 닫기
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}
