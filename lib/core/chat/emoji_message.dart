import 'package:characters/characters.dart';
import 'package:mu_study/core/chat/animated_emoji_registry.dart';

String? singleAnimatedEmojiAsset(String? text) {
  if (text == null || text.isEmpty) return null;

  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  if (_containsWhitespace(trimmed)) return null;

  final graphemes = trimmed.characters;
  if (graphemes.length != 1) return null;

  final emoji = graphemes.first;
  return animatedEmojiAssetPath(emoji) ??
      animatedEmojiAssetPath(stripEmojiVariationSelectors(emoji));
}

bool isSingleAnimatedEmojiMessage(String? text) =>
    singleAnimatedEmojiAsset(text) != null;

String? singleAnimatedEmojiGrapheme(String? text) {
  if (!isSingleAnimatedEmojiMessage(text)) return null;
  return text!.trim().characters.first;
}

String stripEmojiVariationSelectors(String emoji) {
  final buffer = StringBuffer();
  for (final r in emoji.runes) {
    if (r == 0xFE0F || r == 0xFE0E) continue;
    buffer.writeCharCode(r);
  }
  return buffer.toString();
}

bool _containsWhitespace(String text) {
  for (final unit in text.runes) {
    if (unit == 0x20 ||
        unit == 0x09 ||
        unit == 0x0A ||
        unit == 0x0D ||
        unit == 0x200B ||
        unit == 0x00A0 ||
        unit == 0xFEFF ||
        unit == 0x2060) {
      return true;
    }
  }
  return false;
}
