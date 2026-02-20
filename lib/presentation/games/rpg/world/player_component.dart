import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

enum PlayerDirection { down, left, right, up }

class PlayerComponent extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FlameGame> {
  final double speed;
  final List<Rect> collisions;
  final SpriteSheet spriteSheet;

  Vector2 moveDirection = Vector2.zero();
  PlayerDirection currentDirection = PlayerDirection.down;

  late SpriteAnimation _idleDown;
  late SpriteAnimation _idleLeft;
  late SpriteAnimation _idleRight;
  late SpriteAnimation _idleUp;
  late SpriteAnimation _walkDown;
  late SpriteAnimation _walkLeft;
  late SpriteAnimation _walkRight;
  late SpriteAnimation _walkUp;

  PlayerComponent({
    required this.spriteSheet,
    required this.collisions,
    this.speed = 100,
    Vector2? position,
  }) : super(size: Vector2.all(32), position: position ?? Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _idleDown = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.3,
      from: 0,
      to: 1,
    );
    _walkDown = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.15,
      from: 1,
      to: 5,
    );
    _idleLeft = spriteSheet.createAnimation(
      row: 1,
      stepTime: 0.3,
      from: 0,
      to: 1,
    );
    _walkLeft = spriteSheet.createAnimation(
      row: 1,
      stepTime: 0.15,
      from: 1,
      to: 5,
    );
    _idleRight = spriteSheet.createAnimation(
      row: 2,
      stepTime: 0.3,
      from: 0,
      to: 1,
    );
    _walkRight = spriteSheet.createAnimation(
      row: 2,
      stepTime: 0.15,
      from: 1,
      to: 5,
    );
    _idleUp = spriteSheet.createAnimation(
      row: 3,
      stepTime: 0.3,
      from: 0,
      to: 1,
    );
    _walkUp = spriteSheet.createAnimation(
      row: 3,
      stepTime: 0.15,
      from: 1,
      to: 5,
    );
    animation = _idleDown;
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (moveDirection.length2 > 0) {
      final normalized = moveDirection.normalized();
      final delta = normalized * speed * dt;
      final original = position.clone();
      position.add(Vector2(delta.x, 0));
      if (_isColliding()) {
        position.x = original.x;
      }
      position.add(Vector2(0, delta.y));
      if (_isColliding()) {
        position.y = original.y;
      }
      _updateWalkAnimation();
    } else {
      _updateIdleAnimation();
    }
  }

  bool _isColliding() {
    final rect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    for (final other in collisions) {
      if (rect.overlaps(other)) {
        return true;
      }
    }
    return false;
  }

  void _updateWalkAnimation() {
    switch (currentDirection) {
      case PlayerDirection.down:
        animation = _walkDown;
        break;
      case PlayerDirection.left:
        animation = _walkLeft;
        break;
      case PlayerDirection.right:
        animation = _walkRight;
        break;
      case PlayerDirection.up:
        animation = _walkUp;
        break;
    }
  }

  void _updateIdleAnimation() {
    switch (currentDirection) {
      case PlayerDirection.down:
        animation = _idleDown;
        break;
      case PlayerDirection.left:
        animation = _idleLeft;
        break;
      case PlayerDirection.right:
        animation = _idleRight;
        break;
      case PlayerDirection.up:
        animation = _idleUp;
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
