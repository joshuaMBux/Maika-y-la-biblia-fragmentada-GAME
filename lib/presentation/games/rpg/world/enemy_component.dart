import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'projectile_component.dart';
import 'rpg_game_world.dart';

class EnemyComponent extends SpriteComponent
    with CollisionCallbacks, HasGameReference<RpgGameWorld> {
  EnemyComponent({
    required Sprite sprite,
    required Vector2 position,
    required this.projectileSprite,
    this.shootInterval = 1.8,
    this.projectileSpeed = 140,
  }) : super(
          sprite: sprite,
          position: position,
          size: Vector2(32, 32) * 3.0,
          anchor: Anchor.center,
        );

  final double shootInterval;
  final double projectileSpeed;
  final Sprite projectileSprite;

  double _timeSinceLastShot = 0;
  int _health = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint.filterQuality = FilterQuality.none;

    add(
      RectangleHitbox(
        size: size * 0.7,
        anchor: Anchor.center,
      )..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.player == null || game.gameState != GameState.playing) {
      return;
    }

    _timeSinceLastShot += dt;
    if (_timeSinceLastShot >= shootInterval) {
      _timeSinceLastShot = 0;
      _shootAtPlayer();
    }
  }

  void _shootAtPlayer() {
    final player = game.player;
    if (player == null) return;

    final direction = (player.position - position).normalized();
    final velocity = direction * projectileSpeed;

    final projectile = ProjectileComponent(
      velocity: velocity,
      owner: this,
      position: position + direction * 24,
      sprite: projectileSprite,
    );

    game.world.add(projectile);
  }

  void takeDamage(int amount) {
    _health -= amount;
    if (_health <= 0) {
      removeFromParent();
    }
  }
}
