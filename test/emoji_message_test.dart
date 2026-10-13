import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mu_study/core/chat/animated_emoji_registry.dart';
import 'package:mu_study/core/chat/emoji_message.dart';

void main() {
  group('singleAnimatedEmojiAsset', () {
    test('animates exact single supported emoji', () {
      expect(singleAnimatedEmojiAsset('❤️'), contains('Heart.json'));
      expect(singleAnimatedEmojiAsset('❤'), contains('Heart.json'));
      expect(singleAnimatedEmojiAsset('😂'), contains('LMAO-2 side tears.json'));
      expect(singleAnimatedEmojiAsset('🤣'), contains('LMAO.json'));
      expect(singleAnimatedEmojiAsset('👍'), contains('Thumb.json'));
      expect(singleAnimatedEmojiAsset('🔥'), contains('Fire.json'));
      // Party.json is party-face; party-popper lives in Confetti emoji.json.
      expect(singleAnimatedEmojiAsset('🎉'), contains('Confetti emoji.json'));
      expect(singleAnimatedEmojiAsset('🥳'), contains('Party.json'));
      expect(singleAnimatedEmojiAsset('😎'), contains('Cool emoji.json'));
      expect(singleAnimatedEmojiAsset('😴'), contains('Sleepy.json'));
      expect(singleAnimatedEmojiAsset('😢'), contains('Crying emoji.json'));
      expect(singleAnimatedEmojiAsset('😭'), contains('Sad emoji to Crying emoji.json'));
      expect(singleAnimatedEmojiAsset('✅'), contains('check-mark.json'));
      expect(singleAnimatedEmojiAsset('✔️'), contains('check-mark.json'));
      expect(singleAnimatedEmojiAsset('😀'), contains('smiley emoji.json'));
      expect(singleAnimatedEmojiAsset('😤'), contains('Mad emoji.json'));
      expect(singleAnimatedEmojiAsset('😡'), contains('Angry.json'));
      expect(singleAnimatedEmojiAsset('🤩'), contains('Star Strike Emoji.json'));
      expect(singleAnimatedEmojiAsset('🚶'), contains('Emoji Walking.json'));
      expect(singleAnimatedEmojiAsset('🖕'), contains('Middle finger.json'));
    });

    test('trims outer whitespace and normalizes VS16', () {
      expect(singleAnimatedEmojiAsset(' 😂 '), contains('LMAO-2 side tears.json'));
      expect(singleAnimatedEmojiAsset('😂\uFE0F'), contains('LMAO-2 side tears.json'));
      expect(singleAnimatedEmojiAsset('👍\uFE0F'), contains('Thumb.json'));
    });

    test('rejects multiples, text mixes, spaces, unsupported', () {
      expect(singleAnimatedEmojiAsset('❤️❤️'), isNull);
      expect(singleAnimatedEmojiAsset('😂❤️'), isNull);
      expect(singleAnimatedEmojiAsset('Hello ❤️'), isNull);
      expect(singleAnimatedEmojiAsset('❤️ hello'), isNull);
      expect(singleAnimatedEmojiAsset('😂😂😂'), isNull);
      expect(singleAnimatedEmojiAsset('👍 👍'), isNull);
      expect(singleAnimatedEmojiAsset('A'), isNull);
      expect(singleAnimatedEmojiAsset('1'), isNull);
      expect(singleAnimatedEmojiAsset('🐸'), isNull);
      expect(singleAnimatedEmojiAsset(''), isNull);
      expect(singleAnimatedEmojiAsset(null), isNull);
    });
  });

  group('lottie asset coverage', () {
    test('every asset file is referenced by the registry', () {
      final dir = Directory('assets/lottie');
      final onDisk = dir
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json'))
          .toSet();
      final mapped = registeredAnimatedEmojiFilenames
          .union(kAnimatedEmojiRedundantFilenames);
      final unused = onDisk.difference(mapped);
      expect(
        unused,
        isEmpty,
        reason: 'Unused Lottie files: ${unused.join(', ')}',
      );
    });

    test('every registry filename exists on disk', () {
      final dir = Directory('assets/lottie');
      final onDisk = dir
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json'))
          .toSet();
      final missing = registeredAnimatedEmojiFilenames.difference(onDisk);
      expect(
        missing,
        isEmpty,
        reason: 'Missing Lottie files: ${missing.join(', ')}',
      );
    });
  });
}
