import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatFile extends StatelessWidget {
  const ChatFile({
    super.key,
    required this.url,
    required this.fileName,
    required this.color,
  });

  final String url;
  final String fileName;
  final Color color;

  static String _mimeForName(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'csv' => 'text/csv',
      'txt' => 'text/plain',
      'pdf' => 'application/pdf',
      'json' => 'application/json',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'zip' => 'application/zip',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'mp3' => 'audio/mpeg',
      'm4a' => 'audio/mp4',
      'wav' => 'audio/wav',
      'py' => 'text/x-python',
      _ => 'application/octet-stream',
    };
  }

  Future<void> _open(BuildContext context) async {
    final l10n = context.l10n;
    try {
      if (kIsWeb) {
        final uri = Uri.tryParse(url);
        if (uri != null &&
            await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          return;
        }
        throw StateError('launch failed');
      }

      final ext = fileName.contains('.')
          ? fileName.split('.').last
          : ChatMediaCacheService.extensionForUrl(url, fallback: 'bin');
      final cached = await ChatMediaCacheService.instance.getOrFetch(
        url,
        preferredExtension: ext,
      );
      if (cached == null) {
        final uri = Uri.tryParse(url);
        if (uri != null &&
            await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return;
        }
        throw StateError('download failed');
      }

      final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
      final tmp = File(p.join((await getTemporaryDirectory()).path, safeName));
      await cached.copy(tmp.path);

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(tmp.path, mimeType: _mimeForName(safeName), name: safeName),
          ],
          fileNameOverrides: [safeName],
          downloadFallbackEnabled: true,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatOpenFileFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final radius = isMono ? 4.0 : 12.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_rounded, color: color, size: 28),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.chatOpenFile,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.download_rounded,
                color: color.withValues(alpha: 0.75),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
