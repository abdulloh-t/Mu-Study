import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/components/chat/chat_media_gallery.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';

class ChatImage extends StatefulWidget {
  const ChatImage({
    super.key,
    required this.url,
    this.galleryItems = const [],
    this.galleryIndex = -1,
  });

  final String url;
  final List<ChatMediaItem> galleryItems;
  final int galleryIndex;

  @override
  State<ChatImage> createState() => _ChatImageState();
}

class _ChatImageState extends State<ChatImage> {
  File? _cachedFile;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ChatImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _cachedFile = null;
      _resolving = true;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (kIsWeb || !ChatMediaCacheService.instance.isSupported) {
      if (mounted) setState(() => _resolving = false);
      return;
    }
    final file = await ChatMediaCacheService.instance.getOrFetch(
      widget.url,
      preferredExtension: ChatMediaCacheService.extensionForUrl(
        widget.url,
        fallback: 'jpg',
      ),
    );
    if (!mounted) return;
    setState(() {
      _cachedFile = file;
      _resolving = false;
    });
  }

  Widget _buildImage({required BoxFit fit, double? width, double? height}) {
    final file = _cachedFile;
    if (file != null) {
      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => SizedBox(
        width: width ?? 220,
        height: height ?? 180,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving && _cachedFile == null) {
      return const SizedBox(
        width: 220,
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMono ? 4 : 12),
      child: GestureDetector(
        onTap: () {
          final items = widget.galleryItems.isNotEmpty
              ? widget.galleryItems
              : [
                  ChatMediaItem(
                    id: widget.url,
                    url: widget.url,
                    kind: ChatMediaKind.image,
                  ),
                ];
          final index = widget.galleryIndex >= 0 ? widget.galleryIndex : 0;
          showChatMediaGallery(context, items: items, initialIndex: index);
        },
        child: _buildImage(fit: BoxFit.cover, width: 220, height: 180),
      ),
    );
  }
}
