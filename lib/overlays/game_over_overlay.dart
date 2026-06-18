import 'package:flutter/material.dart';

import '../stack_game.dart';


/// Shown when a drop misses. Surfaces score, best, coins earned this run, an
/// optional **Continue** (revive) and a big instant **Retry**.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});

  final StackGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final score = game.scoreNotifier.value;
    final best = game.currentBest;
    final isRecord = score >= best && score > 0;
    final modeLabel = game.isJourney ? 'JOURNEY' : 'CLASSIC';
    final showContinue = game.canReviveWithCoins || game.canReviveWithAd;

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              modeLabel,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text('Score  $score',
                style: const TextStyle(color: Colors.white, fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              isRecord ? 'New Best!  $best' : 'Best  $best',
              style: TextStyle(
                color: isRecord ? Colors.amber : Colors.white70,
                fontSize: 22,
                fontWeight: isRecord ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text('+${game.coinsThisRun}',
                    style: const TextStyle(color: Colors.white70, fontSize: 18)),
              ],
            ),
            if (game.lastCompletedMissions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('MISSION COMPLETE',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    ...game.lastCompletedMissions.map((m) => Text(m,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 36),
            if (showContinue) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (game.canReviveWithCoins)
                    _ReviveButton(
                      icon: Icons.monetization_on,
                      iconColor: Colors.amber,
                      label: '${StackGame.reviveCost} coins',
                      color: const Color(0xFF1B5E20),
                      onPressed: () async => game.continueWithCoins(),
                    ),
                  if (game.canReviveWithCoins && game.canReviveWithAd)
                    const SizedBox(width: 12),
                  if (game.canReviveWithAd)
                    _ReviveButton(
                      icon: Icons.ondemand_video,
                      iconColor: Colors.lightBlueAccent,
                      label: 'Watch Ad',
                      color: const Color(0xFF0D47A1),
                      onPressed: () => game.continueWithAd(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: game.startGame,
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviveButton extends StatelessWidget {
  const _ReviveButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
