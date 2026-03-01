import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

import 'rpg_game_world.dart';
import 'item_component.dart';

enum PlayerDirection { down, left, right, up }

class PlayerComponent extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<RpgGameWorld> {
  final double speed;
  final List<PositionComponent> mapCollisions;
  final SpriteSheet spriteSheet;

  Vector2 moveDirection = Vector2.zero();
  PlayerDirection currentDirection = PlayerDirection.down;

  late SpriteAnimation walkDown;
  late SpriteAnimation walkSide;
  late SpriteAnimation walkUp;

  final double displayScale;

  PlayerComponent({
    required this.spriteSheet,
    required this.mapCollisions,
    this.speed = 100,
    this.displayScale = 1.0,
    Vector2? position,
  }) : super(
          size: Vector2(32, 48) * displayScale,
          position: position ?? Vector2.zero(),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Pixel art nítido
    paint.filterQuality = FilterQuality.none;

    walkDown = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.15,
      from: 0,
      to: 4,
    );

    walkSide = spriteSheet.createAnimation(
      row: 1,
      stepTime: 0.15,
      from: 0,
      to: 4,
    );

    walkUp = spriteSheet.createAnimation(
      row: 2,
      stepTime: 0.15,
      from: 0,
      to: 4,
    );

    animation = walkDown;

    // Hitbox solo en los pies (alineada con Anchor.bottomCenter)
    // El tamaño es 16x14 escalado. 
    // Como el padre es Anchor.bottomCenter, la posición 0,0 es el centro de la base.
    add(
      RectangleHitbox(
        size: Vector2(16, 14) * displayScale,
        anchor: Anchor.bottomCenter,
        position: Vector2(0, 0),
      )..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Priorizar teclado, pero si es cero, usar Joystick
    if (moveDirection.isZero()) {
      if (!game.joystick.relativeDelta.isZero()) {
        moveDirection = game.joystick.relativeDelta;
        _updateDirectionFromJoystick(game.joystick.relativeDelta);
      }
    }

    if (!moveDirection.isZero()) {
      final normalized = moveDirection.normalized();
      final delta = normalized * speed * dt;
      final original = position.clone();
      
      position.add(Vector2(delta.x, 0));
      if (_hasObstacleCollision()) {
        position.x = original.x;
      }
      
      position.add(Vector2(0, delta.y));
      if (_hasObstacleCollision()) {
        position.y = original.y;
      }
      
      _updateWalkAnimation();
    } else {
      _updateIdleAnimation();
    }

    // Resetear moveDirection para el siguiente frame si viene del teclado
    // Si viene del joystick, se sobreescribe en el siguiente frame
    moveDirection = Vector2.zero();
  }

  void _updateDirectionFromJoystick(Vector2 delta) {
    if (delta.x.abs() > delta.y.abs()) {
      currentDirection = delta.x > 0 ? PlayerDirection.right : PlayerDirection.left;
    } else {
      currentDirection = delta.y > 0 ? PlayerDirection.down : PlayerDirection.up;
    }
  }

  bool _hasObstacleCollision() {
    final myHitboxes = children.whereType<RectangleHitbox>();
    if (myHitboxes.isEmpty) return false;
    
    final myHitbox = myHitboxes.first;
    // Usamos el Rect relativo al componente y lo desplazamos a la posición world
    // Como el anchor es bottomCenter, la posición es la base del personaje.
    final localRect = myHitbox.toRect();
    final worldRect = localRect.shift(Offset(position.x, position.y));

    for (final obstacle in mapCollisions) {
      // Los obstáculos son PositionComponent (Anchor.topLeft)
      final obsRect = Rect.fromLTWH(
        obstacle.position.x, 
        obstacle.position.y, 
        obstacle.size.x, 
        obstacle.size.y
      );
      if (worldRect.overlaps(obsRect)) {
        return true;
      }
    }
    return false;
  }

  void _updateWalkAnimation() {
    if (currentDirection == PlayerDirection.left) {
      scale.x = 1; // Sprite base mira a la izquierda
    } else if (currentDirection == PlayerDirection.right) {
      scale.x = -1; // Flip horizontal para mirar a la derecha
    } else {
      scale.x = 1; // Reset para arriba/abajo
    }

    switch (currentDirection) {
      case PlayerDirection.down:
        animation = walkDown;
        break;
      case PlayerDirection.left:
      case PlayerDirection.right:
        animation = walkSide;
        break;
      case PlayerDirection.up:
        animation = walkUp;
        break;
    }
  }

  void _updateIdleAnimation() {
    if (currentDirection == PlayerDirection.left) {
      scale.x = 1;
    } else if (currentDirection == PlayerDirection.right) {
      scale.x = -1;
    } else {
      scale.x = 1;
    }

    switch (currentDirection) {
      case PlayerDirection.down:
        animation = walkDown; // Usar el primer frame
        break;
      case PlayerDirection.left:
      case PlayerDirection.right:
        animation = walkSide;
        break;
      case PlayerDirection.up:
        animation = walkUp;
        break;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    moveDirection = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveDirection.x = -1;
      currentDirection = PlayerDirection.left;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveDirection.x = 1;
      currentDirection = PlayerDirection.right;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      moveDirection.y = -1;
      currentDirection = PlayerDirection.up;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      moveDirection.y = 1;
      currentDirection = PlayerDirection.down;
    }
    return true;
  }
}
