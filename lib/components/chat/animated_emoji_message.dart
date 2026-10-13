import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class AnimatedEmojiMessage extends StatefulWidget {
  const AnimatedEmojiMessage({
    super.key,
    required this.assetPath,
    required this.emoji,
    this.size = 144,
  });

  final String assetPath;

  final String emoji;

  final double size;

  @override
  State<AnimatedEmojiMessage> createState() => _AnimatedEmojiMessageState();
}

class _AnimatedEmojiMessageState extends State<AnimatedEmojiMessage>
    with TickerProviderStateMixin {
  LottieComposition? _composition;
  bool _failed = false;
  late final AnimationController _lottieController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener(_onLottieStatus);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.14,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.14,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_bounceController);
    _load();
  }

  void _onLottieStatus(AnimationStatus status) {
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
    if (_lottieController.value != hold) {
      _lottieController.value = hold;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedEmojiMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _composition = null;
      _failed = false;
      _lottieController
        ..stop()
        ..reset();
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final composition = await AssetLottie(widget.assetPath).load();
      if (!mounted) return;
      setState(() {
        _composition = composition;
        _failed = false;
        _lottieController.duration = composition.duration;
        _lottieController.value = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _composition == null) return;
        _lottieController.forward(from: 0);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _composition = null;
      });
    }
  }

  void _replay() {
    if (_composition == null) return;
    HapticFeedback.selectionClick();
    _bounceController.forward(from: 0);
    _lottieController.forward(from: 0);
  }

  @override
  void dispose() {
    _lottieController.removeStatusListener(_onLottieStatus);
    _lottieController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _composition != null ? _replay : null,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RepaintBoundary(
          child: ScaleTransition(scale: _bounceScale, child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return Center(
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.size * 0.72, height: 1),
        ),
      );
    }
    final composition = _composition;
    if (composition == null) {
      return const SizedBox.expand();
    }
    return Lottie(
      composition: composition,
      controller: _lottieController,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      repeat: false,
    );
  }
}
