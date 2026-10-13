import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/marks/percent_badge.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/teacher/marks/widgets/gradebook_helpers.dart';

class MarkEditorSheet extends ConsumerStatefulWidget {
  const MarkEditorSheet({
    super.key,
    required this.groupId,
    required this.studentId,
    required this.studentName,
    this.existing,
  });

  final String groupId;
  final String studentId;
  final String studentName;
  final Mark? existing;

  @override
  ConsumerState<MarkEditorSheet> createState() => _MarkEditorSheetState();
}

class _MarkEditorSheetState extends ConsumerState<MarkEditorSheet> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final _percentController = TextEditingController(
    text: widget.existing == null
        ? ''
        : formatPercent(widget.existing!.percentage).replaceAll('%', ''),
  );
  late final _weightController = TextEditingController(
    text: '${widget.existing?.weight ?? 1}',
  );
  late final _commentController = TextEditingController(
    text: widget.existing?.comment ?? '',
  );

  late MarkCategory _category = widget.existing?.category ?? MarkCategory.other;
  late DateTime _date = widget.existing?.markedOn ?? DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _percentController.dispose();
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final percent = double.tryParse(_percentController.text.trim());
    final weight = double.tryParse(_weightController.text.trim()) ?? 1;

    if (title.isEmpty) {
      _toast(l10n.marksNeedTitle);
      return;
    }
    if (percent == null || percent < 0 || percent > 100) {
      _toast(l10n.teacherScoreRange);
      return;
    }
    if (weight <= 0) {
      _toast(l10n.marksWeightPositive);
      return;
    }

    final teacher = await ref.read(teacherProfileProvider.future);
    if (teacher == null) return;

    setState(() => _saving = true);
    try {
      await saveMark(
        groupId: widget.groupId,
        studentId: widget.studentId,
        teacherId: teacher.id,
        title: title,
        category: _category,
        percentage: percent,
        weight: weight,
        comment: _commentController.text.trim(),
        markedOn: _date,
        markId: widget.existing?.id,
      );
      if (mounted) Navigator.pop(context);
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
    final linked = widget.existing?.isFromSubmission ?? false;

    return GradebookSheetScaffold(
      title: widget.existing == null ? l10n.marksNewMark : l10n.marksEditMark,
      subtitle: widget.studentName,
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
                l10n.marksSaveMark,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (linked)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.marksFromSubmissionEdit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warmAmber,
                  height: 1.4,
                ),
              ),
            ),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.commonTitle),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _percentController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,3}(\.\d{0,2})?'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.commonScore,
                    suffixText: '%',
                  ),
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
          GradebookCategoryDropdown(
            value: _category,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),
          GradebookDateField(
            value: _date,
            onChanged: (v) => setState(() => _date = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.marksCommentOptional),
          ),
        ],
      ),
    );
  }
}
