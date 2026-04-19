import 'package:flame/components.dart';

import 'rpg_game_world.dart';

/// HUD simple que muestra la vida del jugador en forma de corazones.
class HeartHudComponent extends TextComponent
    with HasGameReference<RpgGameWorld> {
  HeartHudComponent()
      : super(
          text: '',
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(16, 16);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = game.player;
    if (player == null) return;

    final maxHearts = player.maxHearts;
    final current = player.currentHearts;

    final buffer = StringBuffer();
    for (var i = 0; i < maxHearts; i++) {
      buffer.write(i < current ? '♥ ' : '♡ ');
    }

    text = buffer.toString();
  }
}

