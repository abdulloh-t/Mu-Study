import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mu_study/components/chat/chat_media_gallery.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/core/utils/responsive.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/chat/chat_providers.dart';
import 'package:mu_study/screens/chat/room/helpers/chat_list_entries.dart';
import 'package:mu_study/screens/chat/room/widgets/attach_chip.dart';
import 'package:mu_study/screens/chat/room/widgets/chat_date_chip.dart';
import 'package:mu_study/screens/chat/room/widgets/edit_message_dialog.dart';
import 'package:mu_study/screens/chat/room/widgets/message_bubble.dart';
import 'package:mu_study/screens/chat/room/widgets/reply_composer_banner.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen>
    with WidgetsBindingObserver {
  static const _nearBottomThreshold = 120.0;

  static const _recentActivityWindow = Duration(minutes: 3);

  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _recorder = AudioRecorder();
  final _focus = FocusNode();

  bool _sending = false;
  bool _attachOpen = false;
  bool _recording = false;
  double _uploadProgress = 0;
  String? _uploadLabel;
  Duration _recordElapsed = Duration.zero;
  Timer? _recordTick;
  Timer? _typingIdle;
  Timer? _presenceHeartbeat;
  Timer? _presencePoll;
  RealtimeChannel? _typingChannel;
  List<String> _typingNames = const [];
  final Set<String> _presenceOnlineIds = {};
  final Set<String> _recentlyActiveIds = {};
  int _onlineCount = 0;
  bool _markedRead = false;
  bool _presenceSetupInFlight = false;

  bool _stickToBottom = true;
  bool _showScrollDown = false;
  bool _didInitialScroll = false;
  String? _lastTailMessageId;
  int _lastMessageCount = 0;
  bool _loadMoreQueued = false;
  Timer? _scrollFabDebounce;
  Timer? _highlightTimer;
  ChatMessage? _replyTo;
  String? _highlightedMessageId;
  final _messageKeys = <String, GlobalKey>{};
  bool _jumpingToReply = false;
  bool _selectionMode = false;
  Set<String> _selectedMessageIds = {};

  GlobalKey _keyForMessage(String id) =>
      _messageKeys.putIfAbsent(id, GlobalKey.new);

  bool _canModerateMessage(ChatMessage message, String? myId, bool isAdmin) {
    if (message.isDeleted) return false;
    if (isAdmin) return true;
    return myId != null && message.senderId == myId;
  }

  /// Students/teachers: own messages only. Admins: any message in the room.
  bool _canDeleteMessage(ChatMessage message, String? myId, bool isAdmin) {
    return _canModerateMessage(message, myId, isAdmin);
  }

  Iterable<ChatMessage> _deletableMessages(
    List<ChatMessage> messages,
    String? myId,
    bool isAdmin,
  ) {
    return messages.where((m) => _canDeleteMessage(m, myId, isAdmin));
  }

  void _enterSelectionMode({String? messageId}) {
    setState(() {
      _selectionMode = true;
      _selectedMessageIds = messageId == null ? {} : {messageId};
      _attachOpen = false;
    });
    _focus.unfocus();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds = {};
    });
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds = {..._selectedMessageIds, messageId};
      }
    });
  }

  void _selectAllMessages(
    List<ChatMessage> messages,
    String? myId,
    bool isAdmin,
  ) {
    setState(() {
      _selectedMessageIds = _deletableMessages(messages, myId, isAdmin)
          .map((m) => m.id)
          .toSet();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedMessageIds.isEmpty) return;
    final count = _selectedMessageIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.chatDeleteSelectedTitle(count)),
        content: Text(context.l10n.chatDeleteSelectedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final me = ref.read(currentProfileProvider).valueOrNull;
    final isAdmin = me?.role == UserRole.admin;
    final current = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
    final ids = current == null
        ? _selectedMessageIds.toList()
        : _deletableMessages(current.messages, me?.id, isAdmin)
            .where((m) => _selectedMessageIds.contains(m.id))
            .map((m) => m.id)
            .toList();
    if (ids.isEmpty) return;
    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .deleteMessages(ids);
      if (mounted) _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonCouldNotSave('$e'))),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _text.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setupTyping();
      // Don't open the keyboard until the user taps the field.
      _focus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingIdle?.cancel();
    _recordTick?.cancel();
    _presenceHeartbeat?.cancel();
    _presencePoll?.cancel();
    _scrollFabDebounce?.cancel();
    _highlightTimer?.cancel();
    _scroll.dispose();
    _text.dispose();
    _focus.dispose();
    _recorder.dispose();
    final ch = _typingChannel;
    _typingChannel = null;
    if (ch != null) {
      () async {
        try {
          await ch.untrack();
        } catch (_) {}
        try {
          await supabase.removeChannel(ch);
        } catch (_) {}
      }();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retrackPresence();
    }
  }

  void _commitOnlineCount({List<String>? typingNames}) {
    final me = ref.read(currentProfileProvider).valueOrNull?.id;
    final merged = <String>{..._presenceOnlineIds, ..._recentlyActiveIds, ?me};
    final nextCount = merged.length;
    final nextTyping = typingNames ?? _typingNames;
    if (!mounted) return;
    if (nextCount == _onlineCount &&
        typingNames == null &&
        identical(nextTyping, _typingNames)) {
      return;
    }
    setState(() {
      _onlineCount = nextCount;
      if (typingNames != null) _typingNames = typingNames;
    });
  }

  void _refreshPresence(RealtimeChannel channel, String myId) {
    final onlineIds = <String>{};
    final typingNames = <String>{};

    for (final entry in channel.presenceState()) {
      final keyId = entry.key.trim();
      if (keyId.isNotEmpty) onlineIds.add(keyId);

      for (final presence in entry.presences) {
        final payload = presence.payload;
        final id = (payload['user_id'] as String?)?.trim();
        if (id != null && id.isNotEmpty) onlineIds.add(id);

        final typing = payload['typing'] == true;
        final name = payload['full_name'] as String?;
        final who = id ?? (keyId.isEmpty ? null : keyId);
        if (typing && who != null && who != myId && name != null) {
          typingNames.add(name);
        }
      }
    }

    onlineIds.add(myId);
    _presenceOnlineIds
      ..clear()
      ..addAll(onlineIds);
    _commitOnlineCount(typingNames: typingNames.toList()..sort());
  }

  void _notePresenceJoin(RealtimePresenceJoinPayload payload) {
    final key = payload.key.trim();
    if (key.isNotEmpty) _presenceOnlineIds.add(key);
    for (final presence in payload.newPresences) {
      final id = (presence.payload['user_id'] as String?)?.trim();
      if (id != null && id.isNotEmpty) _presenceOnlineIds.add(id);
    }
    _commitOnlineCount();
  }

  void _notePresenceLeave(RealtimePresenceLeavePayload payload) {
    final key = payload.key.trim();
    if (key.isNotEmpty) _presenceOnlineIds.remove(key);
    for (final presence in payload.leftPresences) {
      final id = (presence.payload['user_id'] as String?)?.trim();
      if (id != null && id.isNotEmpty) _presenceOnlineIds.remove(id);
    }
    _commitOnlineCount();
  }

  void _updateRecentlyActive(List<ChatMessage> messages) {
    final cutoff = DateTime.now().subtract(_recentActivityWindow);
    final active = <String>{};
    for (final m in messages) {
      if (m.isDeleted) continue;
      if (m.createdAt.isBefore(cutoff)) continue;
      if (m.senderId.isNotEmpty) active.add(m.senderId);
    }
    if (active.length == _recentlyActiveIds.length &&
        active.containsAll(_recentlyActiveIds)) {
      return;
    }
    _recentlyActiveIds
      ..clear()
      ..addAll(active);
    _commitOnlineCount();
  }

  Future<void> _retrackPresence() async {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    final channel = _typingChannel;
    if (channel == null) {
      await _setupTyping();
      return;
    }
    try {
      await channel.track({
        'user_id': profile.id,
        'full_name': profile.fullName,
        'typing': _text.text.trim().isNotEmpty,
      });
    } catch (_) {}
    if (mounted) _refreshPresence(channel, profile.id);
  }

  Future<void> _setupTyping() async {
    if (_presenceSetupInFlight || _typingChannel != null) return;
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;

    _presenceSetupInFlight = true;
    _presenceHeartbeat?.cancel();
    _presencePoll?.cancel();

    try {
      final previous = _typingChannel;
      _typingChannel = null;
      if (previous != null) {
        try {
          await previous.untrack();
        } catch (_) {}
        try {
          await supabase.removeChannel(previous);
        } catch (_) {}
      }

      final channel = supabase.channel(
        'typing-${widget.roomId}',
        opts: RealtimeChannelConfig(key: profile.id),
      );

      channel
        ..onPresenceSync((_) {
          if (!mounted) return;
          _refreshPresence(channel, profile.id);
        })
        ..onPresenceJoin((payload) {
          if (!mounted) return;
          _notePresenceJoin(payload);
          scheduleMicrotask(() {
            if (mounted) _refreshPresence(channel, profile.id);
          });
        })
        ..onPresenceLeave((payload) {
          if (!mounted) return;
          _notePresenceLeave(payload);
          scheduleMicrotask(() {
            if (mounted) _refreshPresence(channel, profile.id);
          });
        });

      channel.subscribe((status, [_]) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await channel.track({
            'user_id': profile.id,
            'full_name': profile.fullName,
            'typing': false,
          });
          if (mounted) _refreshPresence(channel, profile.id);
        }
      });

      _presenceHeartbeat = Timer.periodic(const Duration(seconds: 20), (_) {
        if (!mounted || _typingChannel == null) return;
        _retrackPresence();
      });

      _presencePoll = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || _typingChannel == null) return;
        _refreshPresence(_typingChannel!, profile.id);
        final msgs = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
        if (msgs != null) _updateRecentlyActive(msgs.messages);
      });

      if (mounted) _typingChannel = channel;
    } finally {
      _presenceSetupInFlight = false;
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null || _typingChannel == null) return;
    _typingChannel!.track({
      'user_id': profile.id,
      'full_name': profile.fullName,
      'typing': _text.text.trim().isNotEmpty,
    });
    _typingIdle?.cancel();
    _typingIdle = Timer(const Duration(seconds: 3), () {
      _typingChannel?.track({
        'user_id': profile.id,
        'full_name': profile.fullName,
        'typing': false,
      });
    });
  }

  bool get _isNearBottom {
    if (!_scroll.hasClients) return true;
    final pos = _scroll.position;
    if (pos.maxScrollExtent <= 0) return true;
    return pos.pixels <= _nearBottomThreshold;
  }

  void _onUserScrolled() {
    if (!_scroll.hasClients) return;
    final nearBottom = _isNearBottom;
    _stickToBottom = nearBottom;
    final show = !nearBottom;
    if (show == _showScrollDown) return;
    _scrollFabDebounce?.cancel();
    _scrollFabDebounce = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      final next = !_isNearBottom;
      if (next != _showScrollDown) {
        setState(() => _showScrollDown = next);
      }
    });
  }

  void _maybeLoadMoreFromScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent > pos.viewportDimension * 0.5 &&
        pos.pixels >= pos.maxScrollExtent - 80) {
      _requestLoadMore();
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      _maybeLoadMoreFromScroll();
    }

    if (_stickToBottom &&
        notification is ScrollMetricsNotification &&
        notification.metrics.axis == Axis.vertical) {
      final m = notification.metrics;
      if (m.pixels > 1) {
        _scroll.jumpTo(0);
      }
    }

    if (notification is UserScrollNotification) {
      _onUserScrolled();
    }
    return false;
  }

  void _requestLoadMore() {
    if (_loadMoreQueued) return;
    final state = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
    if (state == null || !state.hasMore || state.loadingMore) return;
    _loadMoreQueued = true;
    final beforeExtent = _scroll.hasClients
        ? _scroll.position.maxScrollExtent
        : 0.0;
    final beforePixels = _scroll.hasClients ? _scroll.position.pixels : 0.0;
    ref
        .read(chatMessagesProvider(widget.roomId).notifier)
        .loadMore()
        .whenComplete(() {
          _loadMoreQueued = false;
          if (!mounted || !_scroll.hasClients) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_scroll.hasClients) return;
            final afterExtent = _scroll.position.maxScrollExtent;
            final delta = afterExtent - beforeExtent;
            if (delta > 0) {
              _scroll.jumpTo(beforePixels + delta);
            }
          });
        });
  }

  void _maybeMarkRead(AsyncValue<ChatMessagesState> messages) {
    if (_markedRead) return;
    messages.whenData((_) {
      _markedRead = true;
      ref.read(chatMessagesProvider(widget.roomId).notifier).markRoomRead();
    });
  }

  void _onMessagesUpdated(ChatMessagesState state) {
    _updateRecentlyActive(state.messages);

    final tailId = state.messages.isEmpty ? null : state.messages.last.id;
    final count = state.messages.length;

    if (!_didInitialScroll && state.messages.isNotEmpty) {
      _didInitialScroll = true;
      _lastTailMessageId = tailId;
      _lastMessageCount = count;
      _scrollToBottom(animated: false);
      return;
    }

    final hasNewTail = tailId != null && tailId != _lastTailMessageId;
    final prepended = count > _lastMessageCount && !hasNewTail;
    _lastTailMessageId = tailId;
    _lastMessageCount = count;

    if (prepended) return;
    if (!hasNewTail) return;

    if (_stickToBottom) {
      _scrollToBottom();
      ref.read(chatMessagesProvider(widget.roomId).notifier).markRoomRead();
    } else if (!_showScrollDown && mounted) {
      setState(() => _showScrollDown = true);
    }
  }

  void _onScrollDownTap() {
    setState(() {
      _stickToBottom = true;
      _showScrollDown = false;
    });
    _scrollToBottom();
    ref.read(chatMessagesProvider(widget.roomId).notifier).markRoomRead();
  }

  void _beginReply(ChatMessage message) {
    if (message.isDeleted) return;
    setState(() => _replyTo = message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
    });
  }

  void _clearReply() {
    if (_replyTo == null) return;
    setState(() => _replyTo = null);
  }

  void _flashMessage(String messageId) {
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = messageId);
    _highlightTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_highlightedMessageId == messageId) {
        setState(() => _highlightedMessageId = null);
      }
    });
  }

  int? _reverseIndexForMessage(String messageId, List<ChatMessage> messages) {
    final entries = chatEntriesFor(messages);
    final entryIndex = entries.indexWhere((e) => e.message?.id == messageId);
    if (entryIndex < 0) return null;
    return entries.length - 1 - entryIndex;
  }

  Future<void> _awaitLoadMoreSettled({required int previousCount}) async {
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      final s = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
      if (s == null) return;
      if (!s.loadingMore &&
          (s.messages.length != previousCount || !s.hasMore)) {
        return;
      }
    }
  }

  Future<void> _jumpNearReverseIndex(int reverseIndex) async {
    if (!_scroll.hasClients) return;
    const avgExtent = 160.0;
    for (var pass = 0; pass < 3; pass++) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      final target = (reverseIndex * avgExtent).clamp(0.0, max);
      _scroll.jumpTo(target);
      await Future<void>.delayed(const Duration(milliseconds: 32));
    }
  }

  Future<bool> _ensureVisibleMessage(String messageId) async {
    final key = _keyForMessage(messageId);
    for (var frame = 0; frame < 12; frame++) {
      final ctx = key.currentContext;
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: 0.35,
        );
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    return false;
  }

  Future<void> _scrollToRepliedMessage(String messageId) async {
    if (_jumpingToReply || messageId.isEmpty) return;
    _jumpingToReply = true;
    _stickToBottom = false;
    setState(() => _showScrollDown = true);
    final notFoundLabel = context.l10n.chatReplyNotFound;
    final messenger = ScaffoldMessenger.of(context);
    try {
      for (var attempt = 0; attempt < 30; attempt++) {
        if (!mounted) return;
        final state = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
        if (state == null) return;

        ChatMessage? hit;
        for (final m in state.messages) {
          if (m.id == messageId) {
            hit = m;
            break;
          }
        }
        if (hit != null) {
          if (hit.isDeleted) {
            messenger.showSnackBar(
              SnackBar(content: Text(context.l10n.chatReplyDeleted)),
            );
            return;
          }
          break;
        }

        if (!state.hasMore) {
          messenger.showSnackBar(SnackBar(content: Text(notFoundLabel)));
          return;
        }

        if (state.loadingMore) {
          await _awaitLoadMoreSettled(previousCount: state.messages.length);
          continue;
        }

        final before = state.messages.length;
        await ref.read(chatMessagesProvider(widget.roomId).notifier).loadMore();
        await _awaitLoadMoreSettled(previousCount: before);
      }

      if (!mounted) return;
      final state = ref.read(chatMessagesProvider(widget.roomId)).valueOrNull;
      ChatMessage? target;
      if (state != null) {
        for (final m in state.messages) {
          if (m.id == messageId) {
            target = m;
            break;
          }
        }
      }
      if (state == null || target == null || target.isDeleted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              target?.isDeleted == true
                  ? context.l10n.chatReplyDeleted
                  : notFoundLabel,
            ),
          ),
        );
        return;
      }

      final reverseIndex = _reverseIndexForMessage(messageId, state.messages);
      if (reverseIndex != null) {
        await _jumpNearReverseIndex(reverseIndex);
      }

      if (!mounted) return;
      var visible = await _ensureVisibleMessage(messageId);
      if (!visible && reverseIndex != null && mounted) {
        await _jumpNearReverseIndex(reverseIndex + 2);
        visible = await _ensureVisibleMessage(messageId);
      }

      if (visible && mounted) {
        _flashMessage(messageId);
        return;
      }

      if (reverseIndex != null && _scroll.hasClients) {
        await _jumpNearReverseIndex(reverseIndex);
        if (await _ensureVisibleMessage(messageId) && mounted) {
          _flashMessage(messageId);
          return;
        }
      }

      messenger.showSnackBar(SnackBar(content: Text(notFoundLabel)));
    } finally {
      _jumpingToReply = false;
    }
  }

  Future<void> _sendText() async {
    final value = _text.text.trim();
    if (value.isEmpty || _sending) return;
    final replyId = _replyTo?.id;
    setState(() => _sending = true);
    try {
      _text.clear();
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .sendText(value, replyToMessageId: replyId);
      setState(() {
        _stickToBottom = true;
        _showScrollDown = false;
        _replyTo = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chatSendFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    void attempt([int framesLeft = 3]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_scroll.hasClients) {
          if (framesLeft > 0) attempt(framesLeft - 1);
          return;
        }
        final pos = _scroll.position;
        if (pos.pixels <= 1) {
          if (framesLeft > 0) attempt(framesLeft - 1);
          return;
        }
        if (!animated || framesLeft > 0) {
          _scroll.jumpTo(0);
          if (framesLeft > 0) attempt(framesLeft - 1);
          return;
        }
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }

    attempt(animated ? 1 : 3);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    final type = chatMessageTypeForFileName(file.name);
    await _sendMedia(
      type,
      file.bytes!,
      file.name,
      caption: type == ChatMessageType.file ? file.name : null,
    );
  }

  Future<void> _sendMedia(
    ChatMessageType type,
    Uint8List bytes,
    String fileName, {
    String? caption,
  }) async {
    final replyId = _replyTo?.id;
    setState(() {
      _sending = true;
      _uploadProgress = 0.02;
      _uploadLabel = fileName;
      _attachOpen = false;
    });
    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .sendMedia(
            type: type,
            bytes: bytes,
            fileName: fileName,
            caption: caption,
            replyToMessageId: replyId,
            onProgress: (p) {
              if (mounted) setState(() => _uploadProgress = p);
            },
          );
      setState(() {
        _stickToBottom = true;
        _showScrollDown = false;
        _replyTo = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chatSendFailed('$e'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _uploadProgress = 0;
          _uploadLabel = null;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    await _sendMedia(ChatMessageType.image, bytes, image.name);
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    final bytes = await video.readAsBytes();
    await _sendMedia(ChatMessageType.video, bytes, video.name);
  }

  Future<String> _recordingPath() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ext = kIsWeb ? 'wav' : 'm4a';
    final name = 'chat_voice_$stamp.$ext';
    if (kIsWeb) return name;
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, name);
  }

  Future<void> _startRecording() async {
    if (_recording || _sending) return;
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.chatMicDenied)));
      }
      return;
    }
    final path = await _recordingPath();
    await _recorder.start(
      RecordConfig(encoder: kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _recording = true;
      _recordElapsed = Duration.zero;
    });
    _recordTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordElapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording({required bool send}) async {
    _recordTick?.cancel();
    final path = await _recorder.stop();
    setState(() => _recording = false);
    if (!send || path == null) return;

    try {
      final bytes = await XFile(path).readAsBytes();
      final name = kIsWeb
          ? 'chat_voice_${DateTime.now().millisecondsSinceEpoch}.wav'
          : p.basename(path);
      await _sendMedia(ChatMessageType.voice, bytes, name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chatSendFailed('$e'))),
        );
      }
    }
  }

  Future<void> _editMessage(ChatMessage message) async {
    final result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) =>
          EditMessageDialog(initialText: message.textContent ?? ''),
    );
    if (!mounted || result == null || result.isEmpty) return;
    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .editMessage(message.id, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonCouldNotSave('$e'))),
        );
      }
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.chatDeleteTitle),
        content: Text(context.l10n.chatDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .deleteMessage(message.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonCouldNotSave('$e'))),
        );
      }
    }
  }

  Future<void> _react(ChatMessage message, String emoji) async {
    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .toggleReaction(message.id, emoji);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonCouldNotSave('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final room = ref.watch(chatRoomProvider(widget.roomId));
    final messages = ref.watch(chatMessagesProvider(widget.roomId));
    final me = ref.watch(currentProfileProvider).valueOrNull;
    final isAdmin = me?.role == UserRole.admin;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(chatMessagesProvider(widget.roomId), (prev, next) {
      next.whenData(_onMessagesUpdated);
    });
    ref.listen(currentProfileProvider, (prev, next) {
      if (next.valueOrNull != null && _typingChannel == null) {
        _setupTyping();
      }
    });

    _maybeMarkRead(messages);

    final roomData = room.valueOrNull;
    final title = roomData?.groupTitle ?? l10n.chatTitle;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardOpen = keyboardInset > 0;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectionMode) _exitSelectionMode();
      },
      child: Scaffold(
      // Keep viewInsets so the composer can sit flush on the keyboard.
      // Otherwise shell nav padding (from extendBody) leaves a large gap.
      resizeToAvoidBottomInset: false,
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text(l10n.chatSelectedCount(_selectedMessageIds.length)),
              actions: [
                TextButton(
                  onPressed: messages.maybeWhen(
                    data: (state) => state.messages.isEmpty
                        ? null
                        : () => _selectAllMessages(
                            state.messages,
                            me?.id,
                            isAdmin,
                          ),
                    orElse: () => null,
                  ),
                  child: Text(l10n.commonSelectAll),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selectedMessageIds.isEmpty
                      ? null
                      : _deleteSelected,
                ),
              ],
            )
          : AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Builder(
              builder: (context) {
                final isMono =
                    AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ??
                    false;
                final accent = AppColors.accent(context);
                return Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(isMono ? 4 : 18),
                    border: isMono
                        ? Border.all(color: accent.withValues(alpha: 0.22))
                        : null,
                  ),
                  child: Icon(Icons.groups_rounded, size: 20, color: accent),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (roomData != null)
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkAlpha(context, 0.55),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: l10n.chatTeacherMembers(
                              roomData.teacherName,
                              roomData.memberCount,
                            ),
                          ),
                          if (_onlineCount > 0) ...[
                            const TextSpan(text: ' · '),
                            TextSpan(
                              text: '● ${l10n.chatOnlineCount(_onlineCount)}',
                              style: TextStyle(
                                color:
                                    (AppStyleTokens.maybeOf(
                                          context,
                                        )?.isMonochromeWorkspace ??
                                        false)
                                    ? AppColors.ink(context)
                                    : const Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.chatSelectMessages,
            icon: const Icon(Icons.checklist_rounded),
            onPressed: () => _enterSelectionMode(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_uploadProgress > 0 && _uploadProgress < 1)
            LinearProgressIndicator(value: _uploadProgress),
          if (_uploadLabel != null && _uploadProgress > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                l10n.chatUploading(_uploadLabel!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.commonErrorWithDetails('$e'))),
              data: (state) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.chatNoMessagesYet,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkAlpha(context, 0.5),
                      ),
                    ),
                  );
                }
                final entries = chatEntriesFor(state.messages);
                final loadMoreOffset = state.hasMore ? 1 : 0;
                final galleryItems = chatMediaItemsFromMessages(state.messages);

                return Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: ListView.builder(
                        reverse: true,
                        controller: _scroll,
                        cacheExtent: 1200,
                        padding: EdgeInsets.fromLTRB(
                          12,
                          8,
                          12,
                          _selectionMode
                              ? shellContentBottomPadding(context)
                              : 12,
                        ),
                        itemCount: entries.length + loadMoreOffset,
                        itemBuilder: (context, index) {
                          if (state.hasMore && index == entries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                child: state.loadingMore
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () => ref
                                            .read(
                                              chatMessagesProvider(
                                                widget.roomId,
                                              ).notifier,
                                            )
                                            .loadMore(),
                                        child: Text(l10n.commonLoadMore),
                                      ),
                              ),
                            );
                          }
                          final entry = entries[entries.length - 1 - index];
                          if (entry.date != null) {
                            return ChatDateChip(date: entry.date!);
                          }
                          final message = entry.message!;
                          final mine = message.senderId == me?.id;
                          final canModerate = _canModerateMessage(
                            message,
                            me?.id,
                            isAdmin,
                          );
                          final canDelete = _canDeleteMessage(
                            message,
                            me?.id,
                            isAdmin,
                          );
                          return KeyedSubtree(
                            key: _keyForMessage(message.id),
                            child: MessageBubble(
                              message: message,
                              isMine: mine,
                              myUserId: me?.id,
                              galleryItems: galleryItems,
                              highlighted: _highlightedMessageId == message.id,
                              selectionMode: _selectionMode,
                              selected: _selectedMessageIds.contains(
                                message.id,
                              ),
                              selectable: canDelete,
                              onSelectionToggle: canDelete
                                  ? () => _toggleMessageSelection(message.id)
                                  : null,
                              onSelect: canDelete
                                  ? () => _enterSelectionMode(
                                      messageId: message.id,
                                    )
                                  : null,
                              onJumpToReply: _selectionMode
                                  ? null
                                  : (id) => _scrollToRepliedMessage(id),
                              onReply: _selectionMode || message.isDeleted
                                  ? null
                                  : () => _beginReply(message),
                              onReact: _selectionMode || message.isDeleted
                                  ? null
                                  : (emoji) => _react(message, emoji),
                              onEdit:
                                  !_selectionMode &&
                                      canModerate &&
                                      message.messageType ==
                                          ChatMessageType.text &&
                                      !message.isDeleted
                                  ? () => _editMessage(message)
                                  : null,
                              onDelete:
                                  !_selectionMode && canDelete
                                  ? () => _deleteMessage(message)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: IgnorePointer(
                        ignoring: !_showScrollDown,
                        child: AnimatedScale(
                          scale: _showScrollDown ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                            opacity: _showScrollDown ? 1 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: Material(
                              color: isDark
                                  ? scheme.surfaceContainerHighest
                                  : Colors.white,
                              elevation: 4,
                              shadowColor: AppColors.inkAlpha(context, 0.18),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _onScrollDownTap,
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.accent(context),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (!_selectionMode && _typingNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.chatTyping(_typingNames.join(', ')),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warmAmber,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          if (!_selectionMode && _recording)
            Container(
              width: double.infinity,
              color: AppColors.errorRed.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: AppColors.errorRed),
                  const SizedBox(width: 8),
                  Text(
                    l10n.chatRecording(
                      '${_recordElapsed.inMinutes.toString().padLeft(2, '0')}:'
                      '${(_recordElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _stopRecording(send: false),
                    child: Text(l10n.commonCancel),
                  ),
                  FilledButton(
                    onPressed: () => _stopRecording(send: true),
                    child: Text(l10n.commonSubmit),
                  ),
                ],
              ),
            ),
          if (!_selectionMode)
            Padding(
            padding: EdgeInsets.fromLTRB(
              context.isMobile ? 10 : 16,
              6,
              context.isMobile ? 10 : 16,
              keyboardInset +
                  (keyboardOpen
                      ? 8
                      : (context.isMobile ? 10 : 16) +
                            MediaQuery.paddingOf(context).bottom),
            ),
            child: Builder(
              builder: (context) {
                final dockTokens = AppStyleTokens.maybeOf(context);
                final isNeuDock = dockTokens?.isSoftNeumorphism ?? false;
                final isMonoDock = dockTokens?.isMonochromeWorkspace ?? false;
                final dockRadius = BorderRadius.circular(
                  isMonoDock ? 4 : (isNeuDock ? 24 : 28),
                );
                final dockChild = Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: _attachOpen
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AttachChip(
                                      icon: Icons.image_outlined,
                                      label: l10n.chatAttachImage,
                                      onTap: _pickImage,
                                    ),
                                    AttachChip(
                                      icon: Icons.videocam_outlined,
                                      label: l10n.chatAttachVideo,
                                      onTap: _pickVideo,
                                    ),
                                    AttachChip(
                                      icon: Icons.attach_file_rounded,
                                      label: l10n.chatAttachFile,
                                      onTap: _pickFile,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: _replyTo == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: ReplyComposerBanner(
                                  message: _replyTo!,
                                  onClose: _clearReply,
                                ),
                              ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _sending
                                ? null
                                : () => setState(
                                    () => _attachOpen = !_attachOpen,
                                  ),
                            icon: AnimatedRotation(
                              turns: _attachOpen ? 0.125 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.add_circle_outline),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _text,
                              focusNode: _focus,
                              autofocus: false,
                              minLines: 1,
                              maxLines: 5,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendText(),
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                hintText: l10n.chatMessageHint,
                                filled: false,
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.fromLTRB(
                                  4,
                                  10,
                                  8,
                                  10,
                                ),
                              ),
                            ),
                          ),
                          if (_text.text.trim().isEmpty)
                            GestureDetector(
                              onLongPressStart: (_) => _startRecording(),
                              onLongPressEnd: (_) => _stopRecording(send: true),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _recording
                                      ? AppColors.danger(context)
                                      : AppColors.accent(context),
                                  shape: isMonoDock
                                      ? BoxShape.rectangle
                                      : BoxShape.circle,
                                  borderRadius: isMonoDock
                                      ? BorderRadius.circular(4)
                                      : null,
                                  boxShadow: isNeuDock
                                      ? [
                                          BoxShadow(
                                            color: Neumorphic.shadowColor(
                                              context,
                                            ).withValues(alpha: 0.35),
                                            offset: const Offset(2, 3),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  _recording
                                      ? Icons.stop_rounded
                                      : Icons.mic_none,
                                  color: (isDark && (isNeuDock || isMonoDock))
                                      ? const Color(0xFF0E1812)
                                      : Colors.white,
                                  size: 22,
                                ),
                              ),
                            )
                          else
                            IconButton.filled(
                              onPressed: _sending ? null : _sendText,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.accent(context),
                                foregroundColor:
                                    (isDark && (isNeuDock || isMonoDock))
                                    ? const Color(0xFF0E1812)
                                    : Colors.white,
                                fixedSize: const Size(40, 40),
                                padding: EdgeInsets.zero,
                                shape: isMonoDock
                                    ? RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : null,
                              ),
                              icon: _sending
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            (isDark &&
                                                (isNeuDock || isMonoDock))
                                            ? const Color(0xFF0E1812)
                                            : Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 20),
                            ),
                        ],
                      ),
                    ],
                  ),
                );

                if (isNeuDock) {
                  return Container(
                    decoration: Neumorphic.decoration(
                      context,
                      elevation: NeuElevation.floating,
                      borderRadius: dockRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: dockChild,
                  );
                }

                return Material(
                  color: isDark
                      ? scheme.surfaceContainerHigh.withValues(alpha: 0.96)
                      : Colors.white.withValues(alpha: 0.94),
                  elevation: isMonoDock ? 0 : 10,
                  shadowColor: isMonoDock
                      ? Colors.transparent
                      : AppColors.inkAlpha(context, 0.18),
                  surfaceTintColor: Colors.transparent,
                  borderRadius: dockRadius,
                  clipBehavior: Clip.antiAlias,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: dockRadius,
                      border: Border.all(
                        color: AppColors.inkAlpha(
                          context,
                          isMonoDock ? 0.12 : 0.08,
                        ),
                      ),
                    ),
                    child: dockChild,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
