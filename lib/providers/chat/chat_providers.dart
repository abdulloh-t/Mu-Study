import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/services/app_cache.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:mu_study/core/services/voice_cache_service.dart';
import 'package:mu_study/core/utils/voice_playback.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const chatSignedUrlTtlSeconds = 60 * 60 * 24 * 365 * 10;
const _pageSize = 40;
const _chatMessageSelect =
    '*, profiles(full_name, avatar_url, username, role), message_reads(user_id), message_reactions(id, message_id, user_id, emoji), reply_to:reply_to_message_id(id, message_type, text_content, media_url, is_deleted, sender_id, profiles(full_name, username, avatar_url))';

const chatReactionEmojis = ['❤️', '👍', '😂', '😮', '😢', '🔥'];

String chatBucketForType(ChatMessageType type) => switch (type) {
  ChatMessageType.image => 'chat-images',
  ChatMessageType.video => 'chat-videos',
  ChatMessageType.voice => 'chat-voices',
  ChatMessageType.file => 'chat-files',
  ChatMessageType.text => 'chat-images',
};

String chatContentType(ChatMessageType type, String fileName) {
  final lower = fileName.toLowerCase();
  return switch (type) {
    ChatMessageType.image =>
      lower.endsWith('.png')
          ? 'image/png'
          : lower.endsWith('.webp')
          ? 'image/webp'
          : lower.endsWith('.gif')
          ? 'image/gif'
          : 'image/jpeg',
    ChatMessageType.video =>
      lower.endsWith('.webm')
          ? 'video/webm'
          : lower.endsWith('.mov')
          ? 'video/quicktime'
          : 'video/mp4',
    ChatMessageType.voice =>
      lower.endsWith('.wav')
          ? 'audio/wav'
          : lower.endsWith('.mp3')
          ? 'audio/mpeg'
          : 'audio/mp4',
    ChatMessageType.file => _fileContentType(lower),
    ChatMessageType.text => 'text/plain',
  };
}

String _fileContentType(String lowerName) {
  if (lowerName.endsWith('.pdf')) return 'application/pdf';
  if (lowerName.endsWith('.zip')) return 'application/zip';
  if (lowerName.endsWith('.json')) return 'application/json';
  if (lowerName.endsWith('.csv')) return 'text/csv';
  if (lowerName.endsWith('.txt') ||
      lowerName.endsWith('.md') ||
      lowerName.endsWith('.py') ||
      lowerName.endsWith('.dart') ||
      lowerName.endsWith('.js') ||
      lowerName.endsWith('.ts') ||
      lowerName.endsWith('.html') ||
      lowerName.endsWith('.css') ||
      lowerName.endsWith('.sql')) {
    return 'text/plain';
  }
  if (lowerName.endsWith('.doc') || lowerName.endsWith('.docx')) {
    return 'application/msword';
  }
  if (lowerName.endsWith('.xls') || lowerName.endsWith('.xlsx')) {
    return 'application/vnd.ms-excel';
  }
  if (lowerName.endsWith('.ppt') || lowerName.endsWith('.pptx')) {
    return 'application/vnd.ms-powerpoint';
  }
  return 'application/octet-stream';
}

String chatVoiceContentType(Uint8List bytes, String fileName) {
  return detectAudioFormat(bytes).mimeType;
}

String chatVoiceFileName(Uint8List bytes, String fallbackName) {
  final format = detectAudioFormat(bytes);
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final base = fallbackName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  if (base.toLowerCase().endsWith('.${format.extension}')) return base;
  final withoutExt = base.contains('.')
      ? base.substring(0, base.lastIndexOf('.'))
      : base;
  final safe = withoutExt.isEmpty ? 'chat_voice_$stamp' : withoutExt;
  return '$safe.${format.extension}';
}

final chatRoomsProvider = StreamProvider<List<ChatRoomSummary>>((ref) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) {
    yield const [];
    return;
  }

  Future<List<ChatRoomSummary>> load() async {
    final rows = await supabase
        .from('chat_room_summaries')
        .select()
        .order('last_message_at', ascending: false, nullsFirst: false);

    final unreadRows =
        await supabase.rpc('chat_unread_counts') as List<dynamic>? ?? [];
    final unreadMap = <String, int>{};
    for (final row in unreadRows) {
      final map = Map<String, dynamic>.from(row as Map);
      final roomId = map['room_id'] as String?;
      if (roomId == null) continue;
      unreadMap[roomId] = (map['unread_count'] as num?)?.toInt() ?? 0;
    }

    final rooms = (rows as List)
        .map((e) => ChatRoomSummary.fromJson(Map<String, dynamic>.from(e)))
        .map((r) => r.copyWith(unreadCount: unreadMap[r.id] ?? 0))
        .toList();

    rooms.sort((a, b) {
      final aTime =
          a.lastMessageAt ??
          a.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.lastMessageAt ??
          b.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return rooms;
  }

  final changes = StreamController<void>();
  final channel = supabase
      .channel('chat-rooms-${profile.id}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (_) {
          if (!changes.isClosed) changes.add(null);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'message_reads',
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

final unreadChatCountProvider = Provider<int>((ref) {
  final rooms = ref.watch(chatRoomsProvider);
  return rooms.maybeWhen(
    data: (list) => list.fold<int>(0, (sum, r) => sum + r.unreadCount),
    orElse: () => 0,
  );
});

final chatRoomProvider = FutureProvider.family<ChatRoomSummary?, String>((
  ref,
  roomId,
) async {
  final rooms = ref.watch(chatRoomsProvider).valueOrNull;
  if (rooms != null) {
    for (final room in rooms) {
      if (room.id == roomId) return room;
    }
  }
  final row = await supabase
      .from('chat_room_summaries')
      .select()
      .eq('id', roomId)
      .maybeSingle();
  if (row == null) return null;
  return ChatRoomSummary.fromJson(Map<String, dynamic>.from(row));
});

class ChatMessagesState {
  const ChatMessagesState({
    required this.messages,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final bool loadingMore;

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class ChatMessagesNotifier
    extends FamilyAsyncNotifier<ChatMessagesState, String> {
  RealtimeChannel? _channel;
  final _profileCache = <String, Map<String, dynamic>>{};

  @override
  Future<ChatMessagesState> build(String roomId) async {
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile == null) {
      return const ChatMessagesState(messages: []);
    }

    final cache = ref.read(cacheServiceProvider).valueOrNull;
    List<ChatMessage>? cachedMessages;
    try {
      final raw = cache?.cachedChatMessages(roomId);
      if (raw != null && raw.isNotEmpty) {
        cachedMessages = raw.map(ChatMessage.fromJson).toList();
      }
    } catch (_) {}

    try {
      final initial = await _fetchPage(roomId, before: null);
      await _persistMessages(roomId, initial.items);
      prefetchChatMedia(initial.items);

      _channel = supabase
          .channel('chat-room-$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) => _onInsert(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) => _onUpdate(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) => _onDelete(payload.oldRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'message_reads',
            callback: (payload) => _onReadInsert(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'message_reactions',
            callback: (payload) => _onReactionUpsert(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'message_reactions',
            callback: (payload) => _onReactionUpsert(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'message_reactions',
            callback: (payload) => _onReactionDelete(payload.oldRecord),
          )
          .subscribe();

      ref.onDispose(() {
        final ch = _channel;
        if (ch != null) supabase.removeChannel(ch);
      });

      return ChatMessagesState(
        messages: initial.items,
        hasMore: initial.hasMore,
      );
    } catch (_) {
      if (cachedMessages != null) {
        prefetchChatMedia(cachedMessages);
        return ChatMessagesState(messages: cachedMessages, hasMore: true);
      }
      rethrow;
    }
  }

  Future<void> _persistMessages(
    String roomId,
    List<ChatMessage> messages,
  ) async {
    final cache = ref.read(cacheServiceProvider).valueOrNull;
    if (cache == null) return;
    try {
      await cache.cacheChatMessages(
        roomId,
        messages.map((m) => m.toCacheJson()).toList(),
      );
    } catch (_) {}
  }

  Future<void> _persistCurrent() async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _persistMessages(arg, current.messages);
  }

  Future<({List<ChatMessage> items, bool hasMore})> _fetchPage(
    String roomId, {
    required DateTime? before,
  }) async {
    var filtered = supabase
        .from('chat_messages')
        .select(_chatMessageSelect)
        .eq('room_id', roomId);

    if (before != null) {
      filtered = filtered.lt('created_at', before.toIso8601String());
    }

    final rows = await filtered
        .order('created_at', ascending: false)
        .limit(_pageSize + 1);
    final list = (rows as List)
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final hasMore = list.length > _pageSize;
    final page = hasMore ? list.sublist(0, _pageSize) : list;
    return (items: page.reversed.toList(), hasMore: hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    if (current.messages.isEmpty) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final oldest = current.messages.first.createdAt;
      final page = await _fetchPage(arg, before: oldest);
      final merged = [...page.items, ...current.messages];
      state = AsyncData(
        ChatMessagesState(
          messages: merged,
          hasMore: page.hasMore,
          loadingMore: false,
        ),
      );
      await _persistMessages(arg, merged);
      prefetchChatMedia(page.items);
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<void> _hydrateSender(Map<String, dynamic> row) async {
    final senderId = row['sender_id'] as String?;
    if (senderId == null || row['profiles'] != null) return;
    final cached = _profileCache[senderId];
    if (cached != null) {
      row['profiles'] = cached;
      return;
    }
    final profileRow = await supabase
        .from('profiles')
        .select('full_name, avatar_url, username, role')
        .eq('id', senderId)
        .maybeSingle();
    if (profileRow != null) {
      final map = Map<String, dynamic>.from(profileRow);
      _profileCache[senderId] = map;
      row['profiles'] = map;
    }
  }

  Future<void> _hydrateReply(Map<String, dynamic> row) async {
    final replyId = row['reply_to_message_id'] as String?;
    if (replyId == null || row['reply_to'] != null) return;

    final current = state.valueOrNull;
    final local = current?.messages.where((m) => m.id == replyId).firstOrNull;
    if (local != null) {
      row['reply_to'] = ChatReplyPreview.fromMessage(local).toCacheJson();
      return;
    }

    try {
      final data = await supabase
          .from('chat_messages')
          .select(
            'id, message_type, text_content, media_url, is_deleted, sender_id, profiles(full_name, username, avatar_url)',
          )
          .eq('id', replyId)
          .maybeSingle();
      if (data != null) {
        row['reply_to'] = Map<String, dynamic>.from(data);
      }
    } catch (_) {}
  }

  Future<void> _onInsert(Map<String, dynamic> record) async {
    final row = Map<String, dynamic>.from(record);
    await _hydrateSender(row);
    await _hydrateReply(row);
    final message = ChatMessage.fromJson(row);
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.messages.any((m) => m.id == message.id)) return;
    state = AsyncData(
      current.copyWith(messages: [...current.messages, message]),
    );
    prefetchChatMedia([message]);
    await _persistCurrent();
  }

  Future<void> _onUpdate(Map<String, dynamic> record) async {
    final row = Map<String, dynamic>.from(record);
    await _hydrateSender(row);
    final updated = ChatMessage.fromJson(row);
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.messages.map((m) {
      if (m.id != updated.id) return m;
      return updated.copyWith(
        senderName: updated.senderName ?? m.senderName,
        senderUsername: updated.senderUsername ?? m.senderUsername,
        senderAvatarUrl: updated.senderAvatarUrl ?? m.senderAvatarUrl,
        senderRole: updated.senderRole ?? m.senderRole,
        isReadByOthers: m.isReadByOthers || updated.isReadByOthers,
        reactions: updated.reactions.isEmpty ? m.reactions : updated.reactions,
        replyToMessageId: updated.replyToMessageId ?? m.replyToMessageId,
        replyTo: updated.replyTo ?? m.replyTo,
      );
    }).toList();
    state = AsyncData(current.copyWith(messages: next));
    await _persistCurrent();
  }

  void _onDelete(Map<String, dynamic> record) {
    final id = record['id'] as String?;
    if (id == null) return;
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        messages: current.messages.where((m) => m.id != id).toList(),
      ),
    );
    unawaited(_persistCurrent());
  }

  void _onReadInsert(Map<String, dynamic> record) {
    final messageId = record['message_id'] as String?;
    final readerId = record['user_id'] as String?;
    if (messageId == null || readerId == null) return;
    final current = state.valueOrNull;
    if (current == null) return;

    var changed = false;
    final next = current.messages.map((m) {
      if (m.id != messageId || m.isReadByOthers) return m;
      if (readerId == m.senderId) return m;
      changed = true;
      return m.copyWith(isReadByOthers: true);
    }).toList();

    if (changed) {
      state = AsyncData(current.copyWith(messages: next));
    }
  }

  void _onReactionUpsert(Map<String, dynamic> record) {
    final reaction = ChatReaction.fromJson(Map<String, dynamic>.from(record));
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.messages.any((m) => m.id == reaction.messageId)) return;

    final next = current.messages.map((m) {
      if (m.id != reaction.messageId) return m;
      final withoutUser = m.reactions
          .where((r) => r.userId != reaction.userId)
          .toList();
      return m.copyWith(reactions: [...withoutUser, reaction]);
    }).toList();
    state = AsyncData(current.copyWith(messages: next));
  }

  void _onReactionDelete(Map<String, dynamic> record) {
    final id = record['id'] as String?;
    final messageId = record['message_id'] as String?;
    final userId = record['user_id'] as String?;
    final current = state.valueOrNull;
    if (current == null) return;

    final next = current.messages.map((m) {
      if (messageId != null && m.id != messageId) return m;
      if (messageId == null &&
          id != null &&
          !m.reactions.any((r) => r.id == id)) {
        return m;
      }
      return m.copyWith(
        reactions: m.reactions.where((r) {
          if (id != null && r.id == id) return false;
          if (userId != null &&
              messageId != null &&
              r.userId == userId &&
              r.messageId == messageId) {
            return false;
          }
          return true;
        }).toList(),
      );
    }).toList();
    state = AsyncData(current.copyWith(messages: next));
  }

  Future<ChatMessage> sendText(String text, {String? replyToMessageId}) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) throw StateError('Not signed in');
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('Empty message');

    final row = await supabase
        .from('chat_messages')
        .insert({
          'room_id': arg,
          'sender_id': profile.id,
          'message_type': 'text',
          'text_content': trimmed,
          'reply_to_message_id': ?replyToMessageId,
        })
        .select(_chatMessageSelect)
        .single();

    final message = ChatMessage.fromJson(Map<String, dynamic>.from(row));
    final current = state.valueOrNull;
    if (current != null && !current.messages.any((m) => m.id == message.id)) {
      state = AsyncData(
        current.copyWith(messages: [...current.messages, message]),
      );
      await _persistCurrent();
    }
    return message;
  }

  Future<ChatMessage> sendMedia({
    required ChatMessageType type,
    required Uint8List bytes,
    required String fileName,
    String? caption,
    String? replyToMessageId,
    void Function(double progress)? onProgress,
  }) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) throw StateError('Not signed in');
    if (type == ChatMessageType.text) {
      throw ArgumentError('Use sendText for text messages');
    }

    onProgress?.call(0.05);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = type == ChatMessageType.voice
        ? chatVoiceFileName(bytes, fileName)
        : fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
    final path = '$arg/${profile.id}/${stamp}_$safeName';
    final bucket = chatBucketForType(type);
    final contentType = type == ChatMessageType.voice
        ? chatVoiceContentType(bytes, fileName)
        : chatContentType(type, fileName);

    await supabase.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: false, contentType: contentType),
        );
    onProgress?.call(0.7);

    final url = await supabase.storage
        .from(bucket)
        .createSignedUrl(path, chatSignedUrlTtlSeconds);
    onProgress?.call(0.85);

    if (type == ChatMessageType.voice) {
      final format = detectAudioFormat(bytes);
      await VoiceCacheService.instance.put(url, bytes, format.extension);
    } else {
      final ext = ChatMediaCacheService.extensionForUrl(
        url,
        fallback: safeName.contains('.') ? safeName.split('.').last : 'bin',
      );
      await ChatMediaCacheService.instance.put(url, bytes, ext);
    }

    final captionText = caption?.trim();
    final row = await supabase
        .from('chat_messages')
        .insert({
          'room_id': arg,
          'sender_id': profile.id,
          'message_type': chatMessageTypeToDb(type),
          'text_content': (captionText == null || captionText.isEmpty)
              ? null
              : captionText,
          'media_url': url,
          'reply_to_message_id': ?replyToMessageId,
        })
        .select(_chatMessageSelect)
        .single();
    onProgress?.call(1);

    final message = ChatMessage.fromJson(Map<String, dynamic>.from(row));
    final current = state.valueOrNull;
    if (current != null && !current.messages.any((m) => m.id == message.id)) {
      state = AsyncData(
        current.copyWith(messages: [...current.messages, message]),
      );
      await _persistCurrent();
    }
    return message;
  }

  Future<void> editMessage(String messageId, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) throw ArgumentError('Empty message');
    await supabase
        .from('chat_messages')
        .update({'text_content': trimmed})
        .eq('id', messageId);
  }

  Future<void> deleteMessage(String messageId) async {
    await deleteMessages([messageId]);
  }

  Future<void> deleteMessages(Iterable<String> messageIds) async {
    final ids = messageIds.toList();
    if (ids.isEmpty) return;

    final current = state.valueOrNull;
    if (current != null) {
      final idSet = ids.toSet();
      state = AsyncData(
        current.copyWith(
          messages: [
            for (final m in current.messages)
              if (idSet.contains(m.id))
                m.copyWith(isDeleted: true)
              else
                m,
          ],
        ),
      );
      await _persistCurrent();
    }

    await supabase.from('chat_messages').update({
      'is_deleted': true,
      'text_content': null,
      'media_url': null,
    }).inFilter('id', ids);
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) throw StateError('Not signed in');

    final current = state.valueOrNull;
    ChatMessage? message;
    if (current != null) {
      for (final m in current.messages) {
        if (m.id == messageId) {
          message = m;
          break;
        }
      }
    }
    final existing = message?.myReactionEmoji(profile.id);

    if (current != null && message != null) {
      final nextReactions = <ChatReaction>[
        for (final r in message.reactions)
          if (r.userId != profile.id) r,
      ];
      if (existing != emoji) {
        nextReactions.add(
          ChatReaction(
            id: 'local-${profile.id}',
            messageId: messageId,
            userId: profile.id,
            emoji: emoji,
          ),
        );
      }
      state = AsyncData(
        current.copyWith(
          messages: [
            for (final m in current.messages)
              if (m.id == messageId)
                m.copyWith(reactions: nextReactions)
              else
                m,
          ],
        ),
      );
    }

    await supabase.rpc(
      'toggle_message_reaction',
      params: {'p_message_id': messageId, 'p_emoji': emoji},
    );
  }

  Future<void> markRoomRead() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;

    final unread = await supabase
        .from('chat_messages')
        .select('id')
        .eq('room_id', arg)
        .eq('is_deleted', false)
        .neq('sender_id', profile.id);

    final ids = (unread as List)
        .map((e) => (e as Map)['id'] as String)
        .toList();
    if (ids.isEmpty) return;

    final existing = await supabase
        .from('message_reads')
        .select('message_id')
        .eq('user_id', profile.id)
        .inFilter('message_id', ids);
    final already = {
      for (final e in existing as List) (e as Map)['message_id'] as String,
    };
    final toInsert = ids
        .where((id) => !already.contains(id))
        .map((id) => {'message_id': id, 'user_id': profile.id})
        .toList();
    if (toInsert.isEmpty) return;

    await supabase
        .from('message_reads')
        .upsert(toInsert, onConflict: 'message_id,user_id');
    ref.invalidate(chatRoomsProvider);
  }
}

final chatMessagesProvider =
    AsyncNotifierProvider.family<
      ChatMessagesNotifier,
      ChatMessagesState,
      String
    >(ChatMessagesNotifier.new);
