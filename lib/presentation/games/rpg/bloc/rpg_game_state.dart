import '../models/verse_fragment.dart';

abstract class RpgGameState {}

class RpgGameInitial extends RpgGameState {}

class RpgGameLoading extends RpgGameState {}

class RpgGameLoaded extends RpgGameState {
  final int collectedCount;
  final int totalItems;
  final List<VerseFragment> verses;
  final VerseFragment? lastCollectedVerse;
  final Set<String> collectedIds;

  RpgGameLoaded({
    required this.collectedCount,
    required this.totalItems,
    required this.verses,
    required this.collectedIds,
    this.lastCollectedVerse,
  });

  RpgGameLoaded copyWith({
    int? collectedCount,
    int? totalItems,
    List<VerseFragment>? verses,
    VerseFragment? lastCollectedVerse,
    Set<String>? collectedIds,
  }) {
    return RpgGameLoaded(
      collectedCount: collectedCount ?? this.collectedCount,
      totalItems: totalItems ?? this.totalItems,
      verses: verses ?? this.verses,
      lastCollectedVerse: lastCollectedVerse,
      collectedIds: collectedIds ?? this.collectedIds,
    );
  }
}

class RpgGameCompleted extends RpgGameState {
  final List<VerseFragment> verses;
  /// true si el juego terminó porque el jugador murió (se quedó sin corazones).
  /// false si terminó porque se recogieron todos los fragmentos.
  final bool isDeath;

  RpgGameCompleted(this.verses, {this.isDeath = false});
}
