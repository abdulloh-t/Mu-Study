import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/attendance/attendance_calendar_grid.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState
    extends ConsumerState<TeacherAttendanceScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, AttendanceStatus> _edits = {};
  String? _editedGroupId;
  bool _saving = false;
  late final TabController _tabs;
  late DateTime _month;
  String? _historyStudentId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  AttendanceStatus _statusFor(
    String studentId,
    Map<String, AttendanceStatus> saved,
  ) {
    return _edits[studentId] ?? saved[studentId] ?? AttendanceStatus.present;
  }

  void _resetEditsIfGroupChanged(String groupId) {
    if (_editedGroupId != groupId) {
      _edits.clear();
      _editedGroupId = groupId;
      _historyStudentId = null;
    }
  }

  void _markAll(List<GroupMember> members, AttendanceStatus status) {
    setState(() {
      for (final m in members) {
        _edits[m.studentId] = status;
      }
    });
  }

  Future<void> _saveAll(
    String groupId,
    List<GroupMember> members,
    Map<String, AttendanceStatus> saved,
  ) async {
    if (members.isEmpty) return;
    setState(() => _saving = true);

    try {
      final byStudent = {
        for (final m in members) m.studentId: _statusFor(m.studentId, saved),
      };
      await upsertAttendanceBulk(
        groupId: groupId,
        date: DateTime.now(),
        byStudentId: byStudent,
      );

      ref.invalidate(todayAttendanceProvider(groupId));
      ref.invalidate(attendanceWeekTrendProvider(groupId));
      ref.invalidate(attendanceRangeProvider);
      _edits.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.attendanceSaved)));
      }
    } on AttendanceWeekendException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attendanceWeekendNotAllowed)),
        );
      }
    } on AttendanceFutureDateException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attendanceFutureNotAllowed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonErrorWithDetails('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cycleHistoryDay({
    required String groupId,
    required String studentId,
    required DateTime day,
    required AttendanceStatus? current,
  }) async {
    if (!isAttendanceDateAllowed(day)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAttendanceWeekend(day)
                  ? context.l10n.attendanceWeekendNotAllowed
                  : context.l10n.attendanceFutureNotAllowed,
            ),
          ),
        );
      }
      return;
    }
    final next = nextAttendanceStatus(current);
    try {
      await upsertAttendance(
        groupId: groupId,
        studentId: studentId,
        status: next,
        date: day,
      );
      ref.invalidate(todayAttendanceProvider(groupId));
      ref.invalidate(attendanceWeekTrendProvider(groupId));
      ref.invalidate(attendanceRangeProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.attendanceUpdated)));
      }
    } on AttendanceWeekendException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attendanceWeekendNotAllowed)),
        );
      }
    } on AttendanceFutureDateException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attendanceFutureNotAllowed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonErrorWithDetails('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(activeGroupIdProvider);
    final l10n = context.l10n;
    final canMarkToday = isAttendanceDateAllowed(DateTime.now());

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.attendanceMark)),
        body: EmptyState(title: l10n.attendanceNoGroups),
      );
    }

    _resetEditsIfGroupChanged(groupId);

    final members = ref.watch(groupMembersProvider(groupId));
    final saved = ref.watch(todayAttendanceProvider(groupId));
    final memberList = members.valueOrNull ?? const <GroupMember>[];
    final historyStudentId =
        _historyStudentId ??
        (memberList.isEmpty ? null : memberList.first.studentId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendanceTitle),
        actions: [
          if (_tabs.index == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Builder(
                builder: (context) {
                  final isMono =
                      AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ??
                      false;
                  return FilledButton(
                    onPressed:
                        !canMarkToday ||
                            _saving ||
                            members.valueOrNull == null
                        ? null
                        : () => _saveAll(
                            groupId,
                            members.value!,
                            saved.valueOrNull ?? const {},
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent(context),
                      foregroundColor: AppColors.onAccent(context),
                      disabledBackgroundColor: AppColors.inkAlpha(
                        context,
                        0.12,
                      ),
                      disabledForegroundColor: AppColors.inkAlpha(
                        context,
                        0.35,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMono ? 4 : 12),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onAccent(context),
                            ),
                          )
                        : Text(l10n.commonSave),
                  );
                },
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: l10n.attendanceMark),
            Tab(text: l10n.attendanceHistory),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          members.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(message: e.toString()),
            data: (list) {
              final savedMap =
                  saved.valueOrNull ?? const <String, AttendanceStatus>{};
              return Column(
                children: [
                  const GroupSelector(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          DateFormat.yMMMMd().format(DateTime.now()),
                          style: TextStyle(
                            color: AppColors.inkAlpha(context, 0.5),
                            fontSize: 13,
                          ),
                        ),
                        if (!canMarkToday) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.attendanceWeekendNotAllowed,
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.55),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _BulkActions(
                          onPresent: !canMarkToday
                              ? null
                              : () =>
                                    _markAll(list, AttendanceStatus.present),
                          onLate: !canMarkToday
                              ? null
                              : () => _markAll(list, AttendanceStatus.late),
                          onAbsent: !canMarkToday
                              ? null
                              : () =>
                                    _markAll(list, AttendanceStatus.absent),
                          onExcused: !canMarkToday
                              ? null
                              : () =>
                                    _markAll(list, AttendanceStatus.excused),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: list.isEmpty
                        ? EmptyState(
                            title: l10n.marksNoStudents,
                            icon: Icons.person_off_outlined,
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              shellContentBottomPadding(context),
                            ),
                            children: [
                              PremiumCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: List.generate(list.length, (index) {
                                    final member = list[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: AppColors.inkAlpha(
                                                    context,
                                                    0.3,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      member.fullName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: AppColors.ink(
                                                          context,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      member.username,
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.inkAlpha(
                                                              context,
                                                              0.4,
                                                            ),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _AttendanceToggle(
                                                status: _statusFor(
                                                  member.studentId,
                                                  savedMap,
                                                ),
                                                onChanged: !canMarkToday
                                                    ? null
                                                    : (s) => setState(
                                                        () => _edits[member
                                                                .studentId] =
                                                            s,
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index < list.length - 1)
                                          Divider(
                                            height: 1,
                                            indent: 20,
                                            endIndent: 20,
                                            color: AppColors.inkAlpha(
                                              context,
                                              0.12,
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _LegendItem(
                                    label: l10n.attendancePresent,
                                    color: AppColors.successGreen,
                                  ),
                                  _LegendItem(
                                    label: l10n.attendanceLate,
                                    color: AppColors.warmAmber,
                                  ),
                                  _LegendItem(
                                    label: l10n.attendanceAbsent,
                                    color: AppColors.errorRed,
                                  ),
                                  _LegendItem(
                                    label: l10n.attendanceExcused,
                                    color: const Color(0xFF5B8DB8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
          _TeacherAttendanceHistoryTab(
            groupId: groupId,
            members: memberList,
            month: _month,
            selectedStudentId: historyStudentId,
            onMonthChanged: (m) => setState(() => _month = m),
            onStudentChanged: (id) => setState(() => _historyStudentId = id),
            onDayTap: (day, current) {
              if (historyStudentId == null) return;
              _cycleHistoryDay(
                groupId: groupId,
                studentId: historyStudentId,
                day: day,
                current: current,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeacherAttendanceHistoryTab extends ConsumerWidget {
  const _TeacherAttendanceHistoryTab({
    required this.groupId,
    required this.members,
    required this.month,
    required this.selectedStudentId,
    required this.onMonthChanged,
    required this.onStudentChanged,
    required this.onDayTap,
  });

  final String groupId;
  final List<GroupMember> members;
  final DateTime month;
  final String? selectedStudentId;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<String?> onStudentChanged;
  final void Function(DateTime day, AttendanceStatus? current) onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (members.isEmpty) {
      return EmptyState(
        title: l10n.marksNoStudents,
        icon: Icons.person_off_outlined,
      );
    }

    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);
    final query = AttendanceQuery(
      groupId: groupId,
      studentId: selectedStudentId,
      from: from,
      to: to,
    );
    final records = ref.watch(attendanceRangeProvider(query));
    final stats = ref.watch(attendanceRangeStatsProvider(query));

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        shellContentBottomPadding(context, extra: 16),
      ),
      children: [
        const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: selectedStudentId,
          decoration: InputDecoration(labelText: l10n.attendanceSelectStudent),
          items: [
            for (final m in members)
              DropdownMenuItem(value: m.studentId, child: Text(m.fullName)),
          ],
          onChanged: onStudentChanged,
        ),
        const SizedBox(height: 8),
        AttendanceMonthHeader(
          month: month,
          onPrev: () => onMonthChanged(DateTime(month.year, month.month - 1)),
          onNext: () => onMonthChanged(DateTime(month.year, month.month + 1)),
        ),
        const SizedBox(height: 8),
        stats.when(
          data: (s) => AttendanceStatsBar(stats: s),
          loading: () => const SizedBox(height: 56),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.attendanceTapToCycle,
          style: TextStyle(
            color: AppColors.inkAlpha(context, 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        PremiumCard(
          child: records.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
            data: (list) {
              final byDate = <DateTime, AttendanceStatus>{
                for (final r in list)
                  DateTime(r.date.year, r.date.month, r.date.day): r.status,
              };
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AttendanceCalendarGrid(
                    month: month,
                    statusByDate: byDate,
                    editable: selectedStudentId != null,
                    onDayTap: selectedStudentId == null
                        ? null
                        : (day) => onDayTap(
                            day,
                            byDate[DateTime(day.year, day.month, day.day)],
                          ),
                  ),
                  const SizedBox(height: 16),
                  const AttendanceLegendRow(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BulkActions extends StatelessWidget {
  const _BulkActions({
    required this.onPresent,
    required this.onLate,
    required this.onAbsent,
    required this.onExcused,
  });

  final VoidCallback? onPresent;
  final VoidCallback? onLate;
  final VoidCallback? onAbsent;
  final VoidCallback? onExcused;

  static const _excusedBlue = Color(0xFF5B8DB8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 4,
      runSpacing: 0,
      children: [
        TextButton.icon(
          onPressed: onPresent,
          icon: const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.successGreen,
          ),
          label: Text(
            l10n.attendanceAllPresent,
            style: const TextStyle(
              color: AppColors.successGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onLate,
          icon: const Icon(
            Icons.schedule,
            size: 18,
            color: AppColors.warmAmber,
          ),
          label: Text(
            l10n.attendanceAllLate,
            style: const TextStyle(
              color: AppColors.warmAmber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAbsent,
          icon: const Icon(
            Icons.highlight_off,
            size: 18,
            color: AppColors.errorRed,
          ),
          label: Text(
            l10n.attendanceAllAbsent,
            style: const TextStyle(
              color: AppColors.errorRed,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onExcused,
          icon: const Icon(
            Icons.event_available_outlined,
            size: 18,
            color: _excusedBlue,
          ),
          label: Text(
            l10n.attendanceAllExcused,
            style: const TextStyle(
              color: _excusedBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  const _AttendanceToggle({required this.status, required this.onChanged});

  final AttendanceStatus? status;
  final ValueChanged<AttendanceStatus>? onChanged;

  static const _excusedBlue = Color(0xFF5B8DB8);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          label: context.l10n.attendancePresentShort,
          isSelected: status == AttendanceStatus.present,
          activeColor: AppColors.successGreen,
          onTap: onChanged == null
              ? null
              : () => onChanged!(AttendanceStatus.present),
        ),
        const SizedBox(width: 6),
        _StatusButton(
          label: context.l10n.attendanceLateShort,
          isSelected: status == AttendanceStatus.late,
          activeColor: AppColors.warmAmber,
          onTap: onChanged == null
              ? null
              : () => onChanged!(AttendanceStatus.late),
        ),
        const SizedBox(width: 6),
        _StatusButton(
          label: context.l10n.attendanceAbsentShort,
          isSelected: status == AttendanceStatus.absent,
          activeColor: AppColors.errorRed,
          onTap: onChanged == null
              ? null
              : () => onChanged!(AttendanceStatus.absent),
        ),
        const SizedBox(width: 6),
        _StatusButton(
          label: context.l10n.attendanceExcusedShort,
          isSelected: status == AttendanceStatus.excused,
          activeColor: _excusedBlue,
          onTap: onChanged == null
              ? null
              : () => onChanged!(AttendanceStatus.excused),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.controlSurface(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.inkAlpha(context, 0.25),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.inkAlpha(context, 0.55),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.inkAlpha(context, 0.6),
          ),
        ),
      ],
    );
  }
}
