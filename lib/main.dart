import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import 'presentation/games/rpg/pages/rpg_game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlameAudio.bgm.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maika y la Biblia Fragmentada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A2C8A)),
        useMaterial3: true,
      ),
      home: RpgGamePage.prototype(),
    );
  }
}
