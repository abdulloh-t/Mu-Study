import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/screens/chat/room/helpers/reply_snippets.dart';

class ReplyQuote extends StatelessWidget {
  const ReplyQuote({
    super.key,
    required this.reply,
    required this.accent,
    required this.onSurface,
    this.sharp = false,
    this.onTap,
  });

  final ChatReplyPreview? reply;
  final Color accent;
  final Color onSurface;
  final bool sharp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = (reply?.displayName ?? '').trim().isEmpty
        ? '…'
        : reply!.displayName;
    final snippet = chatReplySnippet(context, reply);
    final showThumb =
        reply != null &&
        !reply!.isDeleted &&
        reply!.messageType == ChatMessageType.image &&
        reply!.mediaUrl != null &&
        reply!.mediaUrl!.isNotEmpty;
    final radius = sharp ? 4.0 : 10.0;

    return Material(
      color: onSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: showThumb ? 36 : 32,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(sharp ? 1 : 2),
                ),
              ),
              const SizedBox(width: 8),
              if (showThumb) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(sharp ? 3 : 5),
                  child: CachedNetworkImage(
                    imageUrl: reply!.mediaUrl!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        const SizedBox(width: 32, height: 32),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chatReplyTo(name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      snippet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
