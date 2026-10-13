import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';

ButtonStyle gradebookPrimaryButtonStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fg = isDark ? AppColors.darkChocolate : Colors.white;
  return FilledButton.styleFrom(
    backgroundColor: AppColors.accent(context),
    foregroundColor: fg,
    disabledBackgroundColor: AppColors.accent(context).withValues(alpha: 0.35),
    disabledForegroundColor: fg.withValues(alpha: 0.55),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );
}

class GradebookSheetScaffold extends StatelessWidget {
  const GradebookSheetScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.sheetSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softSurface(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: PremiumSectionHeader(title: title, subtitle: subtitle),
            ),
            Flexible(child: child),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: SizedBox(width: double.infinity, child: action),
            ),
          ],
        ),
      ),
    );
  }
}

class GradebookCategoryDropdown extends StatelessWidget {
  const GradebookCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MarkCategory value;
  final ValueChanged<MarkCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonFormField<MarkCategory>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.marksCategory),
      items: MarkCategory.values
          .map(
            (c) => DropdownMenuItem(value: c, child: Text(c.l10nLabel(l10n))),
          )
          .toList(),
      onChanged: (v) => onChanged(v ?? MarkCategory.other),
    );
  }
}

class GradebookDateField extends StatelessWidget {
  const GradebookDateField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: context.l10n.marksDate),
        child: Row(
          children: [
            Text(DateFormat.yMMMd().format(value)),
            const Spacer(),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.inkAlpha(context, 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
