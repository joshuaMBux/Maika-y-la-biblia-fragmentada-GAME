import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

import 'rpg_game_world.dart';

enum PlayerDirection { down, left, right, up }

class PlayerComponent extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<RpgGameWorld> {
  final double speed;
  final List<PositionComponent> mapCollisions;
  final SpriteSheet spriteSheet;
  final Rect? movementBounds;

  Vector2 moveDirection = Vector2.zero();
  /// Dirección de mirada del jugador, normalizada.
  /// Por defecto mira hacia abajo.
  Vector2 facingDirection = Vector2(0, 1);

  bool hasShield = false;

  /// Vida del jugador en corazones (5 por defecto).
  final int maxHearts = 5;
  int currentHearts = 5;
  bool isDead = false;

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
    this.movementBounds,
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

    // Actualizar dirección de mirada desde el joystick si hay input.
    // Priorizar teclado, pero si es cero, usar Joystick
    if (moveDirection.isZero()) {
      if (!game.joystick.relativeDelta.isZero()) {
        final joystickDelta = game.joystick.relativeDelta;
        moveDirection = joystickDelta;
        _updateDirectionFromJoystick(joystickDelta);
      }
    }

    if (!moveDirection.isZero()) {
      final normalized = moveDirection.normalized();
      // facingDirection siempre sigue la última dirección de movimiento
      facingDirection = normalized;
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
      
      _clampToBounds();
      _updateWalkAnimation();
    } else {
      _updateIdleAnimation();
    }

    // Resetear moveDirection para el siguiente frame si viene del teclado
    // Si viene del joystick, se sobreescribe en el siguiente frame
    moveDirection = Vector2.zero();
  }

  void _updateDirectionFromJoystick(Vector2 delta) {
    if (!delta.isZero()) {
      facingDirection = delta.normalized();
    }

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

  void _clampToBounds() {
    if (movementBounds == null) return;

    final bounds = movementBounds!;
    final halfWidth = size.x / 2;
    final height = size.y;

    final minX = bounds.left + halfWidth;
    final maxX = bounds.right - halfWidth;
    final minY = bounds.top + height;
    final maxY = bounds.bottom;

    position = Vector2(
      position.x.clamp(minX, maxX),
      position.y.clamp(minY, maxY),
    );
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
      facingDirection = Vector2(-1, 0);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveDirection.x = 1;
      currentDirection = PlayerDirection.right;
      facingDirection = Vector2(1, 0);
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      moveDirection.y = -1;
      currentDirection = PlayerDirection.up;
      facingDirection = Vector2(0, -1);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      moveDirection.y = 1;
      currentDirection = PlayerDirection.down;
      facingDirection = Vector2(0, 1);
    }
    return true;
  }

  /// Se llama cuando el jugador recoge el escudo del mapa.
  void equipShield() {
    hasShield = true;
  }

  /// Aplica daño al jugador cuando es alcanzado por un proyectil enemigo.
  void takeHit() {
    if (currentHearts <= 0 || isDead) {
      return;
    }
    currentHearts -= 1;
    if (currentHearts < 0) {
      currentHearts = 0;
    }

    if (currentHearts <= 0 && !isDead) {
      isDead = true;
      // Avisamos al mundo para que notifique al BLoC que el jugador ha muerto.
      game.onPlayerDead();
    }
  }
}
