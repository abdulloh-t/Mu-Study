import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ChatMediaCacheService {
  ChatMediaCacheService._();

  static final ChatMediaCacheService instance = ChatMediaCacheService._();

  static const _folder = 'chat_media_cache';
  static const _indexFile = 'index.json';
  static const maxEntries = 200;
  static const maxTotalBytes = 400 * 1024 * 1024; // 400 MB

  Directory? _dir;
  Map<String, _MediaCacheEntry>? _index;
  Future<void>? _initFuture;
  final _inflight = <String, Future<File?>>{};

  bool get isSupported => !kIsWeb;

  Future<void> _ensureReady() async {
    if (!isSupported) return;
    _initFuture ??= _init();
    await _initFuture;
  }

  Future<void> _init() async {
    final root = await getApplicationCacheDirectory();
    _dir = Directory(p.join(root.path, _folder));
    if (!await _dir!.exists()) {
      await _dir!.create(recursive: true);
    }
    await _loadIndex();
  }

  static String keyForUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final path = uri.path;
    final signIdx = path.indexOf('/object/sign/');
    if (signIdx >= 0) {
      return path.substring(signIdx + '/object/sign/'.length);
    }
    final publicIdx = path.indexOf('/object/public/');
    if (publicIdx >= 0) {
      return path.substring(publicIdx + '/object/public/'.length);
    }
    return path.isEmpty ? url : path;
  }

  static String _hashKey(String key) =>
      sha1.convert(utf8.encode(key)).toString();

  static String extensionForUrl(String url, {String fallback = 'bin'}) {
    final key = keyForUrl(url);
    final name = key.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return fallback;
    final ext = name.substring(dot + 1).toLowerCase();
    if (ext.length > 8 || ext.contains('?')) return fallback;
    return ext;
  }

  Future<void> _loadIndex() async {
    final file = File(p.join(_dir!.path, _indexFile));
    if (!await file.exists()) {
      _index = {};
      return;
    }
    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _index = {
        for (final e in raw.entries)
          e.key: _MediaCacheEntry.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          ),
      };
    } catch (_) {
      _index = {};
    }
  }

  Future<void> _saveIndex() async {
    final file = File(p.join(_dir!.path, _indexFile));
    final map = {for (final e in _index!.entries) e.key: e.value.toJson()};
    await file.writeAsString(jsonEncode(map));
  }

  File _fileFor(String hash, String extension) =>
      File(p.join(_dir!.path, '$hash.$extension'));

  Future<File?> getFile(String url) async {
    if (!isSupported) return null;
    await _ensureReady();
    final hash = _hashKey(keyForUrl(url));
    final entry = _index![hash];
    if (entry == null) return null;
    final file = _fileFor(hash, entry.extension);
    if (!await file.exists()) {
      _index!.remove(hash);
      await _saveIndex();
      return null;
    }
    entry.lastAccessMs = DateTime.now().millisecondsSinceEpoch;
    await _saveIndex();
    return file;
  }

  Future<File?> put(String url, Uint8List bytes, String extension) async {
    if (!isSupported || bytes.isEmpty) return null;
    await _ensureReady();
    final hash = _hashKey(keyForUrl(url));
    final ext = extension.replaceAll('.', '').toLowerCase();
    final file = _fileFor(hash, ext);

    final existing = _index![hash];
    if (existing != null && existing.extension != ext) {
      final old = _fileFor(hash, existing.extension);
      if (await old.exists()) await old.delete();
    }

    await file.writeAsBytes(bytes, flush: true);
    _index![hash] = _MediaCacheEntry(
      extension: ext,
      sizeBytes: bytes.length,
      lastAccessMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _evictIfNeeded();
    await _saveIndex();
    return file;
  }

  Future<File?> getOrFetch(String url, {String? preferredExtension}) {
    final key = keyForUrl(url);
    return _inflight.putIfAbsent(key, () async {
      try {
        final existing = await getFile(url);
        if (existing != null) return existing;
        final response = await http.get(Uri.parse(url));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }
        final bytes = response.bodyBytes;
        final ext = preferredExtension ?? extensionForUrl(url, fallback: 'bin');
        return put(url, Uint8List.fromList(bytes), ext);
      } finally {
        _inflight.remove(key);
      }
    });
  }

  Future<void> prefetch(String url, {String? preferredExtension}) async {
    try {
      await getOrFetch(url, preferredExtension: preferredExtension);
    } catch (_) {}
  }

  Future<void> _evictIfNeeded() async {
    var entries = _index!.entries.toList()
      ..sort((a, b) => a.value.lastAccessMs.compareTo(b.value.lastAccessMs));
    var total = entries.fold<int>(0, (s, e) => s + e.value.sizeBytes);

    while (entries.length > maxEntries || total > maxTotalBytes) {
      if (entries.isEmpty) break;
      final oldest = entries.removeAt(0);
      _index!.remove(oldest.key);
      total -= oldest.value.sizeBytes;
      final file = _fileFor(oldest.key, oldest.value.extension);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<int> totalBytes() async {
    if (!isSupported) return 0;
    await _ensureReady();
    return _index!.values.fold<int>(0, (s, e) => s + e.sizeBytes);
  }

  Future<void> clear() async {
    if (!isSupported) return;
    await _ensureReady();
    if (_dir != null && await _dir!.exists()) {
      try {
        await _dir!.delete(recursive: true);
      } catch (_) {}
    }
    _dir = null;
    _index = null;
    _initFuture = null;
    _inflight.clear();
  }
}

class _MediaCacheEntry {
  _MediaCacheEntry({
    required this.extension,
    required this.sizeBytes,
    required this.lastAccessMs,
  });

  final String extension;
  final int sizeBytes;
  int lastAccessMs;

  factory _MediaCacheEntry.fromJson(Map<String, dynamic> json) {
    return _MediaCacheEntry(
      extension: json['ext'] as String? ?? 'bin',
      sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
      lastAccessMs: (json['at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'ext': extension,
    'size': sizeBytes,
    'at': lastAccessMs,
  };
}
