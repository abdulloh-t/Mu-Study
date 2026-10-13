import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/screens/student/focus/widgets/soft_fireflies.dart';

class FocusAmbientDecor extends StatelessWidget {
  const FocusAmbientDecor({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 80,
            left: -20,
            child: PaperDecor(
              isDark ? PaperAssets.grayCloud : PaperAssets.whiteCloud,
              size: 90,
              opacity: isDark ? 0.25 : 0.45,
            ),
          ),
          Positioned(
            top: 140,
            right: 12,
            child: PaperDecor(
              PaperAssets.flatCloud,
              size: 64,
              opacity: isDark ? 0.2 : 0.35,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 8,
            child: PaperDecor(
              PaperAssets.singleTree,
              height: 100,
              opacity: isDark ? 0.35 : 0.5,
            ),
          ),
          Positioned(
            bottom: 28,
            right: 4,
            child: PaperDecor(
              PaperAssets.twoTrees,
              height: 120,
              opacity: isDark ? 0.4 : 0.55,
            ),
          ),
          if (isDark) const Positioned.fill(child: SoftFireflies()),
        ],
      ),
    );
  }
}
