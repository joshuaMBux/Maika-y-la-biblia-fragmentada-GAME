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
    on<PlayerDied>(_onPlayerDied);
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
          collectedIds: {},
        ),
      );
    } catch (_) {
      emit(
        RpgGameLoaded(
          collectedCount: 0,
          totalItems: 0,
          verses: const [],
          collectedIds: {},
        ),
      );
    }
  }

  Future<void> _onItemCollected(
    ItemCollected event,
    Emitter<RpgGameState> emit,
  ) async {
    final current = state;
    if (current is! RpgGameLoaded) return;

    // Evitar duplicados
    if (current.collectedIds.contains(event.verseId)) return;

    final newCollectedIds = Set<String>.from(current.collectedIds)
      ..add(event.verseId);

    final verse = current.verses.firstWhere(
      (v) => v.id == event.verseId,
      orElse: () => current.verses.isNotEmpty
          ? current.verses.first
          : current.verses[0], // Evitar null
    );

    final newCount = newCollectedIds.length;

    // Siempre emitimos un estado "loaded" con el último versículo
    // Para que el popup se muestre también en el último fragmento.
    emit(
      current.copyWith(
        collectedCount: newCount,
        lastCollectedVerse: verse,
        collectedIds: newCollectedIds,
      ),
    );

    // Si ya se recogieron todos, emitimos el estado de "completed"
    // después, para que la UI pueda primero mostrar el popup.
    if (newCount >= current.totalItems && current.totalItems > 0) {
      emit(RpgGameCompleted(current.verses, isDeath: false));
    }
  }

  Future<void> _onPlayerDied(
    PlayerDied event,
    Emitter<RpgGameState> emit,
  ) async {
    final current = state;
    if (current is RpgGameLoaded) {
      // Reutilizamos la misma pantalla final que cuando se recogen todos los libros.
      emit(RpgGameCompleted(current.verses, isDeath: true));
    }
  }
}
