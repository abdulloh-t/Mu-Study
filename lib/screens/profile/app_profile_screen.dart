import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/settings/language_settings_tile.dart';
import 'package:mu_study/core/marks/academic_term.dart';
import 'package:mu_study/core/progress/progress_report_share.dart';
import 'package:mu_study/core/services/app_cache.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/attendance/attendance_providers.dart';
import 'package:mu_study/providers/marks/marks_providers.dart';
import 'package:mu_study/screens/profile/widgets/profile_hero_card.dart';
import 'package:mu_study/screens/profile/widgets/profile_settings_row.dart';
import 'package:mu_study/screens/profile/widgets/profile_theme_selector.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProfileScreen extends ConsumerWidget {
  const AppProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (p) {
          if (p == null) {
            return EmptyState(title: l10n.profileNotSignedIn);
          }
          return _ProfileBody(profile: p);
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  String _version = '—';
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) setState(() => _version = info.version);
        })
        .catchError((_) {});
  }

  String get _roleBasePath => switch (widget.profile.role) {
    UserRole.student => '/student',
    UserRole.teacher => '/teacher',
    UserRole.admin => '/admin',
  };

  List<_Shortcut> get _shortcuts {
    final l10n = context.l10n;
    final base = _roleBasePath;
    return switch (widget.profile.role) {
      UserRole.student => [
        _Shortcut(
          Icons.self_improvement_outlined,
          l10n.navFocus,
          '$base/focus',
        ),
        _Shortcut(Icons.grade_outlined, l10n.marksTitle, '$base/marks'),
        _Shortcut(
          Icons.assignment_outlined,
          l10n.assignmentsTitle,
          '$base/assignments',
        ),
        _Shortcut(
          Icons.event_available_outlined,
          l10n.attendanceTitle,
          '$base/attendance',
        ),
        _Shortcut(Icons.chat_outlined, l10n.navChat, '$base/chat'),
      ],
      UserRole.teacher => [
        _Shortcut(
          Icons.event_available_outlined,
          l10n.attendanceTitle,
          '$base/attendance',
        ),
        _Shortcut(Icons.grade_outlined, l10n.teacherGradebook, '$base/marks'),
        _Shortcut(
          Icons.assignment_outlined,
          l10n.assignmentsTitle,
          '$base/assignments',
        ),
        _Shortcut(Icons.chat_outlined, l10n.navChat, '$base/chat'),
      ],
      UserRole.admin => [
        _Shortcut(Icons.people_outline, l10n.navUsers, '$base/users'),
        _Shortcut(Icons.groups_outlined, l10n.navGroups, '$base/groups'),
        _Shortcut(
          Icons.calendar_month_outlined,
          l10n.adminAcademicYears,
          '$base/academic-years',
        ),
        _Shortcut(
          Icons.campaign_outlined,
          l10n.announcementsTitle,
          '$base/announcements',
        ),
        _Shortcut(
          Icons.notifications_outlined,
          l10n.profileNotifications,
          '$base/notifications',
        ),
      ],
    };
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    final l10n = context.l10n;
    try {
      final bytes = await file.readAsBytes();
      final path = '${widget.profile.id}/avatar.jpg';
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(path);
      final stamped = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      await ref.read(profileRepositoryProvider).updateProfile(
        widget.profile.id,
        {'avatar_url': stamped},
      );
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profilePhotoUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _editName() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: widget.profile.fullName);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileEditName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.profileFullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (saved == null || saved.isEmpty || !mounted) return;
    if (saved == widget.profile.fullName) return;

    try {
      await ref.read(profileRepositoryProvider).updateProfile(
        widget.profile.id,
        {'full_name': saved},
      );
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileNameUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _changePassword() async {
    final l10n = context.l10n;
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.profileChangePassword),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: current,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.profileCurrentPassword,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: next,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.profileNewPassword,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirm,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.profileConfirmPassword,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profilePasswordHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      ctx,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final n = next.text;
                      if (n.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.profilePasswordTooShort)),
                        );
                        return;
                      }
                      if (n != confirm.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.profilePasswordMismatch)),
                        );
                        return;
                      }
                      setLocal(() => saving = true);
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .changePassword(
                              username: widget.profile.username,
                              currentPassword: current.text,
                              newPassword: n,
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.profilePasswordChanged)),
                        );
                      } catch (e) {
                        setLocal(() => saving = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.commonCouldNotSave('$e')),
                          ),
                        );
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCachedData() async {
    final l10n = context.l10n;

    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileClearCacheWarn1Title),
        content: Text(l10n.profileClearCacheWarn1Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(l10n.profileClearCacheConfirm),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileClearCacheWarn2Title),
        content: Text(l10n.profileClearCacheWarn2Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(l10n.profileClearCacheConfirm),
          ),
        ],
      ),
    );
    if (second != true || !mounted) return;

    try {
      final cache = ref.read(cacheServiceProvider).valueOrNull;
      await clearChatAndMediaCaches(cache);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileClearCacheDone)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _shareProgress() async {
    final l10n = context.l10n;
    final groupId = ref.read(activeGroupIdProvider);
    final student = await ref.read(studentProfileProvider.future);
    if (groupId == null || student == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.progressReportNeedGroup)));
      return;
    }
    final groups = ref.read(myGroupsProvider).valueOrNull ?? const [];
    final groupTitle =
        groups.where((g) => g.id == groupId).map((g) => g.title).firstOrNull ??
        'group';
    try {
      await shareProgressReport(
        studentId: student.id,
        groupId: groupId,
        studentName: widget.profile.fullName.isNotEmpty
            ? widget.profile.fullName
            : widget.profile.username,
        groupTitle: groupTitle,
        term: ref.read(selectedMarkTermProvider),
        l10n: l10n,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.progressReportFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = ref.watch(myGroupsProvider).valueOrNull ?? const [];
    final teacher = ref.watch(teacherProfileProvider).valueOrNull;
    final student = ref.watch(studentProfileProvider).valueOrNull;
    final average = widget.profile.role == UserRole.student
        ? ref.watch(myMarkAverageProvider).valueOrNull
        : null;
    final groupId = ref.watch(activeGroupIdProvider);
    AttendanceStats? attStats;
    if (widget.profile.role == UserRole.student &&
        student != null &&
        groupId != null) {
      final now = DateTime.now();
      final query = AttendanceQuery(
        groupId: groupId,
        studentId: student.id,
        from: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 120)),
        to: DateTime(now.year, now.month, now.day),
      );
      attStats = ref.watch(attendanceRangeStatsProvider(query)).valueOrNull;
    }

    final roleLabel = switch (widget.profile.role) {
      UserRole.student => l10n.commonStudent,
      UserRole.teacher => l10n.commonTeacher,
      UserRole.admin => l10n.commonAdmin,
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        shellContentBottomPadding(context, extra: 24),
      ),
      children: [
        ProfileHeroCard(
          profile: widget.profile,
          roleLabel: roleLabel,
          sphereLabel: teacher == null
              ? null
              : '${l10n.profileSubject}: ${teacher.sphere.l10nLabel(l10n)}',
          uploading: _uploadingAvatar,
          onEditPhoto: _pickAvatar,
          onEditName: _editName,
        ),
        const SizedBox(height: 20),
        if (widget.profile.role != UserRole.admin) ...[
          PremiumSectionHeader(
            title: l10n.profileYourGroups,
            subtitle: groups.isEmpty
                ? l10n.profileNoGroups
                : l10n.profileGroupsCount(groups.length),
            decorAsset: PaperAssets.bookshelfDouble,
          ),
          PremiumCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: groups.isEmpty
                ? Text(
                    l10n.profileNoGroups,
                    style: TextStyle(color: AppColors.inkAlpha(context, 0.5)),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < groups.length; i++) ...[
                        if (i > 0) const Divider(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 18,
                              color: AppColors.accent(context),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                groups[i].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (groupId == groups[i].id)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.successGreen,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
          if (widget.profile.role == UserRole.student) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: l10n.profileAverageLabel,
                    value: average == null
                        ? '—'
                        : '${average.toStringAsFixed(average % 1 == 0 ? 0 : 1)}%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: l10n.profileAttendanceLabel,
                    value: attStats == null || attStats.total == 0
                        ? '—'
                        : '${attStats.presentPercent.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            PremiumCard(
              onTap: _shareProgress,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.ios_share_rounded,
                    color: AppColors.accent(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.profileShareProgress,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.inkAlpha(context, 0.35),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
        PremiumSectionHeader(
          title: l10n.profileShortcuts,
          decorAsset: PaperAssets.puzzlePieces,
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: [
            for (final s in _shortcuts)
              PremiumCard(
                onTap: () => context.push(s.path),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    PaperGlyph(
                      icon: s.icon,
                      color: AppColors.accent(context),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        PremiumSectionHeader(
          title: l10n.profileSettings,
          decorAsset: PaperAssets.settingsGear,
        ),
        PremiumCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: LanguageSettingsTile(embedded: true),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ProfileThemeSelector(),
              ),
              const Divider(height: 1),
              ProfileSettingsRow(
                icon: Icons.notifications_outlined,
                label: l10n.profileNotifications,
                onTap: () => context.push('$_roleBasePath/notifications'),
              ),
              const Divider(height: 1),
              ProfileSettingsRow(
                icon: Icons.badge_outlined,
                label: l10n.profileEditName,
                onTap: _editName,
              ),
              const Divider(height: 1),
              ProfileSettingsRow(
                icon: Icons.lock_outline,
                label: l10n.profileChangePassword,
                onTap: _changePassword,
              ),
              const Divider(height: 1),
              ProfileSettingsRow(
                icon: Icons.cleaning_services_outlined,
                label: l10n.profileClearCache,
                onTap: _clearCachedData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed.withValues(alpha: 0.9),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: Text(
              widget.profile.role == UserRole.admin
                  ? l10n.profileSignOutAdmin
                  : l10n.commonSignOut,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.profileAppVersion(_version),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.inkAlpha(context, 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _Shortcut {
  const _Shortcut(this.icon, this.label, this.path);
  final IconData icon;
  final String label;
  final String path;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.inkAlpha(context, 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.ink(context),
            ),
          ),
        ],
      ),
    );
  }
}
