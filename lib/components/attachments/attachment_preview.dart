import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/components/dialogs/pdf_viewer_sheet.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:url_launcher/url_launcher.dart';

const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'};

bool isImageAttachment(String? nameOrUrl) {
  final ext = attachmentExtension(nameOrUrl);
  return ext != null && _imageExtensions.contains(ext);
}

bool isPdfAttachment(String? nameOrUrl) {
  return attachmentExtension(nameOrUrl) == 'pdf';
}

String? attachmentExtension(String? nameOrUrl) {
  if (nameOrUrl == null || nameOrUrl.isEmpty) return null;
  final clean = Uri.tryParse(nameOrUrl)?.path ?? nameOrUrl;
  final base = clean.split('/').last.split('?').first;
  final dot = base.lastIndexOf('.');
  if (dot < 0 || dot == base.length - 1) return null;
  return base.substring(dot + 1).toLowerCase();
}

String attachmentFileName(String? nameOrUrl, {String fallback = 'Attachment'}) {
  if (nameOrUrl == null || nameOrUrl.isEmpty) return fallback;
  final clean = Uri.tryParse(nameOrUrl)?.path ?? nameOrUrl;
  final base = clean.split('/').last.split('?').first;
  return base.isEmpty ? fallback : Uri.decodeComponent(base);
}

String? storagePathFromSignedUrl(String url, {String? bucket}) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final segments = uri.pathSegments;
  final signIdx = segments.indexOf('sign');
  if (signIdx >= 0 && signIdx + 2 < segments.length) {
    final bucketName = segments[signIdx + 1];
    if (bucket != null && bucketName != bucket) return null;
    return segments.sublist(signIdx + 2).map(Uri.decodeComponent).join('/');
  }
  return null;
}

Future<void> openAttachment(
  BuildContext context, {
  required String url,
  String? fileName,
  Uint8List? bytes,
}) async {
  final name = fileName ?? attachmentFileName(url);

  if (isImageAttachment(name)) {
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => _ImageLightbox(url: url, bytes: bytes, title: name),
    );
    return;
  }

  if (isPdfAttachment(name)) {
    await openPdfViewer(context, url, title: name);
    return;
  }

  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.attachmentCouldNotOpen)),
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    super.key,
    required this.url,
    this.fileName,
    this.bytes,
    this.onRemove,
    this.enabled = true,
  });

  final String url;
  final String? fileName;
  final Uint8List? bytes;
  final VoidCallback? onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name =
        fileName ?? attachmentFileName(url, fallback: l10n.taskAttachment);
    final isImage = isImageAttachment(name);

    return isImage
        ? _ImagePreviewCard(
            url: url,
            bytes: bytes,
            fileName: name,
            subtitle: l10n.attachmentImage,
            tapPreview: l10n.attachmentTapPreview,
            onOpen: enabled
                ? () => openAttachment(
                    context,
                    url: url,
                    fileName: name,
                    bytes: bytes,
                  )
                : null,
            onRemove: enabled ? onRemove : null,
          )
        : _FilePreviewCard(
            fileName: name,
            kindLabel: isPdfAttachment(name)
                ? l10n.attachmentPdf
                : l10n.attachmentFile,
            tapOpen: l10n.attachmentTapOpen,
            onOpen: enabled
                ? () => openAttachment(context, url: url, fileName: name)
                : null,
            onRemove: enabled ? onRemove : null,
          );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({
    required this.url,
    required this.fileName,
    required this.subtitle,
    required this.tapPreview,
    this.bytes,
    this.onOpen,
    this.onRemove,
  });

  final String url;
  final String fileName;
  final String subtitle;
  final String tapPreview;
  final Uint8List? bytes;
  final VoidCallback? onOpen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.controlSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inkAlpha(context, 0.06)),
            boxShadow: [
              BoxShadow(
                color: AppColors.inkAlpha(context, 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: AppColors.softWash(context, lightAlpha: 0.5),
                        child: bytes != null
                            ? Image.memory(bytes!, fit: BoxFit.cover)
                            : CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.accent(context),
                                    size: 32,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.inkAlpha(context, 0.45),
                              ],
                            ),
                          ),
                          child: const SizedBox(height: 48),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: Row(
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tapPreview,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _RemoveButton(onPressed: onRemove!),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.mutedGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: AppColors.mutedGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkAlpha(context, 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkAlpha(context, 0.3),
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

class _FilePreviewCard extends StatelessWidget {
  const _FilePreviewCard({
    required this.fileName,
    required this.kindLabel,
    required this.tapOpen,
    this.onOpen,
    this.onRemove,
  });

  final String fileName;
  final String kindLabel;
  final String tapOpen;
  final VoidCallback? onOpen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isPdf = isPdfAttachment(fileName);
    final accent = isPdf ? AppColors.coffeeBrown : AppColors.softOlive;
    final icon = isPdf
        ? Icons.picture_as_pdf_rounded
        : Icons.insert_drive_file_outlined;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.controlSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inkAlpha(context, 0.06)),
            boxShadow: [
              BoxShadow(
                color: AppColors.inkAlpha(context, 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kindLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkAlpha(context, 0.45),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tapOpen,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                _RemoveButton(onPressed: onRemove!),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkAlpha(context, 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: AppColors.inkAlpha(context, 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: AppColors.errorRed,
          ),
        ),
      ),
    );
  }
}

class _ImageLightbox extends StatelessWidget {
  const _ImageLightbox({required this.url, required this.title, this.bytes});

  final String url;
  final String title;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: bytes != null
                    ? Image.memory(bytes!)
                    : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        errorWidget: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 4,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
