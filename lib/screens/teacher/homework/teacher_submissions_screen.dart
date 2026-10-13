import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/attachments/voice_note_field.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/core/homework/feedback_reuse.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/homework/teacher_submissions_provider.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherSubmissionsScreen extends ConsumerWidget {
  const TeacherSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(teacherSubmissionsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.teacherSubmissions)),
      body: submissions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (rows) {
          if (rows.isEmpty) {
            return EmptyState(
              title: l10n.teacherNoSubmissions,
              subtitle: l10n.teacherNoSubmissionsSubtitle,
              icon: Icons.fact_check_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teacherSubmissionsProvider),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                shellContentBottomPadding(context),
              ),
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final row = rows[i];
                final score = row['score'] == null
                    ? null
                    : double.tryParse('${row['score']}');
                return PremiumCard(
                  onTap: () => _review(context, ref, row),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row['task_title'] as String? ?? l10n.taskTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${row['student_name']} · ${row['status']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkAlpha(context, 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PercentBadge(percent: score, compact: true),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
  ) async {
    final teacher = await ref.read(teacherProfileProvider.future);
    if (!context.mounted) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: _ReviewSubmissionDialog(row: row, teacherId: teacher?.id),
        );
      },
    );

    if (saved != true || !context.mounted) return;

    ref.invalidate(teacherSubmissionsProvider);
    final groupId = ref.read(activeGroupIdProvider);
    if (groupId != null) {
      ref.invalidate(groupMarksProvider(groupId));
      ref.invalidate(groupMarkAveragesProvider(groupId));
    }
  }
}

class _ReviewSubmissionDialog extends StatefulWidget {
  const _ReviewSubmissionDialog({required this.row, this.teacherId});

  final Map<String, dynamic> row;
  final String? teacherId;

  @override
  State<_ReviewSubmissionDialog> createState() =>
      _ReviewSubmissionDialogState();
}

class _ReviewSubmissionDialogState extends State<_ReviewSubmissionDialog> {
  late final TextEditingController _scoreController;
  late final TextEditingController _feedbackController;
  late final FocusNode _scoreFocus;
  bool _saving = false;
  bool _applyToOthers = false;
  List<String> _snippets = const [];

  @override
  void initState() {
    super.initState();
    final score = widget.row['score'];
    _scoreController = TextEditingController(
      text: score == null ? '' : '$score',
    );
    _feedbackController = TextEditingController(
      text: widget.row['feedback'] as String? ?? '',
    );
    _scoreFocus = FocusNode();
    _loadSnippets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scoreFocus.requestFocus();
    });
  }

  Future<void> _loadSnippets() async {
    final teacherId = widget.teacherId;
    if (teacherId == null) return;
    final snippets = await loadFeedbackSnippets(teacherId: teacherId);
    if (!mounted) return;
    setState(() => _snippets = snippets);
  }

  @override
  void dispose() {
    _scoreFocus.dispose();
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final raw = _scoreController.text.trim().replaceAll(',', '.');
    final score = raw.isEmpty ? null : double.tryParse(raw);
    if (raw.isNotEmpty && (score == null || score < 0 || score > 100)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.teacherScoreRange)));
      return;
    }

    setState(() => _saving = true);
    final feedback = _feedbackController.text.trim();
    try {
      await supabase
          .from('submissions')
          .update({
            'score': score,
            'feedback': feedback,
            'status': score == null ? 'submitted' : 'reviewed',
          })
          .eq('id', widget.row['id']);

      final teacherId = widget.teacherId;
      if (teacherId != null && feedback.isNotEmpty) {
        await rememberFeedbackSnippet(teacherId: teacherId, feedback: feedback);
      }

      var applied = 0;
      if (_applyToOthers && feedback.isNotEmpty) {
        applied = await applyFeedbackToOtherPendingForSameTask(
          submissionId: widget.row['id'] as String,
          feedback: feedback,
        );
      }

      if (!mounted) return;
      if (applied > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.teacherFeedbackAppliedCount(applied)),
          ),
        );
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonCouldNotSave('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fileUrl = widget.row['file_url'] as String?;
    final voiceUrl = widget.row['voice_url'] as String?;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.row['student_name'] as String? ??
                  l10n.teacherReviewSubmission,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              widget.row['task_title'] as String? ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.inkAlpha(context, 0.6),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.row['text_answer'] as String? ??
                  l10n.teacherNoWrittenAnswer,
              style: TextStyle(
                color: AppColors.inkAlpha(context, 0.75),
                height: 1.4,
              ),
            ),
            if (voiceUrl != null && voiceUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              VoiceNotePlayer(url: voiceUrl),
            ],
            if (fileUrl != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(fileUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text(l10n.teacherOpenAttachment),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              focusNode: _scoreFocus,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: l10n.commonScore,
                suffixText: '%',
                helperText: l10n.teacherScoreHelper,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              enabled: !_saving,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.commonFeedback),
            ),
            if (_snippets.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.teacherRecentFeedback,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkAlpha(context, 0.55),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _snippets.take(8).map((s) {
                  final label = s.length > 42 ? '${s.substring(0, 42)}…' : s;
                  return ActionChip(
                    label: Text(label, style: const TextStyle(fontSize: 12)),
                    onPressed: _saving
                        ? null
                        : () {
                            _feedbackController.text = s;
                            _feedbackController.selection =
                                TextSelection.collapsed(offset: s.length);
                          },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 4),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _applyToOthers,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _applyToOthers = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                l10n.teacherApplyFeedbackToOthers,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent(context),
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkChocolate
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Text(
                            l10n.commonSave,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
