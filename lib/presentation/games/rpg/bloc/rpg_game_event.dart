abstract class RpgGameEvent {}

class LoadGame extends RpgGameEvent {}

class ItemCollected extends RpgGameEvent {
  final String verseId;

  ItemCollected(this.verseId);
}

/// Evento disparado cuando el jugador se queda sin corazones.
class PlayerDied extends RpgGameEvent {}
