import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player_component.dart';
import 'rpg_game_world.dart';

/// Escudo que actúa como colisionador independiente.
///
/// Es hijo del [PlayerComponent] y sigue su dirección de mirada
/// o la dirección analógica del joystick si está siendo usado.
class ShieldComponent extends SpriteComponent
    with CollisionCallbacks, HasGameReference<RpgGameWorld> {
  final PlayerComponent player;

  /// Distancia desde el centro del jugador hasta el centro del escudo.
  final double offsetDistance;

  ShieldComponent({
    required this.player,
    required Sprite sprite,
    this.offsetDistance = 24,
    double scaleFactor = 1.5,
  }) : super(
          sprite: sprite,
          size: Vector2(16, 16) * scaleFactor,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    paint.filterQuality = FilterQuality.none;

    // Hitbox circular independiente
    add(
      CircleHitbox()..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Si el joystick se está usando, usamos su dirección analógica
    // para permitir que el escudo gire libremente 360° alrededor del jugador.
    Vector2 dir;
    final joystickDelta = game.joystick.relativeDelta;
    if (!joystickDelta.isZero()) {
      dir = joystickDelta.normalized();
    } else {
      // Si no hay joystick, usamos la última dirección de mirada del jugador.
      dir = player.facingDirection.length2 == 0
          ? Vector2(0, 1)
          : player.facingDirection.normalized();
    }

    position = dir * offsetDistance;

    // Escudo semitransparente cuando todavía no está activado.
    opacity = player.hasShield ? 1.0 : 0.3;
  }
}

