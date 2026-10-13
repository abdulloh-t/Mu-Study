import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mu_study/core/theme/app_colors.dart';

class SwipeToReply extends StatefulWidget {
  const SwipeToReply({super.key, required this.child, required this.onReply});

  final Widget child;
  final VoidCallback onReply;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> {
  static const _threshold = 56.0;
  double _dx = 0;
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    final progress = (_dx / _threshold).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        final next = (_dx + details.delta.dx).clamp(0.0, _threshold * 1.35);
        setState(() => _dx = next);
        if (!_triggered && _dx >= _threshold) {
          _triggered = true;
          HapticFeedback.selectionClick();
        }
      },
      onHorizontalDragEnd: (_) {
        final shouldReply = _dx >= _threshold;
        setState(() {
          _dx = 0;
          _triggered = false;
        });
        if (shouldReply) widget.onReply();
      },
      onHorizontalDragCancel: () {
        setState(() {
          _dx = 0;
          _triggered = false;
        });
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (progress > 0)
            Opacity(
              opacity: progress,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.reply_rounded,
                  color: AppColors.accent(context),
                  size: 22 + (progress * 4),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dx * 0.85, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
