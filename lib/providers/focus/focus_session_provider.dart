import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/focus/focus_time_up_cue.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'focus_session_v1';

enum FocusTimerMode { pomodoro, free }

const kFocusPomodoroDuration = Duration(minutes: 25);

class FocusSession {
  const FocusSession({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.mode,
    required this.startedAt,
    this.accumulated = Duration.zero,
    this.pausedAt,
  });

  final String assignmentId;
  final String assignmentTitle;
  final FocusTimerMode mode;
  final DateTime startedAt;

  final Duration accumulated;
  final DateTime? pausedAt;

  bool get isPaused => pausedAt != null;

  Duration elapsedAt([DateTime? now]) {
    final n = now ?? DateTime.now();
    if (isPaused) return accumulated;
    return accumulated + n.difference(startedAt);
  }

  Duration? remainingAt([DateTime? now]) {
    if (mode != FocusTimerMode.pomodoro) return null;
    final left = kFocusPomodoroDuration - elapsedAt(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool isCompleteAt([DateTime? now]) {
    final left = remainingAt(now);
    return left != null && left == Duration.zero;
  }

  Map<String, dynamic> toJson() => {
    'assignmentId': assignmentId,
    'assignmentTitle': assignmentTitle,
    'mode': mode.name,
    'startedAt': startedAt.toIso8601String(),
    'accumulatedMs': accumulated.inMilliseconds,
    'pausedAt': pausedAt?.toIso8601String(),
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      assignmentId: json['assignmentId'] as String,
      assignmentTitle: json['assignmentTitle'] as String? ?? '',
      mode: FocusTimerMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => FocusTimerMode.free,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      accumulated: Duration(milliseconds: json['accumulatedMs'] as int? ?? 0),
      pausedAt: json['pausedAt'] != null
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
    );
  }

  FocusSession copyWith({
    DateTime? startedAt,
    Duration? accumulated,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return FocusSession(
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      mode: mode,
      startedAt: startedAt ?? this.startedAt,
      accumulated: accumulated ?? this.accumulated,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    );
  }
}

class FocusSummary {
  const FocusSummary({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.focused,
    required this.mode,
    this.note,
    this.timedOut = false,
  });

  final String assignmentId;
  final String assignmentTitle;
  final Duration focused;
  final FocusTimerMode mode;
  final String? note;

  final bool timedOut;

  FocusSummary copyWith({String? note}) => FocusSummary(
    assignmentId: assignmentId,
    assignmentTitle: assignmentTitle,
    focused: focused,
    mode: mode,
    note: note ?? this.note,
    timedOut: timedOut,
  );
}

class FocusSessionState {
  const FocusSessionState({this.session, this.summary});

  final FocusSession? session;
  final FocusSummary? summary;

  bool get isActive => session != null;
  bool get showingSummary => summary != null && session == null;

  FocusSessionState copyWith({
    FocusSession? session,
    FocusSummary? summary,
    bool clearSession = false,
    bool clearSummary = false,
  }) {
    return FocusSessionState(
      session: clearSession ? null : (session ?? this.session),
      summary: clearSummary ? null : (summary ?? this.summary),
    );
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionController, FocusSessionState>((ref) {
      return FocusSessionController();
    });

final focusChatMutedProvider = Provider<bool>((ref) {
  return ref.watch(focusSessionProvider).isActive;
});

class FocusSessionController extends StateNotifier<FocusSessionState> {
  FocusSessionController() : super(const FocusSessionState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final session = FocusSession.fromJson(map);
      if (!mounted) return;
      if (session.isCompleteAt()) {
        await endSession(timedOut: true, playCue: false);
        return;
      }
      state = FocusSessionState(session: session);
    } catch (_) {
      await prefs.remove(_prefsKey);
    }
  }

  Future<void> _persist(FocusSession? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, jsonEncode(session.toJson()));
    }
  }

  Future<void> start({
    required String assignmentId,
    required String assignmentTitle,
    required FocusTimerMode mode,
  }) async {
    final session = FocusSession(
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      mode: mode,
      startedAt: DateTime.now(),
    );
    state = FocusSessionState(session: session);
    await _persist(session);
  }

  Future<void> pause() async {
    final s = state.session;
    if (s == null || s.isPaused) return;
    final now = DateTime.now();
    final next = s.copyWith(accumulated: s.elapsedAt(now), pausedAt: now);
    state = state.copyWith(session: next);
    await _persist(next);
  }

  Future<void> resume() async {
    final s = state.session;
    if (s == null || !s.isPaused) return;
    final next = s.copyWith(startedAt: DateTime.now(), clearPausedAt: true);
    state = state.copyWith(session: next);
    await _persist(next);
  }

  Future<void> endSession({bool timedOut = false, bool playCue = true}) async {
    final s = state.session;
    if (s == null) return;
    final focused = timedOut && s.mode == FocusTimerMode.pomodoro
        ? kFocusPomodoroDuration
        : s.elapsedAt();
    final summary = FocusSummary(
      assignmentId: s.assignmentId,
      assignmentTitle: s.assignmentTitle,
      focused: focused,
      mode: s.mode,
      timedOut: timedOut,
    );
    state = FocusSessionState(summary: summary);
    await _persist(null);
    if (timedOut && playCue) {
      await playFocusTimeUpCue();
    }
  }

  void setSummaryNote(String note) {
    final summary = state.summary;
    if (summary == null) return;
    state = state.copyWith(summary: summary.copyWith(note: note));
  }

  void dismissSummary() {
    state = const FocusSessionState();
  }
}
