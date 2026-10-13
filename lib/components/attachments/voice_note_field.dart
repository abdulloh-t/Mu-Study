import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/utils/voice_playback.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceNoteField extends StatefulWidget {
  const VoiceNoteField({
    super.key,
    this.voiceUrl,
    this.enabled = true,
    required this.onUpload,
    this.onRemove,
  });

  final String? voiceUrl;
  final bool enabled;
  final Future<void> Function(Uint8List bytes, String fileName) onUpload;
  final VoidCallback? onRemove;

  @override
  State<VoiceNoteField> createState() => _VoiceNoteFieldState();
}

class _VoiceNoteFieldState extends State<VoiceNoteField> {
  final AudioRecorder _recorder = AudioRecorder();
  final _voice = VoicePlaybackController.instance;

  bool _recording = false;
  bool _busy = false;
  String? _localPath;
  Duration _elapsed = Duration.zero;
  Timer? _tick;

  bool get _hasNote =>
      (widget.voiceUrl != null && widget.voiceUrl!.isNotEmpty) ||
      _localPath != null;

  String? get _playKey => _localPath ?? widget.voiceUrl;

  @override
  void initState() {
    super.initState();
    _voice.addListener(_onVoiceChanged);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _voice.removeListener(_onVoiceChanged);
    _recorder.dispose();
    super.dispose();
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<String> _recordingPath() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ext = kIsWeb ? 'wav' : 'm4a';
    final name = 'voice_$stamp.$ext';
    if (kIsWeb) return name;
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, name);
  }

  Future<void> _startRecording() async {
    if (!widget.enabled || _busy || _recording) return;

    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.voiceMicPermission)));
      return;
    }

    try {
      await _voice.stop();
      final path = await _recordingPath();
      await _recorder.start(
        RecordConfig(
          encoder: kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _recording = true;
        _elapsed = Duration.zero;
        _localPath = null;
      });
      _tick?.cancel();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.voiceCouldNotStart('$e'))),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;
    _tick?.cancel();
    setState(() {
      _recording = false;
      _busy = true;
    });

    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        throw Exception('No audio was captured.');
      }
      final bytes = await XFile(path).readAsBytes();
      if (bytes.isEmpty) throw Exception('Recording was empty.');

      final fileName = kIsWeb
          ? 'voice_${DateTime.now().millisecondsSinceEpoch}.wav'
          : p.basename(path);

      setState(() => _localPath = path);
      await widget.onUpload(bytes, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.voiceCouldNotSave('$e'))),
        );
      }
      setState(() => _localPath = null);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelRecording() async {
    _tick?.cancel();
    try {
      await _recorder.cancel();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _recording = false;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _togglePlay() async {
    if (_busy || _recording || !_hasNote) return;
    final key = _playKey;
    if (key == null) return;

    try {
      if (_localPath != null) {
        await _voice.toggleLocal(_localPath!);
      } else if (widget.voiceUrl != null) {
        await _voice.toggleRemote(widget.voiceUrl!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.voiceCouldNotPlay('$e'))),
      );
    }
  }

  Future<void> _remove() async {
    await _voice.stop();
    setState(() {
      _localPath = null;
    });
    widget.onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_recording) return _buildRecordingCard();
    if (_hasNote) return _buildPlaybackCard();
    return _buildIdleCard();
  }

  Widget _buildIdleCard() {
    return _VoiceShell(
      child: Row(
        children: [
          _RoundAction(
            color: AppColors.accent(context),
            icon: Icons.mic_rounded,
            onPressed: widget.enabled && !_busy ? _startRecording : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.taskVoice,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.voiceTapToRecord,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkAlpha(context, 0.55),
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordingCard() {
    return _VoiceShell(
      accent: AppColors.errorRed.withValues(alpha: 0.12),
      child: Row(
        children: [
          _PulsingDot(active: _recording),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.voiceRecording,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.errorRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _format(_elapsed),
                  style: TextStyle(
                    fontSize: 13,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppColors.inkAlpha(context, 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.commonCancel,
            onPressed: _cancelRecording,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.inkAlpha(context, 0.5),
          ),
          const SizedBox(width: 4),
          _RoundAction(
            color: AppColors.errorRed,
            icon: Icons.stop_rounded,
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackCard() {
    final key = _playKey ?? '';
    final playing = _voice.isPlaying(key);
    final loading = _voice.isLoading(key);
    final position = playing || loading ? _voice.position : Duration.zero;
    final duration = playing || loading ? _voice.duration : Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return _VoiceShell(
      child: Column(
        children: [
          Row(
            children: [
              _RoundAction(
                color: AppColors.mutedGold,
                icon: loading
                    ? Icons.hourglass_top_rounded
                    : playing
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                onPressed: widget.enabled && !_busy ? _togglePlay : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.voiceNote,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration == Duration.zero
                          ? context.l10n.voiceTapPlay
                          : '${_format(position)} / ${_format(duration)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: AppColors.inkAlpha(context, 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (widget.onRemove != null && widget.enabled)
                IconButton(
                  tooltip: context.l10n.commonDelete,
                  onPressed: _busy ? null : _remove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.errorRed,
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: playing || position > Duration.zero ? progress : 0,
              minHeight: 4,
              backgroundColor: AppColors.softSurface(context),
              color: AppColors.mutedGold,
            ),
          ),
          if (widget.enabled && widget.onRemove != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy || _recording ? null : _startRecording,
                icon: const Icon(Icons.mic_none_rounded, size: 18),
                label: Text(context.l10n.voiceRerecord),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final _voice = VoicePlaybackController.instance;

  @override
  void initState() {
    super.initState();
    _voice.addListener(_onVoiceChanged);
  }

  @override
  void dispose() {
    _voice.removeListener(_onVoiceChanged);
    super.dispose();
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggle() async {
    try {
      await _voice.toggleRemote(widget.url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.voiceCouldNotPlay('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playing = _voice.isPlaying(widget.url);
    final loading = _voice.isLoading(widget.url);
    final position = playing || loading ? _voice.position : Duration.zero;
    final duration = playing || loading ? _voice.duration : Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return _VoiceShell(
      child: Column(
        children: [
          Row(
            children: [
              _RoundAction(
                color: AppColors.mutedGold,
                icon: loading
                    ? Icons.hourglass_top_rounded
                    : playing
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                onPressed: _toggle,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? l10n.voiceNote,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration == Duration.zero
                          ? l10n.voiceStudentAnswer
                          : '${_format(position)} / ${_format(duration)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkAlpha(context, 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: playing || position > Duration.zero ? progress : 0,
              minHeight: 4,
              backgroundColor: AppColors.softSurface(context),
              color: AppColors.mutedGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceShell extends StatelessWidget {
  const _VoiceShell({required this.child, this.accent});

  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        accent ??
        (isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.sand.withValues(alpha: 0.85));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.55)
              : AppColors.inkAlpha(context, 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: AppColors.ink(context)),
        child: child,
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: onPressed == null ? 0.35 : 1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.active});

  final bool active;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.85,
        end: 1.15,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.errorRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
