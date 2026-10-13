import 'package:flutter/material.dart';
import 'package:mu_study/components/buttons/primary_button.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/focus/focus_session_provider.dart';

class FocusSummaryView extends StatelessWidget {
  const FocusSummaryView({
    super.key,
    required this.summary,
    required this.formatDuration,
    required this.noteController,
    required this.onNoteChanged,
    required this.onOpenTask,
    required this.onDone,
  });

  final FocusSummary summary;
  final String Function(Duration) formatDuration;
  final TextEditingController noteController;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onOpenTask;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minutes = summary.focused.inMinutes;
    final seconds = summary.focused.inSeconds % 60;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            shellContentBottomPadding(context),
          ),
          children: [
            if (isNaturePaper(context))
              const Align(
                alignment: Alignment.centerRight,
                child: PaperDecor(
                  PaperAssets.beigeLeaf,
                  size: 36,
                  angle: 0.3,
                  opacity: 0.75,
                ),
              ),
            Text(
              summary.timedOut ? l10n.focusTimeUp : l10n.focusSessionComplete,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              summary.timedOut
                  ? l10n.focusTimeUpSubtitle
                  : l10n.focusSessionCompleteSubtitle,
              style: TextStyle(color: AppColors.inkAlpha(context, 0.55)),
            ),
            const SizedBox(height: 20),
            PaperTaped(
              child: PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.assignmentTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.focusMinutesFocused(
                        minutes > 0 ? '$minutes min' : '${seconds}s',
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDuration(summary.focused),
                      style: TextStyle(
                        color: AppColors.inkAlpha(context, 0.45),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.focusOptionalNote,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              onChanged: onNoteChanged,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.focusOptionalNoteHint),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l10n.focusSaveAndOpen, onPressed: onOpenTask),
            const SizedBox(height: 10),
            TextButton(onPressed: onDone, child: Text(l10n.focusDone)),
          ],
        ),
      ),
    );
  }
}
