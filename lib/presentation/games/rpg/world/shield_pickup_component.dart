import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player_component.dart';

/// Escudo en el mapa que el jugador debe recoger antes de poder hacer parry.
class ShieldPickupComponent extends SpriteComponent with CollisionCallbacks {
  ShieldPickupComponent({
    required Sprite sprite,
    required Vector2 position,
    double scale = 3.0,
  }) : super(
          sprite: sprite,
          position: position,
          size: Vector2(16, 16) * scale,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    paint.filterQuality = FilterQuality.none;

    add(
      RectangleHitbox(
        size: size * 0.8,
        anchor: Anchor.center,
      )..collisionType = CollisionType.active,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent) {
      other.equipShield();
      removeFromParent();
    }
  }
}
