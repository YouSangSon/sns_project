import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: AppColors.backgroundGray,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.backgroundGray,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textSecondary,
          ),
        );
  }
}

class CircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData? fallbackIcon;

  const CircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        errorWidget: Container(
          width: radius * 2,
          height: radius * 2,
          color: AppColors.backgroundGray,
          child: Icon(
            fallbackIcon ?? Icons.person,
            color: AppColors.textSecondary,
            size: radius,
          ),
        ),
      ),
    );
  }
}
