import '../models/verse_fragment.dart';

abstract class RpgGameState {}

class RpgGameInitial extends RpgGameState {}

class RpgGameLoading extends RpgGameState {}

class RpgGameLoaded extends RpgGameState {
  final int collectedCount;
  final int totalItems;
  final List<VerseFragment> verses;
  final VerseFragment? lastCollectedVerse;

  RpgGameLoaded({
    required this.collectedCount,
    required this.totalItems,
    required this.verses,
    this.lastCollectedVerse,
  });

  RpgGameLoaded copyWith({
    int? collectedCount,
    int? totalItems,
    List<VerseFragment>? verses,
    VerseFragment? lastCollectedVerse,
  }) {
    return RpgGameLoaded(
      collectedCount: collectedCount ?? this.collectedCount,
      totalItems: totalItems ?? this.totalItems,
      verses: verses ?? this.verses,
      lastCollectedVerse: lastCollectedVerse,
    );
  }
}

class RpgGameCompleted extends RpgGameState {
  final List<VerseFragment> verses;

  RpgGameCompleted(this.verses);
}
