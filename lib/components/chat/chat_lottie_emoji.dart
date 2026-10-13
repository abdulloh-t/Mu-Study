import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mu_study/core/chat/animated_emoji_registry.dart';

class ChatLottieEmoji extends StatefulWidget {
  const ChatLottieEmoji({
    super.key,
    required this.emoji,
    this.size = 22,
    this.playOnTap = true,
    this.autoplay = true,
    this.repeat = false,
  });

  final String emoji;
  final double size;
  final bool playOnTap;
  final bool autoplay;

  final bool repeat;

  @override
  State<ChatLottieEmoji> createState() => _ChatLottieEmojiState();
}

class _ChatLottieEmojiState extends State<ChatLottieEmoji>
    with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  bool _failed = false;
  late final AnimationController _controller;
  String? _assetPath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onStatus);
    _assetPath = animatedEmojiAssetPath(widget.emoji);
    _load();
  }

  @override
  void didUpdateWidget(covariant ChatLottieEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emoji != widget.emoji) {
      _composition = null;
      _failed = false;
      _controller
        ..stop()
        ..reset();
      _assetPath = animatedEmojiAssetPath(widget.emoji);
      _load();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (widget.repeat) return;
    if (status != AnimationStatus.completed) return;
    _holdLastVisibleFrame();
  }

  void _holdLastVisibleFrame() {
    final composition = _composition;
    if (composition == null || !mounted) return;
    final span = composition.endFrame - composition.startFrame;
    if (span <= 0) return;
    const epsilonFrames = 0.5;
    final hold = ((span - epsilonFrames) / span).clamp(0.0, 0.999);
    if (_controller.value != hold) _controller.value = hold;
  }

  Future<void> _load() async {
    final path = _assetPath;
    if (path == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    try {
      final composition = await AssetLottie(path).load();
      if (!mounted) return;
      setState(() {
        _composition = composition;
        _failed = false;
        _controller.duration = composition.duration;
        _controller.value = 0;
      });
      if (widget.autoplay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _composition == null) return;
          _startPlayback();
        });
      } else if (!widget.repeat) {
        _holdLastVisibleFrame();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _composition = null;
      });
    }
  }

  void _startPlayback() {
    if (_composition == null) return;
    if (widget.repeat) {
      _controller.repeat(min: 0, max: _loopMax);
    } else {
      _controller.forward(from: 0);
    }
  }

  double get _loopMax {
    final composition = _composition;
    if (composition == null) return 0.999;
    final span = composition.endFrame - composition.startFrame;
    if (span <= 0) return 0.999;
    return ((span - 0.5) / span).clamp(0.0, 0.999);
  }

  void _replay() => _startPlayback();

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildBody(),
    );
    if (!widget.playOnTap || _composition == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _replay,
      child: child,
    );
  }

  Widget _buildBody() {
    if (_failed || _assetPath == null) {
      return Center(
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.size * 0.85, height: 1),
        ),
      );
    }
    final composition = _composition;
    if (composition == null) return const SizedBox.expand();
    return Lottie(
      composition: composition,
      controller: _controller,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      repeat: false,
    );
  }
}
