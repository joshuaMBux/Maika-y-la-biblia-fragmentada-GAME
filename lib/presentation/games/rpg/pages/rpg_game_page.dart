import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/rpg_game_bloc.dart';
import '../bloc/rpg_game_event.dart';
import '../bloc/rpg_game_state.dart';
import '../data/bible_repository.dart';
import '../models/verse_fragment.dart';
import '../world/rpg_game_world.dart';

class RpgGamePage extends StatefulWidget {
  final VersesLoader loadVerses;
  final VoidCallback? onExit;

  const RpgGamePage({super.key, required this.loadVerses, this.onExit});

  factory RpgGamePage.prototype({Key? key, VoidCallback? onExit}) {
    final repository = BibleRepository();
    return RpgGamePage(
      key: key,
      loadVerses: () => repository.getRpgVerses(),
      onExit: onExit,
    );
  }

  @override
  State<RpgGamePage> createState() => _RpgGamePageState();
}

class _RpgGamePageState extends State<RpgGamePage> {
  late final RpgGameBloc bloc;
  RpgGameWorld? game;
  VerseFragment? currentVerse;
  Timer? verseTimer;

  @override
  void initState() {
    super.initState();
    bloc = RpgGameBloc(loadVerses: widget.loadVerses)..add(LoadGame());
  }

  @override
  void dispose() {
    verseTimer?.cancel();
    bloc.close();
    super.dispose();
  }

  void _createGame(List<VerseFragment> verses) {
    game = RpgGameWorld(
      verses: verses,
      onItemCollected: (id) {
        bloc.add(ItemCollected(id));
      },
    );
  }

  void _showVerse(VerseFragment verse) {
    verseTimer?.cancel();
    setState(() {
      currentVerse = verse;
    });
    verseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          currentVerse = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<RpgGameBloc, RpgGameState>(
        listener: (context, state) {
          if (state is RpgGameLoaded && state.lastCollectedVerse != null) {
            _showVerse(state.lastCollectedVerse!);
          }
        },
        builder: (context, state) {
          if (state is RpgGameLoading || state is RpgGameInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is RpgGameLoaded) {
            if (game == null) {
              _createGame(state.verses);
            }
            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(child: GameWidget(game: game!)),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _HudCounter(
                      collected: state.collectedCount,
                      total: state.totalItems,
                    ),
                  ),
                  if (currentVerse != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _VersePopup(verse: currentVerse!),
                      ),
                    ),
                  Positioned(
                    top: 32,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: widget.onExit,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is RpgGameCompleted) {
            return Scaffold(
              body: Stack(
                children: [
                  if (game != null)
                    Positioned.fill(child: GameWidget(game: game!)),
                  _VictoryOverlay(
                    onBackToMenu: widget.onExit,
                    onPlayAgain: () {
                      setState(() {
                        game = null;
                      });
                      bloc.add(LoadGame());
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HudCounter extends StatelessWidget {
  final int collected;
  final int total;

  const _HudCounter({required this.collected, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        'Fragmentos: $collected/$total',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VersePopup extends StatelessWidget {
  final VerseFragment verse;

  const _VersePopup({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verse.reference,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verse.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _VictoryOverlay extends StatelessWidget {
  final VoidCallback? onBackToMenu;
  final VoidCallback onPlayAgain;

  const _VictoryOverlay({
    required this.onBackToMenu,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Has reunido todos los fragmentos!',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: onBackToMenu,
                    child: const Text('Volver al menú'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: onPlayAgain,
                    child: const Text('Jugar de nuevo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
