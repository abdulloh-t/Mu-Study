import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/inputs/load_more_button.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:mu_study/core/admin/credential_slips_source.dart';
import 'package:mu_study/screens/admin/helpers/admin_labels.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  Future<void> _createUser() async {
    final username = TextEditingController(text: '@');
    final password = TextEditingController();
    final name = TextEditingController();
    var role = UserRole.student;
    var sphere = Sphere.math;
    String? selectedGroupId;

    final groupsRes = await supabase.from('groups').select('id, title');
    final groups = groupsRes as List<dynamic>;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final l10n = ctx.l10n;
          return AlertDialog(
            title: Text(l10n.adminCreateUser),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      labelText: l10n.loginUsername,
                      hintText: '@username',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: password,
                    decoration: InputDecoration(labelText: l10n.adminPassword),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(labelText: l10n.adminFullName),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    initialValue: role,
                    decoration: InputDecoration(labelText: l10n.adminRole),
                    items: UserRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(localizedRole(l10n, r).toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => role = v ?? UserRole.student),
                  ),
                  if (role == UserRole.teacher) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Sphere>(
                      initialValue: sphere,
                      decoration: InputDecoration(labelText: l10n.adminSphere),
                      items: Sphere.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.l10nLabel(l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setLocal(() => sphere = v ?? Sphere.math),
                    ),
                  ],
                  if (role == UserRole.student) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGroupId,
                      decoration: InputDecoration(
                        labelText: l10n.adminInitialGroupOptional,
                      ),
                      items: groups
                          .map(
                            (g) => DropdownMenuItem(
                              value: g['id'] as String,
                              child: Text(g['title'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => selectedGroupId = v),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final userId = await supabase.rpc(
                      'admin_create_user',
                      params: {
                        'p_username': username.text.trim(),
                        'p_password': password.text,
                        'p_full_name': name.text.trim(),
                        'p_role': role.name,
                        if (role == UserRole.teacher) 'p_sphere': sphere.name,
                      },
                    );

                    if (role == UserRole.student && selectedGroupId != null) {
                      final studentRes = await supabase
                          .from('students')
                          .select('id')
                          .eq('profile_id', userId)
                          .single();
                      final studentId = studentRes['id'] as String;

                      await supabase.from('group_students').insert({
                        'group_id': selectedGroupId,
                        'student_id': studentId,
                      });
                    }

                    await saveLoginPassword(
                      userId: '$userId',
                      password: password.text,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(allProfilesProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminUserCreated)),
                      );
                    }
                  } on PostgrestException catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(
                        ctx,
                      ).showSnackBar(SnackBar(content: Text(e.message)));
                    }
                  }
                },
                child: Text(l10n.adminCreateUserButton),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _resetPassword(Profile profile) async {
    final password = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.adminResetPasswordTitle(profile.username)),
          content: TextField(
            controller: password,
            decoration: InputDecoration(labelText: l10n.adminPassword),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.rpc(
                  'admin_reset_password',
                  params: {
                    'p_user_id': profile.id,
                    'p_password': password.text,
                  },
                );
                await saveLoginPassword(
                  userId: profile.id,
                  password: password.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.commonReset),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleDisable(Profile profile) async {
    await supabase
        .from('profiles')
        .update({'is_disabled': !profile.isDisabled})
        .eq('id', profile.id);
    ref.invalidate(allProfilesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(allProfilesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUsers)),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: profiles.when(
        data: (page) {
          final list = page.items;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              shellContentBottomPadding(context, hasFab: true),
            ),
            itemCount: list.length + (page.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == list.length) {
                return LoadMoreButton(
                  hasMore: page.hasMore,
                  loading: page.loadingMore,
                  onPressed: () =>
                      ref.read(allProfilesProvider.notifier).loadMore(),
                );
              }
              final p = list[i];
              return PremiumCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: p.isDisabled
                        ? Colors.grey
                        : AppColors.coffeeBrown,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    p.fullName.isNotEmpty ? p.fullName : p.username,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    l10n.adminRoleLine(
                      localizedRole(l10n, p.role).toUpperCase(),
                      p.username,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'reset') _resetPassword(p);
                      if (v == 'disable') _toggleDisable(p);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'reset',
                        child: Text(l10n.adminResetPassword),
                      ),
                      PopupMenuItem(
                        value: 'disable',
                        child: Text(
                          p.isDisabled ? l10n.adminEnable : l10n.adminDisable,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
