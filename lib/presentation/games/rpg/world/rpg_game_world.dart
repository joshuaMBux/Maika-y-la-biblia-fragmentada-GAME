import 'dart:ui';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../models/game_item.dart';
import '../models/verse_fragment.dart';
import 'item_component.dart';
import 'player_component.dart';

class RpgGameWorld extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final List<VerseFragment> verses;
  final void Function(String verseId) onItemCollected;

  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<PositionComponent> _mapCollisions = [];

  late final SpriteSheet _playerSpriteSheet;
  late final Sprite _itemSprite;

  RpgGameWorld({required this.verses, required this.onItemCollected});

  @override
  Color backgroundColor() => const Color(0xFF2d5a27); // Verde hierba

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    debugMode = false; // Activar para ver hitboxes
    
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

    // Fragmentos escalados
    final fragmentsLayer = map.layerByName('fragments') as ObjectGroup?;
    final items = <GameItem>[];
    if (fragmentsLayer != null) {
      final objects = fragmentsLayer.objects;
      final count =
          objects.length < verses.length ? objects.length : verses.length;
      for (var i = 0; i < count; i++) {
        final obj = objects[i];
        final verse = verses[i];
        items.add(
          GameItem(
            verse: verse,
            position: Vector2(
              (obj.x + obj.width / 2) * scale, 
              (obj.y + obj.height / 2) * scale
            ),
          ),
        );
      }
    }

    // Jugador
    final characterImage = await images.load('maika.png');
    _playerSpriteSheet = SpriteSheet(
      image: characterImage,
      srcSize: Vector2(256, 341.33), // 1024 / 4 x 1024 / 3
    );
    final bookImage = await images.load('item_book_red.png');
    // Verificación temporal de tamaño real del sprite
    // (eliminar estos prints cuando esté confirmado)
    // ignore: avoid_print
    print(bookImage.width);
    // ignore: avoid_print
    print(bookImage.height);
    _itemSprite = Sprite(bookImage);

    player = PlayerComponent(
      spriteSheet: _playerSpriteSheet,
      mapCollisions: _mapCollisions,
      position: Vector2(
        tileSize * 4 * scale + (tileSize * scale) / 2,
        tileSize * 4 * scale + (tileSize * scale),
      ),
      displayScale: scale,
    );
    
    // Verificamos que no haya ya un jugador en el world
    world.children.whereType<PlayerComponent>().forEach((p) => p.removeFromParent());
    world.add(player!);

    // Cámara siguiendo al jugador
    camera.follow(player!);
    camera.viewfinder.zoom = 1.0; // Usamos escala manual en los componentes

    // Items
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
  }

  void _handleItemCollected(VerseFragment verse) {
    onItemCollected(verse.id);
  }
}
