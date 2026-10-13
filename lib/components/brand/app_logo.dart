import 'package:flutter/material.dart';

class AppLogo {
  static const asset = 'assets/images/logo/logo.jpeg';
}

class AppLogoImage extends StatelessWidget {
  const AppLogoImage({
    super.key,
    this.size = 40,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);
    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        AppLogo.asset,
        width: size,
        height: size,
        fit: fit,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'MU Study',
      ),
    );
  }
}
