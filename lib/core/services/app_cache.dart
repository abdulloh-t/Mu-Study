import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:mu_study/core/services/chat_video_thumbnail_service.dart';
import 'package:mu_study/core/services/voice_cache_service.dart';
import 'package:mu_study/models/models.dart';

Future<void> clearChatAndMediaCaches(CacheService? prefsCache) async {
  await prefsCache?.clearChatMessageCaches();
  await VoiceCacheService.instance.clear();
  await ChatMediaCacheService.instance.clear();
  await ChatVideoThumbnailService.instance.clear();
  try {
    await DefaultCacheManager().emptyCache();
  } catch (_) {}
}

Future<void> clearAllAppCaches(CacheService? prefsCache) async {
  await prefsCache?.clearAll();
  await VoiceCacheService.instance.clear();
  await ChatMediaCacheService.instance.clear();
  await ChatVideoThumbnailService.instance.clear();
  try {
    await DefaultCacheManager().emptyCache();
  } catch (_) {}
}

void prefetchChatMedia(Iterable<ChatMessage> messages) {
  for (final m in messages) {
    final url = m.mediaUrl;
    if (url == null || url.isEmpty) continue;
    if (m.messageType == ChatMessageType.voice) {
      continue;
    }
    final ext = switch (m.messageType) {
      ChatMessageType.image => ChatMediaCacheService.extensionForUrl(
        url,
        fallback: 'jpg',
      ),
      ChatMessageType.video => ChatMediaCacheService.extensionForUrl(
        url,
        fallback: 'mp4',
      ),
      ChatMessageType.file => ChatMediaCacheService.extensionForUrl(
        url,
        fallback: (m.textContent ?? 'bin').split('.').last,
      ),
      _ => 'bin',
    };
    ChatMediaCacheService.instance.prefetch(url, preferredExtension: ext);
    if (m.messageType == ChatMessageType.video) {
      ChatVideoThumbnailService.instance.prefetch(url);
    }
  }
}
