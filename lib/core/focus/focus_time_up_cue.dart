import 'package:flutter/services.dart';

Future<void> playFocusTimeUpCue() async {
  try {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.alert);
  } catch (_) {}
}
