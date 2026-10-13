import 'package:flutter/material.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';

String chatReplySnippet(BuildContext context, ChatReplyPreview? reply) {
  final l10n = context.l10n;
  if (reply == null || reply.isDeleted) return l10n.chatReplyDeleted;
  return switch (reply.messageType) {
    ChatMessageType.text =>
      (reply.textContent ?? '').trim().isEmpty
          ? l10n.chatMessageDeleted
          : reply.textContent!.trim(),
    ChatMessageType.image => l10n.chatPreviewImage,
    ChatMessageType.video => l10n.chatPreviewVideo,
    ChatMessageType.voice => l10n.chatPreviewVoice,
    ChatMessageType.file =>
      (reply.textContent?.trim().isNotEmpty == true)
          ? reply.textContent!.trim()
          : l10n.chatPreviewFile,
  };
}

String chatReplySnippetFromMessage(BuildContext context, ChatMessage message) {
  return chatReplySnippet(context, ChatReplyPreview.fromMessage(message));
}
