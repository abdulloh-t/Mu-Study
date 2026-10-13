import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/admin/credential_slips_pdf.dart';
import 'package:mu_study/core/admin/credential_slips_source.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/enums.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:share_plus/share_plus.dart';

class AdminCredentialPrintScreen extends ConsumerStatefulWidget {
  const AdminCredentialPrintScreen({super.key});

  @override
  ConsumerState<AdminCredentialPrintScreen> createState() =>
      _AdminCredentialPrintScreenState();
}

class _AdminCredentialPrintScreenState
    extends ConsumerState<AdminCredentialPrintScreen> {
  UserRole _role = UserRole.student;
  String? _groupId;
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final l10n = context.l10n;
    try {
      final slips = await fetchCredentialSlips(
        role: _role,
        groupId: _role == UserRole.student ? _groupId : null,
      );
      if (slips.isEmpty) {
        throw Exception(l10n.adminCredentialNeedUsers);
      }
      final bytes = buildCredentialSlipsPdf(slips, l10n);
      const fileName = 'mu_study_login_slips.pdf';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'application/pdf', name: fileName),
          ],
          fileNameOverrides: [fileName],
          subject: l10n.adminCredentialPrintTitle,
          downloadFallbackEnabled: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is Exception
          ? e.toString().replaceFirst(RegExp(r'^Exception: '), '')
          : '$e';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = ref.watch(adminGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminCredentialPrintTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          shellContentBottomPadding(context, extra: 24),
        ),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminCredentialPrintSubtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkAlpha(context, 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<UserRole>(
                  segments: [
                    ButtonSegment(
                      value: UserRole.student,
                      label: Text(l10n.adminCredentialStudents),
                    ),
                    ButtonSegment(
                      value: UserRole.teacher,
                      label: Text(l10n.adminCredentialTeachers),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (next) {
                    setState(() {
                      _role = next.first;
                      if (_role != UserRole.student) _groupId = null;
                    });
                  },
                ),
                if (_role == UserRole.student) ...[
                  const SizedBox(height: 16),
                  groups.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (rows) => DropdownButtonFormField<String?>(
                      key: ValueKey(_groupId),
                      initialValue: _groupId,
                      decoration: InputDecoration(
                        labelText: l10n.adminGroups,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.adminCredentialAllGroups),
                        ),
                        ...rows.map(
                          (g) => DropdownMenuItem<String?>(
                            value: g['id'] as String,
                            child: Text(g['title'] as String? ?? ''),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _groupId = value),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      _exporting
                          ? l10n.commonLoading
                          : l10n.adminCredentialExportPdf,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PreviewList(
            role: _role,
            groupId: _role == UserRole.student ? _groupId : null,
          ),
        ],
      ),
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({required this.role, required this.groupId});

  final UserRole role;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder(
      key: ValueKey('${role.name}-${groupId ?? 'all'}'),
      future: fetchCredentialSlipPreviews(role: role, groupId: groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return ErrorState(message: '${snapshot.error}');
        }
        final slips = snapshot.data ?? const [];
        if (slips.isEmpty) {
          return EmptyState(
            icon: Icons.print_outlined,
            title: l10n.adminCredentialNeedUsers,
          );
        }
        return PremiumCard(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            children: [
              for (final slip in slips)
                ListTile(
                  dense: true,
                  title: Text(
                    slip.fullName.isEmpty ? slip.username : slip.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(slip.username),
                ),
            ],
          ),
        );
      },
    );
  }
}
