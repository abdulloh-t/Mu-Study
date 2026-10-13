import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/utils/voice_playback.dart';
import 'package:mu_study/l10n/l10n_x.dart';

class ChatVoice extends StatefulWidget {
  const ChatVoice({
    super.key,
    required this.url,
    required this.timeLabel,
    required this.isMine,
    required this.isReadByOthers,
  });

  final String url;
  final String timeLabel;
  final bool isMine;
  final bool isReadByOthers;

  @override
  State<ChatVoice> createState() => _ChatVoiceState();
}

class _ChatVoiceState extends State<ChatVoice> {
  final _voice = VoicePlaybackController.instance;
  late final List<double> _bars = _waveformFor(widget.url);

  static const _bg = Color(0xFF1C1C1E);
  static const _playCircle = Color(0xFF2C2C2E);
  static const _played = Color(0xFFB8B0E8);
  static const _unplayed = Color(0xFF8E8E93);
  static const _meta = Color(0xFFAEAEB2);

  static List<double> _waveformFor(String seed) {
    var hash = 2166136261;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    final bars = <double>[];
    var x = hash == 0 ? 1 : hash;
    for (var i = 0; i < 36; i++) {
      x = (1103515245 * x + 12345) & 0x7fffffff;
      final n = (x % 1000) / 1000.0;
      final envelope = 0.55 + 0.45 * (1 - (((i / 35) - 0.5).abs() * 1.4));
      bars.add((0.22 + n * 0.78) * envelope.clamp(0.35, 1.0));
    }
    return bars;
  }

  static String _formatDuration(Duration d) {
    final total = d.inSeconds.clamp(0, 99 * 60);
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

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
    final active = _voice.activeKey == widget.url;
    final playing = _voice.isPlaying(widget.url);
    final loading = _voice.isLoading(widget.url);
    final duration = active ? _voice.duration : Duration.zero;
    final position = active ? _voice.position : Duration.zero;
    final progress = (!active || duration.inMilliseconds <= 0)
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    final durationLabel = duration > Duration.zero
        ? _formatDuration(playing ? duration - position : duration)
        : '0:00';
    final isMono =
        AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
    final playRadius = BorderRadius.circular(isMono ? 4 : 20);
    final playedColor = isMono ? const Color(0xFFE8E8E8) : _played;
    final unplayedColor = isMono ? const Color(0xFF6E6E73) : _unplayed;

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(isMono ? 6 : 999),
        border: isMono
            ? Border.all(color: Colors.white.withValues(alpha: 0.10))
            : null,
      ),
      child: Row(
        children: [
          Material(
            color: isMono ? Colors.white : _playCircle,
            borderRadius: playRadius,
            child: InkWell(
              borderRadius: playRadius,
              onTap: loading ? null : _toggle,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isMono ? Colors.black : Colors.white,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isMono ? Colors.black : Colors.white,
                          size: playing ? 22 : 26,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 28,
              child: CustomPaint(
                painter: VoiceWaveformPainter(
                  bars: _bars,
                  progress: progress,
                  playedColor: playedColor,
                  unplayedColor: unplayedColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                durationLabel,
                style: const TextStyle(
                  color: _meta,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.timeLabel,
                    style: const TextStyle(
                      color: _meta,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (widget.isMine) ...[
                    const SizedBox(width: 3),
                    Icon(
                      widget.isReadByOthers
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 13,
                      color: widget.isReadByOthers
                          ? (isMono
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF9ED0FF))
                          : _meta,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VoiceWaveformPainter extends CustomPainter {
  const VoiceWaveformPainter({
    required this.bars,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
  });

  final List<double> bars;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || size.width <= 0 || size.height <= 0) return;
    const gap = 2.0;
    final barWidth = ((size.width - gap * (bars.length - 1)) / bars.length)
        .clamp(1.5, 3.5);
    final total = bars.length * barWidth + (bars.length - 1) * gap;
    var x = (size.width - total) / 2;
    final playedUntil = progress * bars.length;

    for (var i = 0; i < bars.length; i++) {
      final h = (bars[i] * size.height).clamp(4.0, size.height);
      final top = (size.height - h) / 2;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, h),
        const Radius.circular(999),
      );
      final paint = Paint()
        ..color = i + 1 <= playedUntil ? playedColor : unplayedColor;
      canvas.drawRRect(rrect, paint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant VoiceWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.playedColor != playedColor ||
      oldDelegate.unplayedColor != unplayedColor ||
      !identical(oldDelegate.bars, bars);
}
