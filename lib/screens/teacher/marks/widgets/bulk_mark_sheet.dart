import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/teacher/marks/widgets/gradebook_helpers.dart';

class BulkMarkSheet extends ConsumerStatefulWidget {
  const BulkMarkSheet({
    super.key,
    required this.groupId,
    required this.members,
  });

  final String groupId;
  final List<GroupMember> members;

  @override
  ConsumerState<BulkMarkSheet> createState() => _BulkMarkSheetState();
}

class _BulkMarkSheetState extends ConsumerState<BulkMarkSheet> {
  final _titleController = TextEditingController();
  final _weightController = TextEditingController(text: '1');
  final _commentController = TextEditingController();
  late final Map<String, TextEditingController> _percentControllers = {
    for (final m in widget.members) m.studentId: TextEditingController(),
  };

  MarkCategory _category = MarkCategory.test;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _commentController.dispose();
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _toast(l10n.marksNeedTitle);
      return;
    }

    final weight = double.tryParse(_weightController.text.trim()) ?? 1;
    if (weight <= 0) {
      _toast(l10n.marksWeightPositive);
      return;
    }

    final entries = <String, double>{};
    for (final entry in _percentControllers.entries) {
      final raw = entry.value.text.trim();
      if (raw.isEmpty) continue;
      final value = double.tryParse(raw);
      if (value == null || value < 0 || value > 100) {
        _toast(l10n.teacherScoreRange);
        return;
      }
      entries[entry.key] = value;
    }

    if (entries.isEmpty) {
      _toast(l10n.marksNeedAtLeastOne);
      return;
    }

    final teacher = await ref.read(teacherProfileProvider.future);
    if (teacher == null) return;

    final comment = _commentController.text.trim();
    setState(() => _saving = true);
    try {
      for (final entry in entries.entries) {
        await saveMark(
          groupId: widget.groupId,
          studentId: entry.key,
          teacherId: teacher.id,
          title: title,
          category: _category,
          percentage: entry.value,
          weight: weight,
          comment: comment,
          markedOn: _date,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.marksSavedCount(entries.length))),
        );
      }
    } catch (e) {
      _toast(l10n.commonCouldNotSave('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GradebookSheetScaffold(
      title: l10n.marksGradeTheClass,
      subtitle: l10n.marksOnePercentEach,
      action: FilledButton(
        onPressed: _saving ? null : _save,
        style: gradebookPrimaryButtonStyle(context),
        child: _saving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkChocolate
                      : Colors.white,
                ),
              )
            : Text(
                l10n.marksSaveMarks,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.commonTitle,
              hintText: l10n.marksTitleHint,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.teacherSharedComment,
              hintText: l10n.teacherSharedCommentHint,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradebookCategoryDropdown(
                  value: _category,
                  onChanged: (v) => setState(() => _category = v),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l10n.marksWeight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradebookDateField(
            value: _date,
            onChanged: (v) => setState(() => _date = v),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.marksLeaveBlankSkip,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkAlpha(context, 0.5),
            ),
          ),
          const SizedBox(height: 8),
          ...widget.members.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      m.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: _percentControllers[m.studentId],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d{0,2})?'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: '—',
                        suffixText: '%',
                        isDense: true,
                      ),
                    ),
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
