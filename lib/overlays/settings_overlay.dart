import 'package:flutter/material.dart';

import '../stack_game.dart';

/// Settings panel: a single, clear Sound On/Off control and a Back button.
class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({super.key, required this.game});

  final StackGame game;

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) {
    final storage = widget.game.scoreManager;
    final soundOn = storage.soundOn;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      // ListTiles/Switches need a Material ancestor; overlays render outside
      // the app's Scaffold so we provide one here.
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1E33),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SETTINGS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
                const SizedBox(height: 24),

                // Sound toggle — big, tappable row.
                _SettingRow(
                  icon: soundOn ? Icons.volume_up : Icons.volume_off,
                  label: 'Sound',
                  valueLabel: soundOn ? 'On' : 'Off',
                  value: soundOn,
                  onChanged: (v) async {
                    await storage.setSoundOn(v);
                    if (mounted) setState(() {});
                  },
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.game.closeSettings,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('BACK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded row with an icon, label, current value and a switch. Tapping the
/// whole row toggles, for a larger, friendlier hit target.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            Text(valueLabel,
                style: TextStyle(
                    color: value ? Colors.greenAccent : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
