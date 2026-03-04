import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'rpg_game_world.dart';

class StartScreenComponent extends Component
    with HasGameReference<RpgGameWorld>, KeyboardHandler {
  // Textos editables
  final String title = 'MAIKA';
  final String subtitle = 'Y LA BIBLIA FRAGMENTADA';
  final String hint = 'PRESIONA ENTER';

  late final TextComponent _titleComp;
  late final TextComponent _subtitleComp;
  late final TextComponent _hintComp;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _titleComp = TextComponent(
      text: title,
      anchor: Anchor.topCenter,
    )..scale = Vector2.all(2.5);

    _subtitleComp = TextComponent(
      text: subtitle,
      anchor: Anchor.topCenter,
    )..scale = Vector2.all(1.6);

    _hintComp = TextComponent(
      text: hint,
      anchor: Anchor.topCenter,
    )..scale = Vector2.all(1.3);

    _updateLayout();

    addAll([
      _titleComp,
      _subtitleComp,
      _hintComp,
    ]);
  }

  void _updateLayout() {
    final size = game.size;

    _titleComp.position = Vector2(
      size.x / 2,
      size.y * 0.35,
    );

    _subtitleComp.position = Vector2(
      size.x / 2,
      size.y * 0.45,
    );

    _hintComp.position = Vector2(
      size.x / 2,
      size.y * 0.60,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateLayout();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      game.startGame();
      return true;
    }
    return false;
  }
}
