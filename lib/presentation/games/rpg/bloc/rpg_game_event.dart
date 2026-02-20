abstract class RpgGameEvent {}

class LoadGame extends RpgGameEvent {}

class ItemCollected extends RpgGameEvent {
  final String verseId;

  ItemCollected(this.verseId);
}
