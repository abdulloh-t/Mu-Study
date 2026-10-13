import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/screens/chat/room/helpers/reply_snippets.dart';

class ReplyComposerBanner extends StatelessWidget {
  const ReplyComposerBanner({
    super.key,
    required this.message,
    required this.onClose,
  });

  final ChatMessage message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = AppColors.accent(context);
    final name = message.displayName.isEmpty ? '…' : message.displayName;
    final snippet = chatReplySnippetFromMessage(context, message);
    final showThumb =
        message.messageType == ChatMessageType.image &&
        message.mediaUrl != null &&
        message.mediaUrl!.isNotEmpty;

    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final radius = isMono ? 4.0 : 14.0;
    return Material(
      color: AppColors.controlSurface(context),
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(isMono ? 1 : 2),
              ),
            ),
            const SizedBox(width: 8),
            if (showThumb) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(isMono ? 3 : 6),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      const SizedBox(width: 36, height: 36),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.chatReplyTo(name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.inkAlpha(context, 0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.inkAlpha(context, 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
