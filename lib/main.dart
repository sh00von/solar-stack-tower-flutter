import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'managers/audio_manager.dart';
import 'managers/score_manager.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/menu_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/settings_overlay.dart';
import 'stack_game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safety net: swallow otherwise-uncaught async/platform errors (e.g. flaky
  // audio playback) so a stray exception degrades gracefully instead of
  // crashing the whole app. Errors are still logged in debug.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught (handled): $error');
    return true; // prevent app termination
  };

  // Portrait-only: this is a vertical tower-builder.
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);

  // Load persisted best score and preload audio before showing the game.
  final scoreManager = ScoreManager();
  await scoreManager.load();
  final audioManager = AudioManager(scoreManager);
  await audioManager.preload();

  final game = StackGame(
    scoreManager: scoreManager,
    audioManager: audioManager,
  );

  runApp(StackApp(game: game));
}

class StackApp extends StatelessWidget {
  const StackApp({super.key, required this.game});

  final StackGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // A full-screen tap anywhere drops the current block.
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => game.onTapDrop(),
        child: GameWidget<StackGame>(
          game: game,
          overlayBuilderMap: {
            Overlays.menu: (_, g) => MenuOverlay(game: g),
            Overlays.hud: (_, g) => HudOverlay(game: g),
            Overlays.gameOver: (_, g) => GameOverOverlay(game: g),
            Overlays.settings: (_, g) => SettingsOverlay(game: g),
            Overlays.pause: (_, g) => PauseOverlay(game: g),
          },
        ),
      ),
    );
  }
}
