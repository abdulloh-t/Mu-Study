import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mu_study/core/services/voice_cache_service.dart';

class DetectedAudioFormat {
  const DetectedAudioFormat({required this.mimeType, required this.extension});

  final String mimeType;
  final String extension;
}

DetectedAudioFormat detectAudioFormat(Uint8List bytes) {
  if (bytes.length >= 12) {
    final isRiff =
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46;
    final isWave =
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;
    if (isRiff && isWave) {
      return const DetectedAudioFormat(mimeType: 'audio/wav', extension: 'wav');
    }
  }

  if (bytes.length >= 8 &&
      bytes[4] == 0x66 &&
      bytes[5] == 0x74 &&
      bytes[6] == 0x79 &&
      bytes[7] == 0x70) {
    return const DetectedAudioFormat(mimeType: 'audio/mp4', extension: 'm4a');
  }

  if (bytes.length >= 3 &&
      bytes[0] == 0x49 &&
      bytes[1] == 0x44 &&
      bytes[2] == 0x33) {
    return const DetectedAudioFormat(mimeType: 'audio/mpeg', extension: 'mp3');
  }

  return const DetectedAudioFormat(mimeType: 'audio/mp4', extension: 'm4a');
}

String mimeTypeForExtension(String extension) {
  return switch (extension.toLowerCase().replaceAll('.', '')) {
    'wav' => 'audio/wav',
    'mp3' => 'audio/mpeg',
    'aac' => 'audio/aac',
    _ => 'audio/mp4',
  };
}

bool _audioContextReady = false;

Future<void> _ensureAudioContext() async {
  if (_audioContextReady) return;
  await AudioPlayer.global.setAudioContext(
    AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {},
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ),
  );
  _audioContextReady = true;
}

Future<Uint8List> _downloadVoiceBytes(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Could not download voice (${response.statusCode})');
  }
  final bytes = response.bodyBytes;
  if (bytes.isEmpty) {
    throw Exception('Voice file is empty');
  }
  if (bytes.length < 64) {
    final head = String.fromCharCodes(bytes.take(32));
    if (head.trimLeft().startsWith('{') || head.trimLeft().startsWith('<')) {
      throw Exception('Voice download returned an error payload');
    }
  }
  return Uint8List.fromList(bytes);
}

Future<({Uint8List bytes, String mimeType, File? file})> resolveVoiceSource(
  String url,
) async {
  final cache = VoiceCacheService.instance;
  final cachedFile = await cache.getFile(url);
  if (cachedFile != null) {
    final bytes = Uint8List.fromList(await cachedFile.readAsBytes());
    if (bytes.isNotEmpty) {
      final format = detectAudioFormat(bytes);
      final fileExt = cachedFile.path.split('.').last.toLowerCase();
      if (fileExt != format.extension) {
        final fixed = await cache.put(url, bytes, format.extension);
        return (bytes: bytes, mimeType: format.mimeType, file: fixed);
      }
      return (bytes: bytes, mimeType: format.mimeType, file: cachedFile);
    }
  }

  final bytes = await _downloadVoiceBytes(url);
  final format = detectAudioFormat(bytes);
  final file = await cache.put(url, bytes, format.extension);
  return (bytes: bytes, mimeType: format.mimeType, file: file);
}

class VoicePlaybackController extends ChangeNotifier {
  VoicePlaybackController._() {
    _attachPlayerListeners(_player);
  }

  static final VoicePlaybackController instance = VoicePlaybackController._();

  final AudioPlayer _player = AudioPlayer(playerId: 'mu_study_voice');
  String? _activeKey;
  bool _playing = false;
  bool _loading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _generation = 0;

  Future<void> _queue = Future.value();

  String? get activeKey => _activeKey;
  Duration get position => _position;
  Duration get duration => _duration;

  bool isPlaying(String key) => _playing && _activeKey == key;
  bool isLoading(String key) => _loading && _activeKey == key;

  void _attachPlayerListeners(AudioPlayer player) {
    player.onPlayerComplete.listen((_) {
      _playing = false;
      _loading = false;
      _position = Duration.zero;
      notifyListeners();
    });
    player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (_playing) {
          _playing = false;
          notifyListeners();
        }
      }
    });
    player.onPositionChanged.listen((pos) {
      if (!_playing && !_loading) return;
      _position = pos;
      notifyListeners();
    });
    player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
  }

  Future<void> stop() {
    return _enqueue(() async {
      _generation++;
      await _safeStopAndRelease();
      _playing = false;
      _loading = false;
      _activeKey = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();
    });
  }

  Future<void> toggleRemote(String url) => _toggle(url, remote: true);

  Future<void> toggleLocal(String path) => _toggle(path, remote: false);

  Future<void> _enqueue(Future<void> Function() action) {
    final run = _queue.then((_) => action());
    _queue = run.catchError((_) {});
    return run;
  }

  Future<void> _safeStopAndRelease() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
  }

  Future<void> _playResolved({
    required Uint8List bytes,
    required String mimeType,
    File? file,
  }) async {
    if (file != null && await file.exists()) {
      await _player.play(DeviceFileSource(file.path, mimeType: mimeType));
      return;
    }
    await _player.play(BytesSource(bytes, mimeType: mimeType));
  }

  Future<void> _toggle(String key, {required bool remote}) {
    return _enqueue(() async {
      if (_loading && _activeKey == key) return;

      if (_activeKey == key && _playing) {
        _generation++;
        await _safeStopAndRelease();
        _playing = false;
        _loading = false;
        _activeKey = null;
        _position = Duration.zero;
        _duration = Duration.zero;
        notifyListeners();
        return;
      }

      final gen = ++_generation;
      _activeKey = key;
      _loading = true;
      _playing = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();

      try {
        await _ensureAudioContext();
        await _safeStopAndRelease();
        if (gen != _generation) return;

        if (remote) {
          final resolved = await resolveVoiceSource(key);
          if (gen != _generation) return;
          await _playResolved(
            bytes: resolved.bytes,
            mimeType: resolved.mimeType,
            file: resolved.file,
          );
        } else {
          final lower = key.toLowerCase();
          final mime = lower.endsWith('.wav')
              ? 'audio/wav'
              : lower.endsWith('.mp3')
              ? 'audio/mpeg'
              : 'audio/mp4';
          await _player.play(DeviceFileSource(key, mimeType: mime));
        }

        if (gen != _generation) {
          await _safeStopAndRelease();
          return;
        }
        _playing = true;
        _loading = false;
        notifyListeners();
      } catch (e) {
        if (gen != _generation) rethrow;
        _playing = false;
        _loading = false;
        _activeKey = null;
        _position = Duration.zero;
        _duration = Duration.zero;
        notifyListeners();
        rethrow;
      }
    });
  }
}
