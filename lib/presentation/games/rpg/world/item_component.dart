import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../models/verse_fragment.dart';
import 'player_component.dart';

class ItemComponent extends SpriteComponent with CollisionCallbacks {
  final VerseFragment verse;
  final void Function(VerseFragment verse) onCollected;

  ItemComponent({
    required this.verse,
    required this.onCollected,
    required Sprite sprite,
    required Vector2 position,
  }) : super(
          sprite: sprite,
          size: Vector2.all(32),
          position: position,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox()
        ..collisionType = CollisionType.passive
        ..isSolid = false,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      onCollected(verse);
      removeFromParent();
    }
  }
}
