import 'package:flutter/material.dart';

import '../components/block.dart';
import '../game/theme_zones.dart';
import '../stack_game.dart';

/// In-game HUD: score + multiplier, coins, a transient milestone/zone banner,
/// the incoming power-up indicator, and a slow-mo flag.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final StackGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Pause button + coins, top-left.
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: IconButton(
                    iconSize: 26,
                    color: Colors.white,
                    icon: const Icon(Icons.pause),
                    onPressed: game.pauseGame,
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<int>(
                  valueListenable: game.coinsNotifier,
                  builder: (_, coins, _) => _Pill(
                    icon: Icons.monetization_on,
                    iconColor: Colors.amber,
                    label: '$coins',
                  ),
                ),
              ],
            ),
          ),
          // Incoming power-up, top-right.
          Positioned(
            top: 16,
            right: 16,
            child: ValueListenableBuilder<BlockPower>(
              valueListenable: game.powerNotifier,
              builder: (_, power, _) => _PowerChip(power: power),
            ),
          ),
          // Score + multiplier, centred near the top.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: game.scoreNotifier,
                    builder: (_, score, _) => Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.multiplierNotifier,
                    builder: (_, mult, _) => AnimatedOpacity(
                      opacity: mult > 1 ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        'x$mult',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Combo + slow-mo badges.
          Align(
            alignment: const Alignment(0, -0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: game.comboNotifier,
                  builder: (_, combo, _) => AnimatedOpacity(
                    opacity: combo > 1 ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: _Badge(
                      'PERFECT x$combo',
                      color: Colors.amber,
                      textColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: game.slowMoNotifier,
                  builder: (_, slow, _) => AnimatedOpacity(
                    opacity: slow ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: _Badge('SLOW-MO',
                        color: Colors.lightBlueAccent,
                        textColor: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          // Current planet, bottom centre.
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: game.planetNotifier,
                builder: (_, planet, _) {
                  // Find matching zone theme for system/galaxy labels
                  final zone = kZones.firstWhere((z) => z.name == planet, orElse: () => kZones.first);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: zone.accent.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${zone.universeName.toUpperCase()} · ${zone.galaxyName.toUpperCase()}',
                          style: TextStyle(
                            color: zone.accent.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public, color: zone.accent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${zone.systemName.toUpperCase()} : $planet',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Milestone / zone banner, centre screen.
          Align(
            alignment: const Alignment(0, -0.15),
            child: ValueListenableBuilder<String?>(
              valueListenable: game.bannerNotifier,
              builder: (_, text, _) => AnimatedScale(
                scale: text == null ? 0.6 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: text == null ? 0 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    text ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [Shadow(blurRadius: 16, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.icon, required this.iconColor, required this.label});
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.color, required this.textColor});
  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _PowerChip extends StatelessWidget {
  const _PowerChip({required this.power});
  final BlockPower power;

  @override
  Widget build(BuildContext context) {
    if (power == BlockPower.none) return const SizedBox.shrink();
    final (label, color, icon) = switch (power) {
      BlockPower.slowMo => ('SLOW-MO', Colors.lightBlueAccent, Icons.hourglass_bottom),
      BlockPower.wide => ('WIDE', Colors.greenAccent, Icons.unfold_more),
      BlockPower.magnet => ('MAGNET', Colors.amberAccent, Icons.adjust),
      BlockPower.none => ('', Colors.white, Icons.help),
    };
    return _Pill(icon: icon, iconColor: color, label: label);
  }
}
