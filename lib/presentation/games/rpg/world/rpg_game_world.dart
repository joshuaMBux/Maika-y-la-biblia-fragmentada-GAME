import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tiled/tiled.dart';

import '../models/game_item.dart';
import '../models/verse_fragment.dart';
import 'item_component.dart';
import 'player_component.dart';

class RpgGameWorld extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final List<VerseFragment> verses;
  final void Function(String verseId) onItemCollected;

  final List<Rect> _collisionRects = [];
  PlayerComponent? player;

  late final SpriteSheet _playerSpriteSheet;
  late final Sprite _itemSprite;

  RpgGameWorld({required this.verses, required this.onItemCollected});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final tiled = await TiledComponent.load(
      'maps/world_map.tmx',
      Vector2.all(16),
    );
    add(tiled);
    final map = tiled.tileMap.map;
    final scale = 2.0;

    final collisionsLayer = map.layerByName('collisions') as ObjectGroup?;
    if (collisionsLayer != null) {
      for (final obj in collisionsLayer.objects) {
        _collisionRects.add(
          Rect.fromLTWH(
            obj.x * scale,
            obj.y * scale,
            obj.width * scale,
            obj.height * scale,
          ),
        );
      }
    }

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
            position: Vector2(obj.x * scale, obj.y * scale),
          ),
        );
      }
    }

    final characterImage = await images.load('gfx/character.png');
    _playerSpriteSheet = SpriteSheet(
      image: characterImage,
      srcSize: Vector2.all(32),
    );
    final itemImage = await images.load('gfx/libros.png');
    _itemSprite = Sprite(itemImage);

    player = PlayerComponent(
      spriteSheet: _playerSpriteSheet,
      collisions: _collisionRects,
      position: Vector2.all(32),
    );
    add(player!);

    for (final item in items) {
      add(
        ItemComponent(
          verse: item.verse,
          onCollected: _handleItemCollected,
          sprite: _itemSprite,
          position: item.position,
        ),
      );
    }
  }

  void _handleItemCollected(VerseFragment verse) {
    onItemCollected(verse.id);
  }
}
