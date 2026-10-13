import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class ChatVideoThumbnailService {
  ChatVideoThumbnailService._();

  static final ChatVideoThumbnailService instance =
      ChatVideoThumbnailService._();

  static const _folder = 'chat_video_thumbs';
  static const maxWidth = 440;

  Directory? _dir;
  Future<void>? _initFuture;
  final _inflight = <String, Future<File?>>{};

  bool get isSupported => !kIsWeb;

  Future<void> _ensureReady() async {
    if (!isSupported) return;
    _initFuture ??= _init();
    await _initFuture;
  }

  Future<void> _init() async {
    final root = await getApplicationCacheDirectory();
    _dir = Directory(p.join(root.path, _folder));
    if (!await _dir!.exists()) {
      await _dir!.create(recursive: true);
    }
  }

  static String _hashKey(String url) => sha1
      .convert(utf8.encode(ChatMediaCacheService.keyForUrl(url)))
      .toString();

  File _thumbFile(String hash) => File(p.join(_dir!.path, '$hash.jpg'));

  Future<File?> getThumbnail(String url) {
    final key = ChatMediaCacheService.keyForUrl(url);
    return _inflight.putIfAbsent(key, () async {
      try {
        if (!isSupported) return null;
        await _ensureReady();
        final hash = _hashKey(url);
        final cached = _thumbFile(hash);
        if (await cached.exists() && await cached.length() > 0) {
          return cached;
        }

        final videoFile = await ChatMediaCacheService.instance.getOrFetch(
          url,
          preferredExtension: ChatMediaCacheService.extensionForUrl(
            url,
            fallback: 'mp4',
          ),
        );

        Uint8List? bytes;
        if (videoFile != null) {
          try {
            bytes = await VideoThumbnail.thumbnailData(
              video: videoFile.path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: maxWidth,
              quality: 75,
              timeMs: 0,
            );
          } catch (_) {}
        }
        if (bytes == null || bytes.isEmpty) {
          bytes = await VideoThumbnail.thumbnailData(
            video: url,
            imageFormat: ImageFormat.JPEG,
            maxWidth: maxWidth,
            quality: 75,
            timeMs: 0,
          );
        }

        if (bytes.isEmpty) return null;
        await cached.writeAsBytes(bytes, flush: true);
        return cached;
      } catch (_) {
        return null;
      } finally {
        _inflight.remove(key);
      }
    });
  }

  Future<void> prefetch(String url) async {
    try {
      await getThumbnail(url);
    } catch (_) {}
  }

  Future<void> clear() async {
    if (!isSupported) return;
    await _ensureReady();
    if (_dir != null && await _dir!.exists()) {
      try {
        await _dir!.delete(recursive: true);
      } catch (_) {}
    }
    _dir = null;
    _initFuture = null;
    _inflight.clear();
  }
}
