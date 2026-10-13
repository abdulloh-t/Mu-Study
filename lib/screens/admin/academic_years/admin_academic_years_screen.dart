import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class AdminAcademicYearsScreen extends ConsumerStatefulWidget {
  const AdminAcademicYearsScreen({super.key});

  @override
  ConsumerState<AdminAcademicYearsScreen> createState() =>
      _AdminAcademicYearsScreenState();
}

class _AdminAcademicYearsScreenState
    extends ConsumerState<AdminAcademicYearsScreen> {
  bool _busy = false;

  Future<void> _createNext() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final row = await supabase.rpc('admin_create_next_academic_year');
      final label = (row as Map)['label'] as String? ?? '';
      ref.invalidate(academicYearsProvider);
      ref.invalidate(academicTermOptionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminYearCreated(label))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setCurrent(String yearId) async {
    setState(() => _busy = true);
    try {
      await supabase.rpc(
        'admin_set_current_academic_year',
        params: {'p_year_id': yearId},
      );
      ref.invalidate(academicYearsProvider);
      ref.invalidate(academicTermOptionsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _normalizeYearConfirm(String value) =>
      value.trim().replaceAll(RegExp(r'[–—−﹣]'), '-');

  Future<void> _deleteYear(AcademicYearRecord year) async {
    final l10n = context.l10n;
    if (year.isCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminDeleteYearCurrentBlocked)),
      );
      return;
    }

    final confirmController = TextEditingController();
    final expected = _normalizeYearConfirm(year.label);
    var matches = false;

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(l10n.adminDeleteYearTitle(year.label)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.adminDeleteYearBody(year.label)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.adminDeleteYearConfirmHint(year.label),
                    ),
                    onChanged: (value) {
                      setLocal(() {
                        matches = _normalizeYearConfirm(value) == expected;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: matches ? () => Navigator.pop(ctx, true) : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  child: Text(l10n.commonDelete),
                ),
              ],
            );
          },
        );
      },
    );
    confirmController.dispose();

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await supabase.rpc(
        'admin_delete_academic_year',
        params: {'p_year_id': year.id},
      );
      ref.invalidate(academicYearsProvider);
      ref.invalidate(academicTermOptionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminYearDeleted(year.label))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editTerm(AcademicTerm term) async {
    final termId = term.dbTermId;
    final semester = term.semester;
    final start = term.startInclusive;
    final end = term.endInclusive;
    if (termId == null || semester == null || start == null || end == null) {
      return;
    }

    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    var startsOn = start;
    var endsOn = end;

    final saved = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> pickStart() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: startsOn,
                firstDate: DateTime(startsOn.year - 2),
                lastDate: DateTime(endsOn.year + 2),
              );
              if (picked != null) setLocal(() => startsOn = picked);
            }

            Future<void> pickEnd() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: endsOn,
                firstDate: DateTime(startsOn.year - 2),
                lastDate: DateTime(endsOn.year + 2),
              );
              if (picked != null) setLocal(() => endsOn = picked);
            }

            return AlertDialog(
              title: Text(l10n.adminEditTermTitle(semester)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.adminTermStartsOn),
                    subtitle: Text(dateFmt.format(startsOn)),
                    trailing: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    onTap: pickStart,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.adminTermEndsOn),
                    subtitle: Text(dateFmt.format(endsOn)),
                    trailing: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    onTap: pickEnd,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (endsOn.isBefore(startsOn)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminTermDatesInvalid)),
                      );
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await supabase.rpc(
        'admin_update_academic_term',
        params: {
          'p_term_id': termId,
          'p_starts_on': startsOn.toIso8601String().split('T').first,
          'p_ends_on': endsOn.toIso8601String().split('T').first,
        },
      );
      ref.invalidate(academicYearsProvider);
      ref.invalidate(academicTermOptionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminTermUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final years = ref.watch(academicYearsProvider);
    final dateFmt = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminAcademicYearsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _createNext,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(l10n.adminCreateNextYear),
      ),
      floatingActionButtonLocation: shellFabLocation(context),
      body: years.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: l10n.adminNoAcademicYears,
              subtitle: l10n.adminAcademicYearsHint,
              icon: Icons.calendar_month_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(academicYearsProvider);
              await ref.read(academicYearsProvider.future);
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                shellContentBottomPadding(context, hasFab: true),
              ),
              itemCount: list.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.adminAcademicYearsHint,
                      style: TextStyle(
                        color: AppColors.inkAlpha(context, 0.5),
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                final year = list[index - 1];
                return PremiumCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              year.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.adminDeleteYear,
                            onPressed: _busy ? null : () => _deleteYear(year),
                            icon: Icon(
                              Icons.delete_outline,
                              color: year.isCurrent
                                  ? AppColors.inkAlpha(context, 0.25)
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          if (year.isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent(
                                  context,
                                ).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accent(
                                    context,
                                  ).withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                l10n.adminCurrentYearBadge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent(context),
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _setCurrent(year.id),
                              child: Text(l10n.adminSetCurrentYear),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.adminYearSemesters,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkAlpha(context, 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final t in year.terms) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _busy ? null : () => _editTerm(t),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 2,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: AppColors.accent(context),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.adminSemesterRange(
                                          t.semester ?? 0,
                                          dateFmt.format(t.startInclusive!),
                                          dateFmt.format(t.endInclusive!),
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.ink(context),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AppColors.inkAlpha(context, 0.45),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
