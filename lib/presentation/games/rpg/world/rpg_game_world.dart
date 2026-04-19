import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_audio/flame_audio.dart';

import '../models/game_item.dart';
import '../models/verse_fragment.dart';
import 'item_component.dart';
import 'enemy_component.dart';
import 'player_component.dart';
import 'heart_hud_component.dart';
import 'shield_component.dart';
import 'shield_pickup_component.dart';
import 'start_screen_component.dart';

enum GameState {
  start,
  playing,
}

class RpgGameWorld extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final List<VerseFragment> verses;
  final void Function(String verseId) onItemCollected;
  final void Function() onPlayerDead;

  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<PositionComponent> _mapCollisions = [];

  GameState gameState = GameState.start;

  late final SpriteSheet _playerSpriteSheet;
  late final Sprite _itemSprite;
  late final Sprite _shieldSprite;
  late final Sprite _enemySprite;

  StartScreenComponent? _startScreen;
  bool _worldInitialized = false;

  RpgGameWorld({
    required this.verses,
    required this.onItemCollected,
    required this.onPlayerDead,
  });

  @override
  Color backgroundColor() => const Color(0xFF2d5a27); // Verde hierba

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = false; // Activar para ver hitboxes

    await startGame();
  }

  Future<void> startGame() async {
    if (gameState == GameState.playing) return;

    gameState = GameState.playing;
    _startScreen?.removeFromParent();

    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play(
        'DarkWinds.ogg',
        volume: 0.4,
      );
    }

    await _loadWorld();
  }

  Future<void> _loadWorld() async {
    if (_worldInitialized) return;
    _worldInitialized = true;

    // Limpieza agresiva inicial para evitar duplicidades
    world.removeAll(world.children);
    _mapCollisions.clear();

    // Tile size real del mapa: 16x16
    // Escala 3x para pixel art legible
    const double tileSize = 16;
    const double scale = 3.0;

    // Configurar Joystick para móvil
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 15,
        paint: Paint()..color = const Color(0x88FFFFFF),
      ),
      background: CircleComponent(
        radius: 40,
        paint: Paint()..color = const Color(0x44FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    // Pre-cargar el tileset para evitar errores de renderizado
    await images.load('tiles.png');

    final tiled = await TiledComponent.load(
      'world_map.tmx',
      Vector2.all(tileSize),
    );
    tiled.scale = Vector2.all(scale);
    tiled.anchor = Anchor.topLeft;
    tiled.position = Vector2.zero();
    world.add(tiled);

    final map = tiled.tileMap.map;

    // Collisiones como componentes con hitbox
    final collisionsLayer = map.layerByName('collisions') as ObjectGroup?;
    if (collisionsLayer != null) {
      for (final obj in collisionsLayer.objects) {
        final collisionComp = PositionComponent(
          position: Vector2(obj.x * scale, obj.y * scale),
          size: Vector2(obj.width * scale, obj.height * scale),
        )..add(RectangleHitbox()..collisionType = CollisionType.passive);
        _mapCollisions.add(collisionComp);
        world.add(collisionComp);
      }
    }

    // Jugador y sprites
    final characterImage = await images.load('maika.png');
    _playerSpriteSheet = SpriteSheet(
      image: characterImage,
      srcSize: Vector2(256, 341.33), // 1024 / 4 x 1024 / 3
    );

    final bookImage = await images.load('item_book_red.png');
    _itemSprite = Sprite(bookImage);

    final shieldImage = await images.load('shield_gold.png');
    _shieldSprite = Sprite(shieldImage);

    final enemyImage = await images.load('enemy.png');
    _enemySprite = Sprite(enemyImage);

    // Proyectil: usamos ball1.png como sprite de la bala.
    final projectileImage = await images.load('ball1.png');
    final projectileSprite = Sprite(projectileImage);

    // Dimensiones reales del mapa en píxeles (ya escaladas).
    final mapWidth = tileSize * map.width * scale;
    final mapHeight = tileSize * map.height * scale;

    // RNG compartido para ítems y escudo.
    final random = Random();

    // Libros (fragmentos) colocados de forma aleatoria por el mapa,
    // evitando bordes y que queden demasiado juntos.
    final items = <GameItem>[];
    final positions = <Vector2>[];
    final desiredCount = verses.length < 7 ? verses.length : 7;

    const double marginTiles = 2; // margen de 2 tiles por lado
    final double marginX = marginTiles * tileSize * scale;
    final double marginY = marginTiles * tileSize * scale;
    final double minDistance = tileSize * scale * 3; // separación mínima

    for (var i = 0; i < desiredCount; i++) {
      Vector2 candidate = Vector2.zero();
      for (var attempt = 0; attempt < 20; attempt++) {
        final x =
            marginX + random.nextDouble() * (mapWidth - marginX * 2);
        final y =
            marginY + random.nextDouble() * (mapHeight - marginY * 2);
        final pos = Vector2(x, y);

        var tooClose = false;
        for (final existing in positions) {
          if (existing.distanceTo(pos) < minDistance) {
            tooClose = true;
            break;
          }
        }

        candidate = pos;
        if (!tooClose) {
          break;
        }
      }

      positions.add(candidate);
      items.add(
        GameItem(
          verse: verses[i],
          position: candidate,
        ),
      );
    }

    // Jugador
    player = PlayerComponent(
      spriteSheet: _playerSpriteSheet,
      mapCollisions: _mapCollisions,
      // Spawn en el camino central, cerca del cruce
      // Tile (8, 10) -> centrado en el camino
      position: Vector2(
        tileSize * 8 * scale + (tileSize * scale) / 2,
        tileSize * 10 * scale + (tileSize * scale) / 2,
      ),
      displayScale: scale,
      movementBounds: Rect.fromLTWH(0, 0, mapWidth, mapHeight),
    );

    // Verificamos que no haya ya un jugador en el world
    world.children
        .whereType<PlayerComponent>()
        .forEach((p) => p.removeFromParent());
    world.add(player!);

    // Escudo visual que rota alrededor del jugador cuando está equipado.
    final shieldVisual = ShieldComponent(
      player: player!,
      sprite: _shieldSprite,
      offsetDistance: 26 * scale,
      scaleFactor: 1.5 * scale,
    );
    player!.add(shieldVisual);

    // HUD de corazones del jugador (5 corazones por defecto).
    camera.viewport.add(HeartHudComponent());

    // Cámara siguiendo al jugador, con un pequeño offset hacia arriba
    // para ver un poco más de mapa por delante del personaje.
    camera.viewfinder.anchor = const Anchor(0.5, 0.4);
    camera.follow(player!);
    camera.viewfinder.zoom = 1.0; // Usamos escala manual en los componentes

    // Items (libros) en el mundo
    for (final item in items) {
      final comp = ItemComponent(
        verse: item.verse,
        onCollected: _handleItemCollected,
        sprite: _itemSprite,
        position: item.position,
        scale: scale,
      );
      world.add(comp);
    }

    // Spawn aleatorio del escudo en el mapa. El jugador debe recogerlo
    // para poder hacer parry con el proyectil.
    final shieldPosition = Vector2(
      random.nextDouble() * (mapWidth - 48) + 24,
      random.nextDouble() * (mapHeight - 48) + 24,
    );

    final shieldPickup = ShieldPickupComponent(
      sprite: _shieldSprite,
      position: shieldPosition,
      scale: scale,
    );
    world.add(shieldPickup);

    // Enemigo fijo que dispara siempre hacia el jugador.
    final enemyPosition = Vector2(
      tileSize * 10 * scale,
      tileSize * 3 * scale,
    );

    final enemy = EnemyComponent(
      sprite: _enemySprite,
      position: enemyPosition,
      projectileSprite: projectileSprite,
    );

    world.add(enemy);
  }

  void _handleItemCollected(VerseFragment verse) {
    onItemCollected(verse.id);
  }
}

