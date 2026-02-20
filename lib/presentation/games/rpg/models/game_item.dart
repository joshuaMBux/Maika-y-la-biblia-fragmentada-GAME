import 'package:flame/components.dart';

import 'verse_fragment.dart';

class GameItem {
  final VerseFragment verse;
  final Vector2 position;

  const GameItem({
    required this.verse,
    required this.position,
  });
}
