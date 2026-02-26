import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../models/verse_fragment.dart';
import 'player_component.dart';

class ItemComponent extends SpriteComponent with CollisionCallbacks {
  final VerseFragment verse;
  final void Function(VerseFragment verse) onCollected;

  ItemComponent({
    required Sprite sprite,
    required Vector2 position,
    required this.onCollected,
    required this.verse,
    double scale = 3.0,
  }) : super(
          sprite: sprite,
          position: position,
          size: Vector2(16, 16) * scale, // ajustar si el sprite no es 16x16 real
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Pixel art nítido
    paint.filterQuality = FilterQuality.none;

    add(
      RectangleHitbox(
        size: size * 0.6,
        anchor: Anchor.center,
      )..collisionType = CollisionType.active,
    );
  }

  void collect() {
    onCollected(verse);
    removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      collect();
    }
  }
}
