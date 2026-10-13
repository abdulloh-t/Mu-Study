import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((
  ref,
) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) {
    yield [];
    return;
  }

  final cache = ref.watch(cacheServiceProvider).valueOrNull;

  Future<List<AppNotification>> load() async {
    final rows = await supabase
        .from('notifications')
        .select()
        .eq('user_id', profile.id)
        .order('created_at', ascending: false)
        .limit(50);
    final list = rows.map((e) => Map<String, dynamic>.from(e)).toList();
    await cache?.cacheNotifications(list);
    return list.map(AppNotification.fromJson).toList();
  }

  final changes = StreamController<void>();
  final channel = supabase
      .channel('notifications-${profile.id}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: profile.id,
        ),
        callback: (_) {
          if (!changes.isClosed) changes.add(null);
        },
      )
      .subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel);
    changes.close();
  });

  yield await load();

  await for (final _ in changes.stream) {
    yield await load();
  }
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

final announcementsProvider =
    FutureProvider.family<List<Announcement>, String?>((ref, groupId) async {
      var query = supabase.from('announcements').select();
      if (groupId != null) query = query.eq('group_id', groupId);
      final rows = await query.order('created_at', ascending: false);
      return rows
          .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

Future<void> markNotificationRead(String id) async {
  await supabase.from('notifications').update({'is_read': true}).eq('id', id);
}

Future<void> markAllNotificationsRead(String userId) async {
  await supabase
      .from('notifications')
      .update({'is_read': true})
      .eq('user_id', userId)
      .eq('is_read', false);
}
