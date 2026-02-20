import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/verse_fragment.dart';
import 'rpg_game_event.dart';
import 'rpg_game_state.dart';

typedef VersesLoader = Future<List<VerseFragment>> Function();

class RpgGameBloc extends Bloc<RpgGameEvent, RpgGameState> {
  final VersesLoader loadVerses;

  RpgGameBloc({required this.loadVerses}) : super(RpgGameInitial()) {
    on<LoadGame>(_onLoadGame);
    on<ItemCollected>(_onItemCollected);
  }

  Future<void> _onLoadGame(
    LoadGame event,
    Emitter<RpgGameState> emit,
  ) async {
    emit(RpgGameLoading());
    try {
      final verses = await loadVerses();
      emit(
        RpgGameLoaded(
          collectedCount: 0,
          totalItems: verses.length,
          verses: verses,
        ),
      );
    } catch (_) {
      emit(
        RpgGameLoaded(
          collectedCount: 0,
          totalItems: 0,
          verses: const [],
        ),
      );
    }
  }

  void _onItemCollected(
    ItemCollected event,
    Emitter<RpgGameState> emit,
  ) {
    final current = state;
    if (current is RpgGameLoaded) {
      if (current.verses.isEmpty) {
        emit(current);
        return;
      }
      final verse = current.verses.firstWhere(
        (v) => v.id == event.verseId,
        orElse: () => current.verses.first,
      );
      final newCount = current.collectedCount + 1;
      if (newCount >= current.totalItems && current.totalItems > 0) {
        emit(RpgGameCompleted(current.verses));
      } else {
        emit(
          current.copyWith(
            collectedCount: newCount,
            lastCollectedVerse: verse,
          ),
        );
      }
    }
  }
}
