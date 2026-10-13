import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService(this._prefs);

  final SharedPreferences _prefs;

  static const _profileKey = 'cached_profile';
  static const _notificationsKey = 'cached_notifications';
  static const _assignmentsKey = 'cached_assignments';
  static const _dashboardKey = 'cached_dashboard';
  static const _chatRoomIdsKey = 'cached_chat_room_ids';

  static String _chatMessagesKey(String roomId) =>
      'cached_chat_messages_$roomId';

  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    await _prefs.setString(key, jsonEncode(items));
  }

  List<Map<String, dynamic>>? readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> cacheProfile(Map<String, dynamic> profile) =>
      saveJson(_profileKey, profile);

  Map<String, dynamic>? get cachedProfile => readJson(_profileKey);

  Future<void> cacheNotifications(List<Map<String, dynamic>> items) =>
      saveList(_notificationsKey, items);

  List<Map<String, dynamic>>? get cachedNotifications =>
      readList(_notificationsKey);

  Future<void> cacheAssignments(List<Map<String, dynamic>> items) =>
      saveList(_assignmentsKey, items);

  List<Map<String, dynamic>>? get cachedAssignments =>
      readList(_assignmentsKey);

  Future<void> cacheDashboard(Map<String, dynamic> data) =>
      saveJson(_dashboardKey, data);

  Map<String, dynamic>? get cachedDashboard => readJson(_dashboardKey);

  Future<void> cacheChatMessages(
    String roomId,
    List<Map<String, dynamic>> rows,
  ) async {
    await saveList(_chatMessagesKey(roomId), rows);
    final ids = _prefs.getStringList(_chatRoomIdsKey) ?? <String>[];
    if (!ids.contains(roomId)) {
      await _prefs.setStringList(_chatRoomIdsKey, [...ids, roomId]);
    }
  }

  List<Map<String, dynamic>>? cachedChatMessages(String roomId) =>
      readList(_chatMessagesKey(roomId));

  Future<void> clearChatMessageCaches() async {
    final ids = _prefs.getStringList(_chatRoomIdsKey) ?? <String>[];
    for (final id in ids) {
      await _prefs.remove(_chatMessagesKey(id));
    }
    await _prefs.remove(_chatRoomIdsKey);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_profileKey);
    await _prefs.remove(_notificationsKey);
    await _prefs.remove(_assignmentsKey);
    await _prefs.remove(_dashboardKey);
    await clearChatMessageCaches();
  }
}

final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return CacheService(prefs);
});
