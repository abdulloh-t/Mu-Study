import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/focus/focus_session_provider.dart';
import 'package:mu_study/screens/student/focus/focus_format.dart';
import 'package:mu_study/screens/student/focus/widgets/active_session_view.dart';
import 'package:mu_study/screens/student/focus/widgets/focus_home_view.dart';
import 'package:mu_study/screens/student/focus/widgets/focus_summary_view.dart';

class StudentFocusScreen extends ConsumerStatefulWidget {
  const StudentFocusScreen({super.key});

  @override
  ConsumerState<StudentFocusScreen> createState() => _StudentFocusScreenState();
}

class _StudentFocusScreenState extends ConsumerState<StudentFocusScreen>
    with WidgetsBindingObserver {
  Timer? _tick;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final session = ref.read(focusSessionProvider).session;
      if (session == null || session.isPaused) return;
      setState(() {});
      _finishIfTimedOut(session);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final session = ref.read(focusSessionProvider).session;
      if (session != null) _finishIfTimedOut(session);
    }
  }

  void _finishIfTimedOut(FocusSession session) {
    if (!session.isCompleteAt()) return;
    ref.read(focusSessionProvider.notifier).endSession(timedOut: true);
  }

  Future<void> _pickModeAndStart(Assignment a) async {
    final l10n = context.l10n;
    final mode = await showModalBottomSheet<FocusTimerMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.focusChooseMode,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  a.title,
                  style: TextStyle(
                    color: AppColors.inkAlpha(ctx, 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    Icons.timer_outlined,
                    color: AppColors.accent(ctx),
                  ),
                  title: Text(l10n.focusModePomodoro),
                  subtitle: Text(l10n.focusModePomodoroHint),
                  onTap: () => Navigator.pop(ctx, FocusTimerMode.pomodoro),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    Icons.all_inclusive_rounded,
                    color: AppColors.accent(ctx),
                  ),
                  title: Text(l10n.focusModeFree),
                  subtitle: Text(l10n.focusModeFreeHint),
                  onTap: () => Navigator.pop(ctx, FocusTimerMode.free),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mode == null || !mounted) return;
    await ref
        .read(focusSessionProvider.notifier)
        .start(assignmentId: a.id, assignmentTitle: a.title, mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(focusSessionProvider);
    if (focus.session != null) {
      return ActiveSessionView(
        session: focus.session!,
        formatDuration: formatFocusDuration,
        onPause: () => ref.read(focusSessionProvider.notifier).pause(),
        onResume: () => ref.read(focusSessionProvider.notifier).resume(),
        onEnd: () => ref.read(focusSessionProvider.notifier).endSession(),
        onOpenTask: () =>
            context.push('/student/assignments/${focus.session!.assignmentId}'),
      );
    }
    if (focus.summary != null) {
      final summary = focus.summary!;
      if (_noteController.text != (summary.note ?? '') &&
          summary.note != null) {
        _noteController.text = summary.note!;
      }
      return FocusSummaryView(
        summary: summary,
        formatDuration: formatFocusDuration,
        noteController: _noteController,
        onNoteChanged: (v) =>
            ref.read(focusSessionProvider.notifier).setSummaryNote(v),
        onOpenTask: () {
          ref.read(focusSessionProvider.notifier).dismissSummary();
          context.push('/student/assignments/${summary.assignmentId}');
        },
        onDone: () => ref.read(focusSessionProvider.notifier).dismissSummary(),
      );
    }
    return FocusHomeView(onStart: _pickModeAndStart);
  }
}
