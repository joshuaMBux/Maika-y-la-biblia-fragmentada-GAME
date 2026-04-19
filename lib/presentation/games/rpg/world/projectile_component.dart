import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'enemy_component.dart';
import 'player_component.dart';
import 'rpg_game_world.dart';
import 'shield_component.dart';

class ProjectileComponent extends SpriteComponent
    with CollisionCallbacks, HasGameReference<RpgGameWorld> {
  ProjectileComponent({
    required this.velocity,
    required this.owner,
    required Vector2 position,
    double radius = 6,
    Sprite? sprite,
  }) : super(
          sprite: sprite,
          position: position,
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  Vector2 velocity;
  bool hasBounced = false;
  final EnemyComponent owner;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    paint.filterQuality = FilterQuality.none;

    add(
      CircleHitbox()..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Substeps simples para reducir tunelización a altas velocidades.
    final halfDt = dt * 0.5;
    position += velocity * halfDt;
    position += velocity * halfDt;

    // Eliminar si sale de la pantalla de juego.
    final bounds = game.size;
    if (position.x < -32 ||
        position.y < -32 ||
        position.x > bounds.x + 32 ||
        position.y > bounds.y + 32) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Colisión con el escudo (parry direccional)
    if (other is ShieldComponent) {
      // Evitar reprocesar el rebote si ya se hizo.
      if (hasBounced) {
        return;
      }

      final player = other.player;

      // Solo permitir rebote si el jugador tiene el escudo equipado
      // y aún no ha rebotado.
      if (!hasBounced && player.hasShield) {
        final facing = player.facingDirection.length2 == 0
            ? Vector2(0, 1)
            : player.facingDirection.normalized();
        final toProjectile =
            (position - player.position).normalized(); // desde el jugador

        final dot = facing.dot(toProjectile);

        if (dot > 0.6) {
          // Rebote: normal desde el centro del escudo hacia el proyectil
          final shieldCenter = other.absolutePosition;
          final normal = (position - shieldCenter).normalized();
          final vDotN = velocity.dot(normal);
          velocity = velocity - normal * (2 * vDotN);
          velocity *= 1.15; // pequeño boost de velocidad
          hasBounced = true;

          // Feedback visual: pequeño squash y rotación.
          add(
            ScaleEffect.to(
              Vector2.all(1.2),
              EffectController(
                duration: 0.08,
                reverseDuration: 0.08,
              ),
            ),
          );
          add(
            RotateEffect.by(
              pi / 4,
              EffectController(duration: 0.1),
            ),
          );

          return;
        }
      }

      // Si no cumple las condiciones de rebote, simplemente desaparece.
      removeFromParent();
      return;
    }

    // Colisión con el enemigo después del rebote
    if (other is EnemyComponent) {
      if (hasBounced && other == owner) {
        other.takeDamage(1);
      }
      removeFromParent();
      return;
    }

    // Colisión directa con el jugador (sin escudo / mal ángulo)
    if (other is PlayerComponent) {
      other.takeHit();
      removeFromParent();
      return;
    }

    // Cualquier otra cosa después de rebotar: el proyectil desaparece.
    if (hasBounced) {
      removeFromParent();
    }
  }
}

