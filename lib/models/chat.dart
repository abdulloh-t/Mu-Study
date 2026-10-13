import 'package:mu_study/models/enums.dart';

class ChatRoomSummary {
  const ChatRoomSummary({
    required this.id,
    required this.groupId,
    required this.groupTitle,
    required this.teacherName,
    required this.memberCount,
    this.createdAt,
    this.lastMessageId,
    this.lastMessageType,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageDeleted = false,
    this.lastMessageSenderId,
    this.lastMessageSenderName,
    this.unreadCount = 0,
  });

  final String id;
  final String groupId;
  final String groupTitle;
  final String teacherName;
  final int memberCount;
  final DateTime? createdAt;
  final String? lastMessageId;
  final ChatMessageType? lastMessageType;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final bool lastMessageDeleted;
  final String? lastMessageSenderId;
  final String? lastMessageSenderName;
  final int unreadCount;

  ChatRoomSummary copyWith({int? unreadCount}) {
    return ChatRoomSummary(
      id: id,
      groupId: groupId,
      groupTitle: groupTitle,
      teacherName: teacherName,
      memberCount: memberCount,
      createdAt: createdAt,
      lastMessageId: lastMessageId,
      lastMessageType: lastMessageType,
      lastMessageText: lastMessageText,
      lastMessageAt: lastMessageAt,
      lastMessageDeleted: lastMessageDeleted,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageSenderName: lastMessageSenderName,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['last_message_type'] as String?;
    return ChatRoomSummary(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      groupTitle: json['group_title'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastMessageId: json['last_message_id'] as String?,
      lastMessageType: typeRaw == null
          ? null
          : chatMessageTypeFromString(typeRaw),
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessageDeleted: json['last_message_deleted'] as bool? ?? false,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageSenderName: json['last_message_sender_name'] as String?,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.messageType,
    this.textContent,
    this.mediaUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.senderName,
    this.senderUsername,
    this.senderAvatarUrl,
    this.senderRole,
    this.isReadByOthers = false,
    this.reactions = const [],
    this.replyToMessageId,
    this.replyTo,
  });

  final String id;
  final String roomId;
  final String senderId;
  final ChatMessageType messageType;
  final String? textContent;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String? senderName;
  final String? senderUsername;
  final String? senderAvatarUrl;
  final UserRole? senderRole;

  final bool isReadByOthers;

  final List<ChatReaction> reactions;

  final String? replyToMessageId;

  final ChatReplyPreview? replyTo;

  String get displayName {
    final name = senderName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final user = senderUsername?.trim() ?? '';
    if (user.isNotEmpty) {
      return user.startsWith('@') ? user.substring(1) : user;
    }
    return '';
  }

  bool get wasEdited =>
      !isDeleted && updatedAt.difference(createdAt).inSeconds.abs() > 1;

  List<({String emoji, int count})> get reactionSummary {
    final counts = <String, int>{};
    final order = <String>[];
    for (final r in reactions) {
      if (!counts.containsKey(r.emoji)) order.add(r.emoji);
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
    }
    return [for (final emoji in order) (emoji: emoji, count: counts[emoji]!)];
  }

  String? myReactionEmoji(String? userId) {
    if (userId == null) return null;
    for (final r in reactions) {
      if (r.userId == userId) return r.emoji;
    }
    return null;
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'message_type': messageType.name,
      'text_content': textContent,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'reply_to_message_id': replyToMessageId,
      if (replyTo != null) 'reply_to': replyTo!.toCacheJson(),
      'profiles': {
        'full_name': senderName,
        'username': senderUsername,
        'avatar_url': senderAvatarUrl,
        if (senderRole != null) 'role': senderRole!.name,
      },
      'message_reads': [
        if (isReadByOthers) {'user_id': 'cached_other'},
      ],
      'message_reactions': [
        for (final r in reactions)
          {
            'id': r.id,
            'message_id': r.messageId,
            'user_id': r.userId,
            'emoji': r.emoji,
          },
      ],
    };
  }

  ChatMessage copyWith({
    String? textContent,
    String? mediaUrl,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isReadByOthers,
    String? senderName,
    String? senderUsername,
    String? senderAvatarUrl,
    UserRole? senderRole,
    List<ChatReaction>? reactions,
    String? replyToMessageId,
    ChatReplyPreview? replyTo,
  }) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      messageType: messageType,
      textContent: textContent ?? this.textContent,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      senderName: senderName ?? this.senderName,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      senderRole: senderRole ?? this.senderRole,
      isReadByOthers: isReadByOthers ?? this.isReadByOthers,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyTo: replyTo ?? this.replyTo,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map?;
    final senderId = json['sender_id'] as String;
    final reads = json['message_reads'] as List?;
    final isReadByOthers =
        reads?.any((r) {
          if (r is! Map) return false;
          final readerId = r['user_id'] as String?;
          return readerId != null && readerId != senderId;
        }) ??
        false;

    final reactionRows = json['message_reactions'] as List?;
    final reactions =
        reactionRows
            ?.whereType<Map>()
            .map((r) => ChatReaction.fromJson(Map<String, dynamic>.from(r)))
            .toList() ??
        const <ChatReaction>[];

    final roleRaw = profile?['role'] as String?;

    ChatReplyPreview? replyTo;
    final replyRaw = json['reply_to'];
    if (replyRaw is Map) {
      replyTo = ChatReplyPreview.fromJson(Map<String, dynamic>.from(replyRaw));
    }

    return ChatMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: senderId,
      messageType: chatMessageTypeFromString(json['message_type'] as String?),
      textContent: json['text_content'] as String?,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ??
            json['created_at'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      isDeleted: json['is_deleted'] as bool? ?? false,
      senderName: profile?['full_name'] as String?,
      senderUsername: profile?['username'] as String?,
      senderAvatarUrl: profile?['avatar_url'] as String?,
      senderRole: roleRaw != null ? userRoleFromString(roleRaw) : null,
      isReadByOthers: isReadByOthers,
      reactions: reactions,
      replyToMessageId: json['reply_to_message_id'] as String?,
      replyTo: replyTo,
    );
  }
}

class ChatReplyPreview {
  const ChatReplyPreview({
    required this.id,
    required this.messageType,
    this.textContent,
    this.mediaUrl,
    this.isDeleted = false,
    required this.senderId,
    this.senderName,
    this.senderUsername,
    this.senderAvatarUrl,
  });

  final String id;
  final ChatMessageType messageType;
  final String? textContent;
  final String? mediaUrl;
  final bool isDeleted;
  final String senderId;
  final String? senderName;
  final String? senderUsername;
  final String? senderAvatarUrl;

  String get displayName {
    final name = senderName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final user = senderUsername?.trim() ?? '';
    if (user.isNotEmpty) {
      return user.startsWith('@') ? user.substring(1) : user;
    }
    return '';
  }

  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'message_type': messageType.name,
    'text_content': textContent,
    'media_url': mediaUrl,
    'is_deleted': isDeleted,
    'sender_id': senderId,
    'profiles': {
      'full_name': senderName,
      'username': senderUsername,
      'avatar_url': senderAvatarUrl,
    },
  };

  factory ChatReplyPreview.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map?;
    return ChatReplyPreview(
      id: json['id'] as String,
      messageType: chatMessageTypeFromString(json['message_type'] as String?),
      textContent: json['text_content'] as String?,
      mediaUrl: json['media_url'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      senderId: json['sender_id'] as String? ?? '',
      senderName: profile?['full_name'] as String?,
      senderUsername: profile?['username'] as String?,
      senderAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  factory ChatReplyPreview.fromMessage(ChatMessage message) {
    return ChatReplyPreview(
      id: message.id,
      messageType: message.messageType,
      textContent: message.textContent,
      mediaUrl: message.mediaUrl,
      isDeleted: message.isDeleted,
      senderId: message.senderId,
      senderName: message.senderName,
      senderUsername: message.senderUsername,
      senderAvatarUrl: message.senderAvatarUrl,
    );
  }
}

class ChatReaction {
  const ChatReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
  });

  final String id;
  final String messageId;
  final String userId;
  final String emoji;

  factory ChatReaction.fromJson(Map<String, dynamic> json) {
    return ChatReaction(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
    );
  }
}
