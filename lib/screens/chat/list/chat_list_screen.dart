import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/components/layouts/shell_nav_bar.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/chat/chat_providers.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key, required this.basePath});

  final String basePath;

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _preview(ChatRoomSummary room, AppLocalizations l10n) {
    if (room.lastMessageId == null) return l10n.chatNoMessagesYet;
    if (room.lastMessageDeleted) return l10n.chatMessageDeleted;
    return switch (room.lastMessageType) {
      ChatMessageType.image => l10n.chatPreviewImage,
      ChatMessageType.video => l10n.chatPreviewVideo,
      ChatMessageType.voice => l10n.chatPreviewVoice,
      ChatMessageType.file =>
        room.lastMessageText?.trim().isNotEmpty == true
            ? room.lastMessageText!.trim()
            : l10n.chatPreviewFile,
      ChatMessageType.text || null =>
        room.lastMessageText?.trim().isNotEmpty == true
            ? room.lastMessageText!.trim()
            : l10n.chatNoMessagesYet,
    };
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateFormat.Hm().format(local);
    }
    if (now.difference(local).inDays < 7) {
      return DateFormat.E().format(local);
    }
    return DateFormat.MMMd().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roomsAsync = ref.watch(chatRoomsProvider);
    final isNeu = Neumorphic.isActive(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: NeuSearchField(
                    controller: _search,
                    hintText: l10n.chatSearchHint,
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
                if (isNaturePaper(context))
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: PaperDecor(
                      PaperAssets.tealBird,
                      size: 36,
                      angle: -0.06,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: roomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.commonErrorWithDetails('$e'))),
              data: (rooms) {
                final filtered = _query.isEmpty
                    ? rooms
                    : rooms
                          .where(
                            (r) =>
                                r.groupTitle.toLowerCase().contains(_query) ||
                                r.teacherName.toLowerCase().contains(_query),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.chatEmptyTitle,
                    subtitle: l10n.chatEmptySubtitle,
                  );
                }

                return ListView.separated(
                  clipBehavior: isNeu ? Clip.none : Clip.hardEdge,
                  padding: EdgeInsets.fromLTRB(
                    isNeu ? 16 : 12,
                    isNeu ? 4 : 0,
                    isNeu ? 16 : 12,
                    shellContentBottomPadding(context),
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(height: isNeu ? 4 : 4),
                  itemBuilder: (context, index) {
                    final room = filtered[index];
                    return _ChatRoomTile(
                          room: room,
                          preview: _preview(room, l10n),
                          timeLabel: _formatTime(room.lastMessageAt),
                          onTap: () =>
                              context.push('${widget.basePath}/${room.id}'),
                        )
                        .animate()
                        .fadeIn(duration: 220.ms, delay: (20 * index).ms)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: 280.ms,
                          delay: (20 * index).ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomTile extends ConsumerWidget {
  const _ChatRoomTile({
    required this.room,
    required this.preview,
    required this.timeLabel,
    required this.onTap,
  });

  final ChatRoomSummary room;
  final String preview;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final me = ref.watch(currentProfileProvider).valueOrNull;
    final unread = room.unreadCount;
    final l10n = context.l10n;
    final isNeu = Neumorphic.isActive(context);
    final accent = AppColors.accent(context);

    final avatarLetter = Text(
      room.groupTitle.isNotEmpty
          ? room.groupTitle.characters.first.toUpperCase()
          : '?',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: accent,
        fontSize: 18,
      ),
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNeu ? 4 : 0,
        vertical: isNeu ? 2 : 0,
      ),
      child: Row(
        children: [
          if (isNeu)
            NeuAvatar(child: avatarLetter)
          else
            CircleAvatar(
              radius: 26,
              backgroundColor: accent.withValues(alpha: 0.18),
              child: avatarLetter,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.groupTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: unread > 0
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                      ),
                    ),
                    if (timeLabel.isNotEmpty)
                      Text(
                        timeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: unread > 0
                              ? AppColors.goldAccent(context)
                              : scheme.onSurface.withValues(alpha: 0.45),
                          fontWeight: unread > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.chatTeacherMembers(room.teacherName, room.memberCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.lastMessageSenderId != null &&
                                room.lastMessageSenderId == me?.id
                            ? '${l10n.chatYou}: $preview'
                            : preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: scheme.onSurface.withValues(
                            alpha: unread > 0 ? 0.9 : 0.65,
                          ),
                        ),
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent(context),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: isNeu
                              ? [
                                  BoxShadow(
                                    color: Neumorphic.shadowColor(
                                      context,
                                    ).withValues(alpha: 0.35),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1A1408)
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isNeu) {
      return PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        elevation: NeuElevation.raised,
        child: content,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? scheme.surfaceContainerHigh : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: content,
        ),
      ),
    );
  }
}
