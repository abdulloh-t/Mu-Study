import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: EmptyState(
          title: l10n.adminActivityLog,
          subtitle: l10n.adminActivityLogSubtitle,
          icon: Icons.history,
        ),
      ),
    );
  }
}
