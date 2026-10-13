import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/focus/focus_session_provider.dart';
import 'package:mu_study/screens/student/focus/widgets/focus_ambient_decor.dart';

class ActiveSessionView extends StatelessWidget {
  const ActiveSessionView({
    super.key,
    required this.session,
    required this.formatDuration,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onOpenTask,
  });

  final FocusSession session;
  final String Function(Duration) formatDuration;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onOpenTask;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nature = isNaturePaper(context);
    final elapsed = session.elapsedAt();
    final remaining = session.remainingAt();
    final display = remaining ?? elapsed;
    final progress = session.mode == FocusTimerMode.pomodoro
        ? (1 -
                  (remaining?.inMilliseconds ?? 0) /
                      kFocusPomodoroDuration.inMilliseconds)
              .clamp(0.0, 1.0)
        : null;

    return Scaffold(
      backgroundColor: nature
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (nature) const FocusAmbientDecor(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent(
                            context,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.focusDoNotDisturb,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent(context),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onEnd,
                        child: Text(l10n.focusEndSession),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Text(
                    session.assignmentTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkAlpha(context, 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.mode == FocusTimerMode.pomodoro
                        ? l10n.focusModePomodoro
                        : l10n.focusModeFree,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkAlpha(context, 0.45),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (progress != null)
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              backgroundColor: AppColors.inkAlpha(
                                context,
                                0.08,
                              ),
                              color: AppColors.accent(context),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.inkAlpha(context, 0.08),
                                width: 6,
                              ),
                            ),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatDuration(display),
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                            if (session.isPaused)
                              Text(
                                l10n.focusPaused,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning(context),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: session.isPaused ? onResume : onPause,
                          icon: Icon(
                            session.isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(
                            session.isPaused
                                ? l10n.focusResume
                                : l10n.focusPause,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onOpenTask,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(l10n.focusOpenAssignment),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
