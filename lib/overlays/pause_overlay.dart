import 'package:flutter/material.dart';

import '../stack_game.dart';

/// Shown when the player pauses mid-run. Resume / Settings / Main Menu.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final StackGame game;

  @override
  Widget build(BuildContext context) {
    // Absorb taps so they don't fall through to the drop handler.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 32),
              _MenuButton(
                icon: Icons.play_arrow,
                label: 'RESUME',
                color: Colors.green,
                onPressed: game.resumeGame,
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.home,
                label: 'MAIN MENU',
                color: Colors.redAccent,
                onPressed: game.quitToMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
