import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/chat/animated_emoji_message.dart';
import 'package:mu_study/components/chat/chat_lottie_emoji.dart';
import 'package:mu_study/components/chat/chat_media_gallery.dart';
import 'package:mu_study/core/chat/emoji_message.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/chat/chat_providers.dart';
import 'package:mu_study/screens/chat/room/widgets/chat_file.dart';
import 'package:mu_study/screens/chat/room/widgets/chat_image.dart';
import 'package:mu_study/screens/chat/room/widgets/chat_video.dart';
import 'package:mu_study/screens/chat/room/widgets/chat_voice.dart';
import 'package:mu_study/screens/chat/room/widgets/reply_quote.dart';
import 'package:mu_study/screens/chat/room/widgets/swipe_to_reply.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.myUserId,
    this.galleryItems = const [],
    this.highlighted = false,
    this.selectionMode = false,
    this.selected = false,
    this.selectable = false,
    this.onSelectionToggle,
    this.onSelect,
    this.onJumpToReply,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
  });

  final ChatMessage message;
  final bool isMine;
  final String? myUserId;
  final List<ChatMediaItem> galleryItems;
  final bool highlighted;
  final bool selectionMode;
  final bool selected;
  final bool selectable;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onSelect;
  final ValueChanged<String>? onJumpToReply;
  final VoidCallback? onReply;
  final ValueChanged<String>? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const _nameColors = [
    Color(0xFFE57373),
    Color(0xFF5B9BD5),
    Color(0xFF7CB342),
    Color(0xFFAB47BC),
    Color(0xFFFFB300),
    Color(0xFF26A69A),
    Color(0xFFEC407A),
    Color(0xFF42A5F5),
  ];

  static const _monoNameColors = [
    Color(0xFF111111),
    Color(0xFF3A3A3A),
    Color(0xFF5A5A5A),
    Color(0xFF7A7A7A),
    Color(0xFF2E2E2E),
    Color(0xFF4E4E4E),
  ];

  static const _monoNameColorsDark = [
    Color(0xFFF5F5F5),
    Color(0xFFD0D0D0),
    Color(0xFFB0B0B0),
    Color(0xFF909090),
    Color(0xFFE0E0E0),
    Color(0xFFC0C0C0),
  ];

  Color _senderColor(
    String senderId, {
    required bool monochrome,
    required bool isDark,
  }) {
    var hash = 0;
    for (final c in senderId.codeUnits) {
      hash = (hash + c) & 0x7fffffff;
    }
    final palette = monochrome
        ? (isDark ? _monoNameColorsDark : _monoNameColors)
        : _nameColors;
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AppStyleTokens.maybeOf(context);
    final isNeu = tokens?.isSoftNeumorphism ?? false;
    final isMono = tokens?.isMonochromeWorkspace ?? false;
    final time = DateFormat.Hm().format(message.createdAt.toLocal());
    final Color bubbleColor;
    final Color textColor;
    if (isNeu) {
      bubbleColor = isMine
          ? (isDark
                ? SoftNeumorphismColors.emerald
                : SoftNeumorphismColors.sage)
          : Neumorphic.surface(context, elevation: NeuElevation.raised);
      textColor = isMine
          ? (isDark
                ? const Color(0xFF0E1812)
                : SoftNeumorphismColors.morningSurfaceHigh)
          : scheme.onSurface;
    } else if (isMono) {
      bubbleColor = isMine
          ? AppColors.ink(context)
          : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04));
      textColor = isMine
          ? (isDark ? Colors.black : Colors.white)
          : scheme.onSurface;
    } else {
      bubbleColor = isMine
          ? (isDark ? const Color(0xFF3E2C23) : AppColors.coffeeBrown)
          : (isDark ? AppColors.darkSurfaceElevated : Colors.white);
      textColor = isMine
          ? (isDark ? AppColors.darkTextPrimary : Colors.white)
          : scheme.onSurface;
    }
    final myEmoji = message.myReactionEmoji(myUserId);
    final summary = message.reactionSummary;
    final hasReactions = summary.isNotEmpty;
    final isAnimatedEmoji =
        !message.isDeleted &&
        message.messageType == ChatMessageType.text &&
        isSingleAnimatedEmojiMessage(message.textContent);
    final isVoiceMessage =
        !message.isDeleted && message.messageType == ChatMessageType.voice;
    final voiceHasCaption =
        isVoiceMessage && (message.textContent?.trim().isNotEmpty ?? false);
    final voiceHasReply =
        isVoiceMessage &&
        (message.replyTo != null || message.replyToMessageId != null);
    final isStandaloneVoice =
        isVoiceMessage && !voiceHasCaption && !voiceHasReply;
    final metaColor = (isAnimatedEmoji || isStandaloneVoice)
        ? AppColors.inkAlpha(context, 0.45)
        : textColor.withValues(alpha: 0.65);

    Widget messageColumn({required Color bodyTextColor}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SenderHeader(
                message: message,
                nameColor: _senderColor(
                  message.senderId,
                  monochrome: isMono,
                  isDark: isDark,
                ),
              ),
            ),
          if (message.isDeleted)
            Text(
              context.l10n.chatMessageDeleted,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: bodyTextColor.withValues(alpha: 0.7),
              ),
            )
          else ...[
            if (message.replyTo != null || message.replyToMessageId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ReplyQuote(
                  reply: message.replyTo,
                  accent: isMono
                      ? bodyTextColor.withValues(alpha: 0.72)
                      : (isMine
                            ? (isDark
                                  ? const Color(0xFF9ED0FF)
                                  : Colors.white.withValues(alpha: 0.9))
                            : AppColors.accent(context)),
                  onSurface: bodyTextColor,
                  sharp: isMono,
                  onTap: () {
                    final id = message.replyTo?.id ?? message.replyToMessageId;
                    if (id != null) onJumpToReply?.call(id);
                  },
                ),
              ),
            MessageBody(
              message: message,
              textColor: bodyTextColor,
              galleryItems: galleryItems,
              timeLabel: time,
              isMine: isMine,
            ),
            if (message.textContent != null &&
                message.textContent!.isNotEmpty &&
                message.messageType != ChatMessageType.text &&
                message.messageType != ChatMessageType.file)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  message.textContent!,
                  style: TextStyle(color: bodyTextColor, height: 1.35),
                ),
              ),
          ],
          if (!isVoiceMessage || voiceHasCaption) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.wasEdited)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      context.l10n.chatEdited,
                      style: TextStyle(fontSize: 10, color: metaColor),
                    ),
                  ),
                Text(time, style: TextStyle(fontSize: 10, color: metaColor)),
                if (isMine && !message.isDeleted) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isReadByOthers
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 14,
                    color: message.isReadByOthers
                        ? (isMono
                              ? bodyTextColor.withValues(alpha: 0.72)
                              : const Color(0xFF9ED0FF))
                        : metaColor,
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    }

    final highlightAccent = AppColors.accent(context).withValues(alpha: 0.85);
    final highlightGlow = AppColors.accent(context).withValues(alpha: 0.35);

    Widget bubbleBody;
    if (isAnimatedEmoji || isStandaloneVoice) {
      final radius = BorderRadius.circular(
        isMono ? 6 : (isStandaloneVoice ? 999 : 24),
      );
      bubbleBody = AnimatedScale(
        scale: highlighted ? (isMono ? 1.02 : 1.06) : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: isMono ? Curves.easeOutCubic : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: highlighted ? highlightAccent : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: highlighted && !isMono
                ? [
                    BoxShadow(
                      color: highlightGlow,
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: messageColumn(bodyTextColor: textColor),
        ),
      );
    } else {
      final radius = isMono
          ? BorderRadius.only(
              topLeft: const Radius.circular(6),
              topRight: const Radius.circular(6),
              bottomLeft: Radius.circular(isMine ? 6 : 2),
              bottomRight: Radius.circular(isMine ? 2 : 6),
            )
          : BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMine ? 20 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 20),
            );
      final List<BoxShadow> bubbleShadows;
      if (isMono) {
        bubbleShadows = const [];
      } else if (highlighted) {
        bubbleShadows = [
          BoxShadow(
            color: highlightGlow,
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ];
      } else if (isNeu) {
        bubbleShadows = isMine
            ? [
                BoxShadow(
                  color: Neumorphic.shadowColor(
                    context,
                  ).withValues(alpha: isDark ? 0.45 : 0.20),
                  offset: const Offset(3, 4),
                  blurRadius: 10,
                ),
              ]
            : Neumorphic.shadows(
                context,
                elevation: NeuElevation.raised,
                intensity: 0.75,
              );
      } else {
        bubbleShadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      }
      final Color bubbleBorder;
      if (highlighted) {
        bubbleBorder = highlightAccent;
      } else if (isMono && !isMine) {
        bubbleBorder = AppColors.inkAlpha(context, 0.12);
      } else {
        bubbleBorder = Colors.transparent;
      }
      bubbleBody = AnimatedScale(
        scale: highlighted ? (isMono ? 1.01 : 1.03) : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: isMono ? Curves.easeOutCubic : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(
            isMono ? 12 : 12,
            isMono ? 9 : 8,
            isMono ? 12 : 12,
            isMono ? 7 : 6,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            border: Border.all(
              color: bubbleBorder,
              width: highlighted ? 1.5 : 1,
            ),
            boxShadow: bubbleShadows,
          ),
          child: messageColumn(bodyTextColor: textColor),
        ),
      );
    }

    final bubble = GestureDetector(
      onTap: selectionMode
          ? (selectable ? onSelectionToggle : null)
          : null,
      onLongPress: message.isDeleted
          ? null
          : selectionMode
          ? (selectable ? onSelectionToggle : null)
          : () {
              HapticFeedback.mediumImpact();
              _showActions(context);
            },
      child: bubbleBody,
    );

    final bubbleWithReactions = Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        bubble,
        if (hasReactions)
          Transform.translate(
            offset: const Offset(0, -6),
            child: Padding(
              padding: EdgeInsets.only(
                left: isMine ? 0 : 4,
                right: isMine ? 4 : 0,
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final item in summary)
                    ReactionPill(
                      emoji: item.emoji,
                      count: item.count,
                      mine: myEmoji == item.emoji,
                      onTap: onReact == null
                          ? null
                          : () => onReact!(item.emoji),
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mineMax = (constraints.maxWidth * 0.78).clamp(
          160.0,
          constraints.maxWidth,
        );
        final incomingMax = (constraints.maxWidth - 36).clamp(
          120.0,
          constraints.maxWidth * 0.85,
        );

        if (isMine) {
          final child = Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: mineMax),
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: hasReactions ? 10 : 4),
                child: bubbleWithReactions,
              ),
            ),
          );
          final wrapped = selectionMode && selectable
              ? _selectionRow(context, child)
              : child;
          if (onReply == null || selectionMode) return wrapped;
          return SwipeToReply(onReply: onReply!, child: wrapped);
        }

        final initials = message.displayName
            .trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

        final senderTone = _senderColor(
          message.senderId,
          monochrome: isMono,
          isDark: isDark,
        );
        final incomingAvatar = isMono
            ? Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: senderTone.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: senderTone.withValues(alpha: 0.28)),
                  image:
                      message.senderAvatarUrl != null &&
                          message.senderAvatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            message.senderAvatarUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    message.senderAvatarUrl == null ||
                        message.senderAvatarUrl!.isEmpty
                    ? Text(
                        initials.isEmpty ? '?' : initials,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: senderTone,
                        ),
                      )
                    : null,
              )
            : CircleAvatar(
                radius: 14,
                backgroundColor: senderTone.withValues(alpha: 0.22),
                backgroundImage:
                    message.senderAvatarUrl != null &&
                        message.senderAvatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(message.senderAvatarUrl!)
                    : null,
                child:
                    message.senderAvatarUrl == null ||
                        message.senderAvatarUrl!.isEmpty
                    ? Text(
                        initials.isEmpty ? '?' : initials,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: senderTone,
                        ),
                      )
                    : null,
              );

        final incoming = Padding(
          padding: EdgeInsets.only(top: 4, bottom: hasReactions ? 10 : 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              incomingAvatar,
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: incomingMax),
                    child: bubbleWithReactions,
                  ),
                ),
              ),
            ],
          ),
        );
        final wrapped = selectionMode && selectable
            ? _selectionRow(context, incoming)
            : incoming;
        if (onReply == null || selectionMode) return wrapped;
        return SwipeToReply(onReply: onReply!, child: wrapped);
      },
    );
  }

  Widget _selectionRow(BuildContext context, Widget child) {
    final accent = AppColors.accent(context);
    final muted = AppColors.inkAlpha(context, 0.35);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selectable ? onSelectionToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        color: selected ? accent.withValues(alpha: 0.08) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color: selectable
                  ? (selected ? accent : muted)
                  : muted.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            // Ignore media InkWells (files/images/video/voice) so taps select
            // the message instead of opening/downloading the attachment.
            Expanded(
              child: IgnorePointer(
                ignoring: selectable,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final origin = box.localToGlobal(Offset.zero);
    final rect = origin & box.size;
    final textToCopy = message.isDeleted ? null : message.textContent?.trim();
    final canCopy = textToCopy != null && textToCopy.isNotEmpty;

    late OverlayEntry entry;
    void dismiss() {
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: dismiss,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.42),
                  ),
                ),
              ),
              MessageActionPopover(
                anchorRect: rect,
                isMine: isMine,
                emojis: onReact == null ? const [] : chatReactionEmojis,
                onEmoji: onReact == null
                    ? null
                    : (emoji) {
                        dismiss();
                        onReact!(emoji);
                      },
                onReply: onReply == null
                    ? null
                    : () {
                        dismiss();
                        onReply!();
                      },
                onCopy: !canCopy
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: textToCopy));
                        dismiss();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.chatCopied)),
                          );
                        }
                      },
                onEdit: onEdit == null
                    ? null
                    : () {
                        dismiss();
                        onEdit!();
                      },
                onSelect: onSelect == null
                    ? null
                    : () {
                        dismiss();
                        onSelect!();
                      },
                onDelete: onDelete == null
                    ? null
                    : () {
                        dismiss();
                        onDelete!();
                      },
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(entry);
  }
}

class MessageActionPopover extends StatelessWidget {
  const MessageActionPopover({
    super.key,
    required this.anchorRect,
    required this.isMine,
    required this.emojis,
    this.onEmoji,
    this.onReply,
    this.onCopy,
    this.onEdit,
    this.onSelect,
    this.onDelete,
  });

  final Rect anchorRect;
  final bool isMine;
  final List<String> emojis;
  final ValueChanged<String>? onEmoji;
  final VoidCallback? onReply;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onSelect;
  final VoidCallback? onDelete;

  static const _menuWidth = 220.0;
  static const _reactionHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final screen = media.size;
    final pad = media.padding;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark
        ? const Color(0xE62A2F36)
        : Colors.white.withValues(alpha: 0.96);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final itemColor = isDark ? Colors.white : AppColors.darkChocolate;

    final reactionWidth = emojis.isEmpty ? 0.0 : (emojis.length * 48.0) + 20;
    final panelWidth = [
      if (emojis.isNotEmpty) reactionWidth,
      _menuWidth,
    ].fold<double>(0, (a, b) => a > b ? a : b);

    final itemCount = [
      onReply,
      onCopy,
      onEdit,
      onSelect,
      onDelete,
    ].where((callback) => callback != null).length;
    final menuHeight = itemCount * 44.0 + 8;
    final panelHeight =
        (emojis.isEmpty ? 0.0 : _reactionHeight + 8) + menuHeight;
    final bottomReserve = pad.bottom + media.viewInsets.bottom + 108;
    final spaceBelow = screen.height - bottomReserve - anchorRect.bottom;
    final spaceAbove = anchorRect.top - pad.top - 8;
    final placeAbove =
        spaceBelow < panelHeight + 12 && spaceAbove >= panelHeight * 0.45;
    final stackTop = placeAbove
        ? (anchorRect.top - panelHeight - 10).clamp(
            pad.top + 8,
            math.max(pad.top + 8, screen.height - panelHeight - bottomReserve),
          )
        : (anchorRect.bottom + 10).clamp(
            pad.top + 8,
            math.max(pad.top + 8, screen.height - panelHeight - bottomReserve),
          );

    var left = isMine ? anchorRect.right - panelWidth : anchorRect.left;
    left = left.clamp(12.0, screen.width - panelWidth - 12);

    Widget menuDivider() =>
        Divider(height: 1, thickness: 1, color: dividerColor);

    final menuItems = <Widget>[
      if (onReply != null)
        PopoverMenuItem(
          icon: Icons.reply_rounded,
          label: l10n.chatReply,
          color: itemColor,
          onTap: onReply!,
        ),
      if (onReply != null &&
          (onCopy != null ||
              onEdit != null ||
              onSelect != null ||
              onDelete != null))
        menuDivider(),
      if (onCopy != null)
        PopoverMenuItem(
          icon: Icons.copy_rounded,
          label: l10n.chatCopyText,
          color: itemColor,
          onTap: onCopy!,
        ),
      if (onEdit != null)
        PopoverMenuItem(
          icon: Icons.edit_outlined,
          label: l10n.commonEdit,
          color: itemColor,
          onTap: onEdit!,
        ),
      if (onSelect != null)
        PopoverMenuItem(
          icon: Icons.check_circle_outline_rounded,
          label: l10n.chatSelect,
          color: itemColor,
          onTap: onSelect!,
        ),
      if (onDelete != null) ...[
        if (onReply != null ||
            onCopy != null ||
            onEdit != null ||
            onSelect != null)
          menuDivider(),
        PopoverMenuItem(
          icon: Icons.delete_outline_rounded,
          label: l10n.commonDelete,
          color: AppColors.errorRed,
          onTap: onDelete!,
        ),
      ],
    ];

    return Positioned(
      left: left,
      top: stackTop.toDouble(),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emojis.isNotEmpty)
              ReactionBar(
                emojis: emojis,
                surface: surface,
                onEmoji: onEmoji!,
                showCaretBelow: placeAbove,
                isMine: isMine,
              ),
            if (emojis.isNotEmpty && menuItems.isNotEmpty)
              const SizedBox(height: 8),
            if (menuItems.isNotEmpty)
              Builder(
                builder: (context) {
                  final isMono =
                      AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ??
                      false;
                  return Container(
                    width: _menuWidth,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(isMono ? 6 : 16),
                      border: isMono
                          ? Border.all(color: AppColors.inkAlpha(context, 0.12))
                          : null,
                      boxShadow: isMono
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: menuItems,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.emojis,
    required this.surface,
    required this.onEmoji,
    required this.showCaretBelow,
    required this.isMine,
  });

  final List<String> emojis;
  final Color surface;
  final ValueChanged<String> onEmoji;
  final bool showCaretBelow;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final barRadius = isMono ? 6.0 : 999.0;
    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!showCaretBelow)
          Padding(
            padding: EdgeInsets.only(
              left: isMine ? 0 : 22,
              right: isMine ? 22 : 0,
            ),
            child: CustomPaint(
              size: const Size(14, 7),
              painter: CaretPainter(color: surface, pointUp: true),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(barRadius),
            border: isMono
                ? Border.all(color: AppColors.inkAlpha(context, 0.12))
                : null,
            boxShadow: isMono
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final emoji in emojis)
                InkWell(
                  borderRadius: BorderRadius.circular(isMono ? 4 : 20),
                  onTap: () => onEmoji(emoji),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: ChatLottieEmoji(
                      emoji: emoji,
                      size: 32,
                      playOnTap: false,
                      repeat: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showCaretBelow)
          Padding(
            padding: EdgeInsets.only(
              left: isMine ? 0 : 22,
              right: isMine ? 22 : 0,
            ),
            child: CustomPaint(
              size: const Size(14, 7),
              painter: CaretPainter(color: surface, pointUp: false),
            ),
          ),
      ],
    );
  }
}

class CaretPainter extends CustomPainter {
  const CaretPainter({required this.color, required this.pointUp});

  final Color color;
  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CaretPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointUp != pointUp;
}

class PopoverMenuItem extends StatelessWidget {
  const PopoverMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionPill extends StatelessWidget {
  const ReactionPill({
    super.key,
    required this.emoji,
    required this.count,
    required this.mine,
    this.onTap,
  });

  final String emoji;
  final int count;
  final bool mine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final Color fill;
    final Color border;
    if (mine) {
      fill = AppColors.accent(context).withValues(alpha: isDark ? 0.32 : 0.20);
      border = AppColors.accent(context).withValues(alpha: 0.85);
    } else {
      fill = isDark
          ? AppColors.darkSurfaceHighest
          : AppColors.sand.withValues(alpha: 0.95);
      border = AppColors.inkAlpha(context, 0.12);
    }
    final chipRadius = isMono ? 4.0 : 999.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(chipRadius),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(chipRadius),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChatLottieEmoji(emoji: emoji, size: 20, repeat: false),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: mine
                      ? AppColors.accent(context)
                      : AppColors.ink(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SenderHeader extends StatelessWidget {
  const SenderHeader({
    super.key,
    required this.message,
    required this.nameColor,
  });

  final ChatMessage message;
  final Color nameColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = message.displayName;
    if (name.isEmpty) return const SizedBox.shrink();

    final role = message.senderRole;
    final tagLabel = switch (role) {
      UserRole.admin => l10n.chatRoleAdmin,
      UserRole.teacher => l10n.chatRoleTeacher,
      _ => null,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: nameColor,
            ),
          ),
        ),
        if (tagLabel != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: nameColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(
                (AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ??
                        false)
                    ? 3
                    : 8,
              ),
            ),
            child: Text(
              tagLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: nameColor.withValues(alpha: 0.95),
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class MessageBody extends StatelessWidget {
  const MessageBody({
    super.key,
    required this.message,
    required this.textColor,
    this.galleryItems = const [],
    this.timeLabel = '',
    this.isMine = false,
  });

  final ChatMessage message;
  final Color textColor;
  final List<ChatMediaItem> galleryItems;
  final String timeLabel;
  final bool isMine;

  int get _galleryIndex =>
      galleryItems.indexWhere((item) => item.id == message.id);

  @override
  Widget build(BuildContext context) {
    return switch (message.messageType) {
      ChatMessageType.text => _buildTextBody(),
      ChatMessageType.image => ChatImage(
        url: message.mediaUrl!,
        galleryItems: galleryItems,
        galleryIndex: _galleryIndex,
      ),
      ChatMessageType.video => ChatVideo(
        url: message.mediaUrl!,
        galleryItems: galleryItems,
        galleryIndex: _galleryIndex,
      ),
      ChatMessageType.voice => ChatVoice(
        url: message.mediaUrl!,
        timeLabel: timeLabel,
        isMine: isMine,
        isReadByOthers: message.isReadByOthers,
      ),
      ChatMessageType.file => ChatFile(
        url: message.mediaUrl!,
        fileName: message.textContent?.trim().isNotEmpty == true
            ? message.textContent!.trim()
            : 'file',
        color: textColor,
      ),
    };
  }

  Widget _buildTextBody() {
    final text = message.textContent ?? '';
    final asset = singleAnimatedEmojiAsset(text);
    final emoji = singleAnimatedEmojiGrapheme(text);
    if (asset != null && emoji != null) {
      return AnimatedEmojiMessage(
        key: ValueKey('anim-emoji-${message.id}'),
        assetPath: asset,
        emoji: emoji,
        size: 144,
      );
    }
    return Text(
      text,
      style: TextStyle(color: textColor, height: 1.35, fontSize: 15),
    );
  }
}
