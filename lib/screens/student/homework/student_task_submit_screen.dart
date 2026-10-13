import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mu_study/components/attachments/attachment_preview.dart';
import 'package:mu_study/components/attachments/voice_note_field.dart';
import 'package:mu_study/components/buttons/primary_button.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/dialogs/pdf_viewer_sheet.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentTaskSubmitScreen extends ConsumerStatefulWidget {
  const StudentTaskSubmitScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<StudentTaskSubmitScreen> createState() =>
      _StudentTaskSubmitScreenState();
}

const _signedUrlTtlSeconds = 60 * 60 * 24 * 365 * 10;

class _StudentTaskSubmitScreenState
    extends ConsumerState<StudentTaskSubmitScreen> {
  final _textController = TextEditingController();
  bool _loading = false;
  bool _completed = false;
  String? _fileUrl;
  String? _fileName;
  String? _storagePath;
  Uint8List? _localBytes;
  String? _voiceUrl;
  String? _voiceStoragePath;
  Map<String, dynamic>? _task;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final task = await supabase
        .from('tasks')
        .select()
        .eq('id', widget.taskId)
        .maybeSingle();
    if (task != null) setState(() => _task = Map<String, dynamic>.from(task));

    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;
    final sub = await supabase
        .from('submissions')
        .select()
        .eq('task_id', widget.taskId)
        .eq('student_id', student.id)
        .maybeSingle();
    if (sub != null && mounted) {
      final url = sub['file_url'] as String?;
      final voice = sub['voice_url'] as String?;
      setState(() {
        _textController.text = sub['text_answer'] as String? ?? '';
        _fileUrl = url;
        _fileName = url == null ? null : attachmentFileName(url);
        _storagePath = url == null ? null : storagePathFromSignedUrl(url);
        _localBytes = null;
        _voiceUrl = voice;
        _voiceStoragePath = voice == null
            ? null
            : storagePathFromSignedUrl(voice);
        _completed = sub['is_completed'] as bool? ?? false;
      });
    }
  }

  Future<void> _storeAttachment({
    required String studentId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = '$studentId/${widget.taskId}/$fileName';
    await supabase.storage
        .from('submissions')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = await supabase.storage
        .from('submissions')
        .createSignedUrl(path, _signedUrlTtlSeconds);
    if (!mounted) return;
    setState(() {
      _fileUrl = url;
      _fileName = fileName;
      _storagePath = path;
      _localBytes = bytes;
    });
  }

  Future<void> _uploadFile() async {
    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;

    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _loading = true);
    try {
      await _storeAttachment(
        studentId: student.id,
        fileName: file.name,
        bytes: file.bytes!,
      );
    } catch (e) {
      if (!mounted) return;
      _showError(context.l10n.taskUploadFailed('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _loading = true);
    try {
      await _storeAttachment(
        studentId: student.id,
        fileName: image.name,
        bytes: bytes,
      );
    } catch (e) {
      if (!mounted) return;
      _showError(context.l10n.taskUploadFailed('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeAttachment() async {
    final path = _storagePath;
    setState(() {
      _fileUrl = null;
      _fileName = null;
      _storagePath = null;
      _localBytes = null;
    });

    if (path != null) {
      try {
        await supabase.storage.from('submissions').remove([path]);
      } catch (_) {}
    }

    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;
    try {
      await supabase
          .from('submissions')
          .update({'file_url': null})
          .eq('task_id', widget.taskId)
          .eq('student_id', student.id);
    } catch (_) {}
  }

  Future<void> _uploadVoice(Uint8List bytes, String fileName) async {
    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;

    setState(() => _loading = true);
    try {
      final path = '${student.id}/${widget.taskId}/voice/$fileName';
      await supabase.storage
          .from('submissions')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: fileName.endsWith('.wav')
                  ? 'audio/wav'
                  : 'audio/mp4',
            ),
          );
      final url = await supabase.storage
          .from('submissions')
          .createSignedUrl(path, _signedUrlTtlSeconds);
      if (!mounted) return;
      setState(() {
        _voiceUrl = url;
        _voiceStoragePath = path;
      });
    } catch (e) {
      if (mounted) _showError(context.l10n.taskVoiceUploadFailed('$e'));
      rethrow;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeVoice() async {
    final path = _voiceStoragePath;
    setState(() {
      _voiceUrl = null;
      _voiceStoragePath = null;
    });

    if (path != null) {
      try {
        await supabase.storage.from('submissions').remove([path]);
      } catch (_) {}
    }

    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;
    try {
      await supabase
          .from('submissions')
          .update({'voice_url': null})
          .eq('task_id', widget.taskId)
          .eq('student_id', student.id);
    } catch (_) {}
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save({required bool submit}) async {
    final student = await ref.read(studentProfileProvider.future);
    if (student == null) return;
    setState(() => _loading = true);
    try {
      await supabase.from('submissions').upsert({
        'task_id': widget.taskId,
        'student_id': student.id,
        'text_answer': _textController.text.trim(),
        'file_url': _fileUrl,
        'voice_url': _voiceUrl,
        'is_completed': _completed,
        if (submit) 'status': 'submitted',
        if (submit) 'submitted_at': DateTime.now().toIso8601String(),
      }, onConflict: 'task_id,student_id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              submit ? context.l10n.taskSubmitted : context.l10n.taskSaved,
            ),
          ),
        );

        ref.invalidate(assignmentProgressProvider);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(context.l10n.taskCouldNotSave('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(task?['title'] as String? ?? l10n.taskTitle)),
      body: task == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                shellContentBottomPadding(context, extra: 16),
              ),
              children: [
                PremiumCard(child: Text(task['description'] as String? ?? '')),
                if (task['attachment_url'] != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => openPdfViewer(
                      context,
                      task['attachment_url'] as String,
                      title: task['title'] as String?,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l10n.taskViewPdf),
                  ),
                ],
                if (task['link_url'] != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        launchUrl(Uri.parse(task['link_url'] as String)),
                    child: Text(l10n.taskOpenLink),
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l10n.taskMarkCompleted),
                  value: _completed,
                  onChanged: (v) => setState(() => _completed = v),
                ),
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: l10n.taskYourAnswer),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.taskAttachment,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _fileUrl == null
                      ? l10n.taskAttachmentHint
                      : l10n.taskAttachmentHintReady,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                if (_fileUrl != null)
                  AttachmentPreview(
                    url: _fileUrl!,
                    fileName: _fileName,
                    bytes: _localBytes,
                    enabled: !_loading,
                    onRemove: _loading ? null : _removeAttachment,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _AttachAction(
                          icon: Icons.image_outlined,
                          label: l10n.taskImage,
                          subtitle: l10n.taskImageSubtitle,
                          onPressed: _loading ? null : _pickImage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AttachAction(
                          icon: Icons.upload_file_outlined,
                          label: l10n.taskFile,
                          subtitle: l10n.taskFileSubtitle,
                          onPressed: _loading ? null : _uploadFile,
                        ),
                      ),
                    ],
                  ),
                if (_fileUrl != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _loading ? null : _pickImage,
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: Text(l10n.taskReplaceImage),
                      ),
                      TextButton.icon(
                        onPressed: _loading ? null : _uploadFile,
                        icon: const Icon(Icons.upload_file_outlined, size: 18),
                        label: Text(l10n.taskReplaceFile),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.taskVoice,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.taskVoiceHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                VoiceNoteField(
                  voiceUrl: _voiceUrl,
                  enabled: !_loading,
                  onUpload: _uploadVoice,
                  onRemove: _loading ? null : _removeVoice,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: l10n.commonSaveDraft,
                  loading: _loading,
                  onPressed: () => _save(submit: false),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: l10n.commonSubmit,
                  loading: _loading,
                  onPressed: () => _save(submit: true),
                ),
              ],
            ),
    );
  }
}

class _AttachAction extends StatelessWidget {
  const _AttachAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.controlSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inkAlpha(context, 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accent(context), size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.inkAlpha(context, 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
