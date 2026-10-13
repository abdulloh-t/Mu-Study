library;

const String kAnimatedEmojiAssetPrefix = 'assets/lottie/';

const Map<String, String> kAnimatedEmojiAssets = {
  '❤️': 'Heart.json',
  '❤': 'Heart.json',
  '😍': 'Heart eyes.json',
  '😘': 'Emoji 30 - Lovely Kiss.json', // face + hearts (kiss), not 💋 mark
  '💋': 'Emoji 30 - Lovely Kiss.json',

  '😂': 'LMAO-2 side tears.json',
  '🤣': 'LMAO.json',
  '😀': 'smiley emoji.json', // composition: Grinning Face
  '😎': 'Cool emoji.json',
  '😉': 'Winking Emoji.json',
  '😜': 'Zany tongue.json',
  '😌': 'Calm.json',
  '😋': 'Yummy.json',

  '😢': 'Crying emoji.json',
  '😭': 'Sad emoji to Crying emoji.json',
  '😔': 'Pensive.json',
  '😞': 'Sad Emoji.json', // composition is pensive-like; closest sad we have
  '🥹': 'Holding back tears.json',

  '😠': 'Angry Face.json',
  '😡': 'Angry.json', // composition: emoji_pouting
  '😤': 'Mad emoji.json', // composition: steam from nose
  '😈': 'Angry Face with Horns.json',
  '🤬': 'Angry Face with Symbols on Mouth Emoji.json',
  '😖': 'Confounded Face.json', // filename; layers read as confused mouth
  '😕': 'Confounded Face.json',
  '🤢': 'Puke Emoji.json',
  '🤒': 'Sick face with thermometer.json',
  '😷': 'Sick face with thermometer.json',
  '🤕': 'injury head face emoji.json',
  '😵': 'Dizzy Face.json',
  '🥶': 'Cold Face.json',
  '🥵': 'High Temperature.json',
  '😴': 'Sleepy.json',
  '🥱': 'Yawn Emoji.json',
  '🤤': 'Drooling Face.json',
  '🤐': 'Zipper mouth Emoji.json',
  '🙄': 'Rolling Eyes Emoji.json',
  '😐': 'Neutral face.json',
  '🤔': 'Thinking.json',
  '😅': 'Anxious Face with Sweat.json',
  '😮': 'Astonished Face.json',
  '😲': 'Astonished Face.json',

  '🥳': 'Party.json',
  '🎉': 'Confetti emoji.json',
  '🎊': 'Confetti emoji.json',
  '✨': 'Sparkles Emoji.json',
  '🤩': 'Star Strike Emoji.json',
  '🌟': 'Sparkles Emoji.json', // sparkles, not a star-struck face

  '👍': 'Thumb.json',
  '👏': 'Clapping Hands.json',
  '💪': 'Muscle.json',
  '🙏': 'Please.json', // U+1F64F folded hands
  '🤞': 'Crossed Fingers.json',
  '☝️': 'Index finger.json',
  '👆': 'Backhand Index Pointing Up.json',
  '👇': 'Backhand Index Pointing Down.json',
  '👉': 'Backhand Index Pointing Right.json',
  '🤙': 'Call Me Hand.json',
  '🤚': 'Hand.json',
  '✋': 'Hand.json',
  '🖕': 'Middle finger.json',

  '🔥': 'Fire.json',
  '✅': 'check-mark.json',
  '✔️': 'check-mark.json',
  '✔': 'check-mark.json',
  '☑️': 'check-mark.json',
  '☑': 'check-mark.json',
  '❌': 'X.json',
  '👀': 'Eyes.json',
  '🚀': 'Rocket.json',
  '💰': 'Money.json',
  '💸': 'FlyingMoney.json',
  '🦄': 'Unicorn Emoji.json',
  '👽': 'Alien Emoji.json',
  '🤡': 'Animated Clown Face.json',
  '🤠': 'Cowboy Hat Face.json',
  '😇': 'Halo.json',
  '🚕': 'Taxi.json',
  '💻': 'Laptop.json',
  '⏳': 'Hourglass.json',
  '⌛': 'Hourglass.json',
  '💯': '100% Emoji.json',
  '💣': 'Bomb Emoji.json',
  '💥': 'emoji head explosion.json',
  '🤯': 'emoji head explosion.json', // exploding head
  '🏅': 'Medal Animations.json',
  '🥇': 'Medal Animations.json',
  '🌡️': 'High Temperature.json',
  '🚶': 'Emoji Walking.json',
  '🚶‍♂️': 'Emoji Walking.json',
  '🚶‍♀️': 'Emoji Walking.json',
};

String? animatedEmojiAssetPath(String emoji) {
  final direct = kAnimatedEmojiAssets[emoji];
  if (direct != null) return '$kAnimatedEmojiAssetPrefix$direct';

  final stripped = emoji.replaceAll('\uFE0F', '').replaceAll('\uFE0E', '');
  if (stripped != emoji) {
    final alt = kAnimatedEmojiAssets[stripped];
    if (alt != null) return '$kAnimatedEmojiAssetPrefix$alt';
  }

  final withVs16 = '$stripped\uFE0F';
  final vs = kAnimatedEmojiAssets[withVs16];
  if (vs != null) return '$kAnimatedEmojiAssetPrefix$vs';

  return null;
}

bool isAnimatedEmojiSupported(String emoji) =>
    animatedEmojiAssetPath(emoji) != null;

Set<String> get registeredAnimatedEmojiFilenames =>
    kAnimatedEmojiAssets.values.toSet();

const Set<String> kAnimatedEmojiRedundantFilenames = {
  'Starstruck.json', // same star-struck face as Star Strike Emoji.json → 🤩
};
