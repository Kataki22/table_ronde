class StickerModel {
  final String id;
  final String name;       // display label under the sticker
  final String assetPath;  // e.g. 'assets/stickers/pack1/smile.png'
  final String emoji;      // fallback emoji shown when asset is missing

  const StickerModel({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.emoji,
  });
}

class StickerPack {
  final String id;
  final String packName;
  final String thumbEmoji;          // emoji shown as pack icon in the tab bar
  final List<StickerModel> stickers;

  const StickerPack({
    required this.id,
    required this.packName,
    required this.thumbEmoji,
    required this.stickers,
  });
}

// ---------------------------------------------------------------------------
// Static sample packs – replace assetPath values with your real assets.
// ---------------------------------------------------------------------------
const List<StickerPack> sampleStickerPacks = [
  StickerPack(
    id: 'emotions',
    packName: 'Emotions',
    thumbEmoji: '😊',
    stickers: [
      StickerModel(id: 'e1', name: 'Happy',      assetPath: 'assets/stickers/emotions/happy.png',      emoji: '😄'),
      StickerModel(id: 'e2', name: 'Laughing',   assetPath: 'assets/stickers/emotions/laughing.png',   emoji: '😂'),
      StickerModel(id: 'e3', name: 'Wink',       assetPath: 'assets/stickers/emotions/wink.png',       emoji: '😉'),
      StickerModel(id: 'e4', name: 'Love',       assetPath: 'assets/stickers/emotions/love.png',       emoji: '😍'),
      StickerModel(id: 'e5', name: 'Thinking',   assetPath: 'assets/stickers/emotions/thinking.png',   emoji: '🤔'),
      StickerModel(id: 'e6', name: 'Surprised',  assetPath: 'assets/stickers/emotions/surprised.png',  emoji: '😲'),
      StickerModel(id: 'e7', name: 'Sad',        assetPath: 'assets/stickers/emotions/sad.png',        emoji: '😢'),
      StickerModel(id: 'e8', name: 'Angry',      assetPath: 'assets/stickers/emotions/angry.png',      emoji: '😠'),
    ],
  ),
  StickerPack(
    id: 'gestures',
    packName: 'Gestures',
    thumbEmoji: '👋',
    stickers: [
      StickerModel(id: 'g1', name: 'Wave',       assetPath: 'assets/stickers/gestures/wave.png',       emoji: '👋'),
      StickerModel(id: 'g2', name: 'Thumbs Up',  assetPath: 'assets/stickers/gestures/thumbsup.png',  emoji: '👍'),
      StickerModel(id: 'g3', name: 'Clap',       assetPath: 'assets/stickers/gestures/clap.png',       emoji: '👏'),
      StickerModel(id: 'g4', name: 'Pray',       assetPath: 'assets/stickers/gestures/pray.png',       emoji: '🙏'),
      StickerModel(id: 'g5', name: 'Muscle',     assetPath: 'assets/stickers/gestures/muscle.png',     emoji: '💪'),
      StickerModel(id: 'g6', name: 'OK',         assetPath: 'assets/stickers/gestures/ok.png',         emoji: '👌'),
      StickerModel(id: 'g7', name: 'Peace',      assetPath: 'assets/stickers/gestures/peace.png',      emoji: '✌️'),
      StickerModel(id: 'g8', name: 'Fire',       assetPath: 'assets/stickers/gestures/fire.png',       emoji: '🔥'),
    ],
  ),
  StickerPack(
    id: 'animals',
    packName: 'Animals',
    thumbEmoji: '🐶',
    stickers: [
      StickerModel(id: 'a1', name: 'Dog',        assetPath: 'assets/stickers/animals/dog.png',        emoji: '🐶'),
      StickerModel(id: 'a2', name: 'Cat',        assetPath: 'assets/stickers/animals/cat.png',        emoji: '🐱'),
      StickerModel(id: 'a3', name: 'Bunny',      assetPath: 'assets/stickers/animals/bunny.png',      emoji: '🐰'),
      StickerModel(id: 'a4', name: 'Bear',       assetPath: 'assets/stickers/animals/bear.png',       emoji: '🐻'),
      StickerModel(id: 'a5', name: 'Penguin',    assetPath: 'assets/stickers/animals/penguin.png',    emoji: '🐧'),
      StickerModel(id: 'a6', name: 'Frog',       assetPath: 'assets/stickers/animals/frog.png',       emoji: '🐸'),
      StickerModel(id: 'a7', name: 'Monkey',     assetPath: 'assets/stickers/animals/monkey.png',     emoji: '🐒'),
      StickerModel(id: 'a8', name: 'Owl',        assetPath: 'assets/stickers/animals/owl.png',        emoji: '🦉'),
    ],
  ),
  StickerPack(
    id: 'food',
    packName: 'Food',
    thumbEmoji: '🍕',
    stickers: [
      StickerModel(id: 'f1', name: 'Pizza',      assetPath: 'assets/stickers/food/pizza.png',      emoji: '🍕'),
      StickerModel(id: 'f2', name: 'Burger',     assetPath: 'assets/stickers/food/burger.png',     emoji: '🍔'),
      StickerModel(id: 'f3', name: 'Taco',       assetPath: 'assets/stickers/food/taco.png',       emoji: '🌮'),
      StickerModel(id: 'f4', name: 'Sushi',      assetPath: 'assets/stickers/food/sushi.png',      emoji: '🍣'),
      StickerModel(id: 'f5', name: 'Cake',       assetPath: 'assets/stickers/food/cake.png',       emoji: '🎂'),
      StickerModel(id: 'f6', name: 'Coffee',     assetPath: 'assets/stickers/food/coffee.png',     emoji: '☕'),
      StickerModel(id: 'f7', name: 'Ice Cream',  assetPath: 'assets/stickers/food/icecream.png',   emoji: '🍦'),
      StickerModel(id: 'f8', name: 'Donut',      assetPath: 'assets/stickers/food/donut.png',      emoji: '🍩'),
    ],
  ),
];
