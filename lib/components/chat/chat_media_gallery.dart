import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mu_study/core/services/chat_media_cache_service.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:video_player/video_player.dart';

const _speedOptions = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
const _dismissDistance = 120.0;

enum ChatMediaKind { image, video }

class ChatMediaItem {
  const ChatMediaItem({
    required this.id,
    required this.url,
    required this.kind,
  });

  final String id;
  final String url;
  final ChatMediaKind kind;
}

List<ChatMediaItem> chatMediaItemsFromMessages(Iterable<ChatMessage> messages) {
  final items = <ChatMediaItem>[];
  for (final m in messages) {
    if (m.isDeleted) continue;
    final url = m.mediaUrl;
    if (url == null || url.isEmpty) continue;
    final kind = switch (m.messageType) {
      ChatMessageType.image => ChatMediaKind.image,
      ChatMessageType.video => ChatMediaKind.video,
      _ => null,
    };
    if (kind == null) continue;
    items.add(ChatMediaItem(id: m.id, url: url, kind: kind));
  }
  return items;
}

Future<void> showChatMediaGallery(
  BuildContext context, {
  required List<ChatMediaItem> items,
  required int initialIndex,
}) {
  assert(items.isNotEmpty);
  final index = initialIndex.clamp(0, items.length - 1);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ChatMediaGalleryPage(items: items, initialIndex: index);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

Future<void> showChatVideoPlayer(BuildContext context, {required String url}) {
  return showChatMediaGallery(
    context,
    items: [ChatMediaItem(id: url, url: url, kind: ChatMediaKind.video)],
    initialIndex: 0,
  );
}

class ChatMediaGalleryPage extends StatefulWidget {
  const ChatMediaGalleryPage({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<ChatMediaItem> items;
  final int initialIndex;

  @override
  State<ChatMediaGalleryPage> createState() => _ChatMediaGalleryPageState();
}

class _ChatMediaGalleryPageState extends State<ChatMediaGalleryPage> {
  late final PageController _pageController;
  late int _index;
  double _dragY = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    setState(() {
      _dragging = true;
      _dragY = (_dragY + dy).clamp(0.0, 400.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final fling = details.primaryVelocity ?? 0;
    final shouldClose = _dragY > _dismissDistance || fling > 900;
    if (shouldClose) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _dragging = false;
      _dragY = 0;
    });
  }

  void _onVerticalDragCancel() {
    setState(() {
      _dragging = false;
      _dragY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragY / _dismissDistance).clamp(0.0, 1.0);
    final bgOpacity = (1.0 - progress * 0.55).clamp(0.35, 1.0);
    final scale = (1.0 - progress * 0.08).clamp(0.9, 1.0);

    return Material(
      color: Colors.black.withValues(alpha: bgOpacity),
      child: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onVerticalDragCancel: _onVerticalDragCancel,
        child: AnimatedContainer(
          duration: _dragging
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0, _dragging ? _dragY : 0, 0, 1)
            ..scaleByDouble(scale, scale, 1, 1),
          transformAlignment: Alignment.center,
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final item = widget.items[i];
                    final active = i == _index && _dragY < 24;
                    return switch (item.kind) {
                      ChatMediaKind.image => _GalleryImagePage(url: item.url),
                      ChatMediaKind.video => _GalleryVideoPage(
                        url: item.url,
                        isActive: active,
                      ),
                    };
                  },
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
                if (widget.items.length > 1)
                  Positioned(
                    top: 14,
                    right: 16,
                    child: Text(
                      '${_index + 1} / ${widget.items.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryImagePage extends StatefulWidget {
  const _GalleryImagePage({required this.url});
  final String url;

  @override
  State<_GalleryImagePage> createState() => _GalleryImagePageState();
}

class _GalleryImagePageState extends State<_GalleryImagePage>
    with AutomaticKeepAliveClientMixin {
  File? _file;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (!kIsWeb && ChatMediaCacheService.instance.isSupported) {
      final file = await ChatMediaCacheService.instance.getOrFetch(
        widget.url,
        preferredExtension: ChatMediaCacheService.extensionForUrl(
          widget.url,
          fallback: 'jpg',
        ),
      );
      if (!mounted) return;
      setState(() {
        _file = file;
        _loading = false;
      });
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    final child = _file != null
        ? Image.file(_file!, fit: BoxFit.contain)
        : CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 48,
            ),
          );
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(child: child),
    );
  }
}

class _GalleryVideoPage extends StatefulWidget {
  const _GalleryVideoPage({required this.url, required this.isActive});

  final String url;
  final bool isActive;

  @override
  State<_GalleryVideoPage> createState() => _GalleryVideoPageState();
}

class _GalleryVideoPageState extends State<_GalleryVideoPage>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _controlsVisible = true;
  double _speed = 1.0;
  Timer? _hideControls;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(covariant _GalleryVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  Future<void> _open() async {
    VideoPlayerController controller;
    if (!kIsWeb && ChatMediaCacheService.instance.isSupported) {
      final file = await ChatMediaCacheService.instance.getOrFetch(
        widget.url,
        preferredExtension: ChatMediaCacheService.extensionForUrl(
          widget.url,
          fallback: 'mp4',
        ),
      );
      if (!mounted) return;
      controller = file != null
          ? VideoPlayerController.file(file)
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    }

    _controller = controller;
    controller.addListener(_onTick);
    try {
      await controller.initialize();
      await controller.setPlaybackSpeed(_speed);
      if (!mounted) return;
      setState(() => _ready = true);
      await _syncPlayback();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _syncPlayback() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (widget.isActive) {
      await c.play();
      _scheduleHideControls();
    } else {
      await c.pause();
      _hideControls?.cancel();
      if (mounted) setState(() => _controlsVisible = true);
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _scheduleHideControls() {
    _hideControls?.cancel();
    if (!(_controller?.value.isPlaying ?? false)) return;
    _hideControls = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHideControls();
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      await c.pause();
      _hideControls?.cancel();
      setState(() => _controlsVisible = true);
    } else {
      await c.play();
      _scheduleHideControls();
    }
  }

  Future<void> _seekBy(Duration delta) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final total = c.value.duration;
    var next = c.value.position + delta;
    if (next < Duration.zero) next = Duration.zero;
    if (next > total) next = total;
    await c.seekTo(next);
    _scheduleHideControls();
  }

  Future<void> _setSpeed(double speed) async {
    final c = _controller;
    if (c == null) return;
    setState(() => _speed = speed);
    await c.setPlaybackSpeed(speed);
    _scheduleHideControls();
  }

  Future<void> _showSpeedSheet() async {
    _hideControls?.cancel();
    setState(() => _controlsVisible = true);
    final selected = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (ctx) {
        final l10n = context.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.chatVideoPlaybackSpeed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              for (final speed in _speedOptions)
                ListTile(
                  selected: speed == _speed,
                  selectedColor: Colors.white,
                  selectedTileColor: Colors.white12,
                  title: Text(
                    speed == 1.0
                        ? l10n.chatVideoSpeedNormal
                        : l10n.chatVideoSpeedValue(speed),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: speed == _speed
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () => Navigator.pop(ctx, speed),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) await _setSpeed(selected);
    _scheduleHideControls();
  }

  String _fmt(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _hideControls?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final c = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_failed)
          Center(
            child: Text(
              l10n.chatVideoCouldNotPlay,
              style: const TextStyle(color: Colors.white70),
            ),
          )
        else if (!_ready || c == null)
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: Center(
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio == 0
                    ? 16 / 9
                    : c.value.aspectRatio,
                child: VideoPlayer(c),
              ),
            ),
          ),
        if (_ready && c != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: _ControlsBar(
                  controller: c,
                  onSeekBack: () => _seekBy(const Duration(seconds: -10)),
                  onSeekForward: () => _seekBy(const Duration(seconds: 10)),
                  onTogglePlay: _togglePlay,
                  onSpeedTap: _showSpeedSheet,
                  onSeek: (value) async {
                    final total = c.value.duration.inMilliseconds;
                    await c.seekTo(
                      Duration(milliseconds: (value * total).round()),
                    );
                    _scheduleHideControls();
                  },
                  format: _fmt,
                  speedLabel: _speed == 1.0
                      ? l10n.chatVideoSpeedNormal
                      : l10n.chatVideoSpeedValue(_speed),
                  rewindLabel: l10n.chatVideoRewind10,
                  forwardLabel: l10n.chatVideoForward10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.controller,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.onTogglePlay,
    required this.onSpeedTap,
    required this.onSeek,
    required this.format,
    required this.speedLabel,
    required this.rewindLabel,
    required this.forwardLabel,
  });

  final VideoPlayerController controller;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final VoidCallback onTogglePlay;
  final VoidCallback onSpeedTap;
  final ValueChanged<double> onSeek;
  final String Function(Duration) format;
  final String speedLabel;
  final String rewindLabel;
  final String forwardLabel;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final duration = value.duration;
    final position = value.position;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 28, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                format(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(value: progress, onChanged: onSeek),
                ),
              ),
              Text(
                format(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                onPressed: onSeekBack,
                icon: Icons.replay_10_rounded,
                label: rewindLabel,
              ),
              IconButton(
                onPressed: onTogglePlay,
                iconSize: 56,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: Colors.white,
                ),
              ),
              _ControlButton(
                onPressed: onSeekForward,
                icon: Icons.forward_10_rounded,
                label: forwardLabel,
              ),
              TextButton(
                onPressed: onSpeedTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(
                  speedLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 32),
          tooltip: label,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
