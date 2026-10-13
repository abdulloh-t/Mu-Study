import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mu_study/components/chat/chat_media_gallery.dart';
import 'package:mu_study/core/services/chat_video_thumbnail_service.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class ChatVideo extends StatefulWidget {
  const ChatVideo({
    super.key,
    required this.url,
    this.galleryItems = const [],
    this.galleryIndex = -1,
  });

  final String url;
  final List<ChatMediaItem> galleryItems;
  final int galleryIndex;

  @override
  State<ChatVideo> createState() => _ChatVideoState();
}

class _ChatVideoState extends State<ChatVideo> {
  File? _thumb;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  @override
  void didUpdateWidget(covariant ChatVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _thumb = null;
      _loading = true;
      _loadThumb();
    }
  }

  Future<void> _loadThumb() async {
    final file = await ChatVideoThumbnailService.instance.getThumbnail(
      widget.url,
    );
    if (!mounted) return;
    setState(() {
      _thumb = file;
      _loading = false;
    });
  }

  void _openFullscreen() {
    final items = widget.galleryItems.isNotEmpty
        ? widget.galleryItems
        : [
            ChatMediaItem(
              id: widget.url,
              url: widget.url,
              kind: ChatMediaKind.video,
            ),
          ];
    final index = widget.galleryIndex >= 0 ? widget.galleryIndex : 0;
    showChatMediaGallery(context, items: items, initialIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMono ? 4 : 12),
      child: SizedBox(
        width: 220,
        height: 180,
        child: Material(
          color: const Color(0xFF1C1C1E),
          child: InkWell(
            onTap: _openFullscreen,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (_thumb != null)
                  Image.file(
                    _thumb!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: Color(0xFF2C2C2E)),
                  )
                else
                  ColoredBox(
                    color: const Color(0xFF2C2C2E),
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.videocam_rounded,
                            size: 44,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                  ),
                const ColoredBox(color: Color(0x33000000)),
                const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 52,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.l10n.chatPreviewVideo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
