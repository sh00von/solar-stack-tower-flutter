import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../game/missions.dart';
import '../game/theme_zones.dart';
import '../stack_game.dart';

/// Start screen: title, Play, a settings gear, and a stats row.
/// Custom designed with deep glassmorphism and neon gradients to look extremely premium.
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  final StackGame game;

  Widget _buildGlowButton({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    required List<Color> colors,
    required Color glowColor,
  }) {
    final enabled = onPressed != null;
    return Container(
      width: 260,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled ? colors : [Colors.white12, Colors.white12],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: enabled ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 if (icon != null) ...[
                   Icon(icon, color: enabled ? Colors.white : Colors.white24, size: 20),
                   const SizedBox(width: 8),
                 ],
                 Text(
                   text,
                   style: TextStyle(
                     color: enabled ? Colors.white : Colors.white24,
                     fontSize: 16,
                     fontWeight: FontWeight.w900,
                     letterSpacing: 2,
                   ),
                 ),
               ],
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    double padding = 16.0,
    double width = 300.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = game.scoreManager;
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SOLAR\nSTACK\nTOWER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(blurRadius: 16, color: Colors.indigoAccent),
                          Shadow(blurRadius: 32, color: Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap anywhere to drop a block. Perfect alignments regrow width!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons list
                    _buildGlowButton(
                      onPressed: game.startClassic,
                      text: 'PLAY CLASSIC',
                      colors: [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
                      glowColor: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 14),

                    ValueListenableBuilder<int>(
                      valueListenable: game.selectedJourneyCheckpointNotifier,
                      builder: (context, selectedIndex, _) {
                        return _buildGlowButton(
                          onPressed: game.journeyUnlocked
                              ? () => _showCheckpointSelector(context)
                              : null,
                          text: game.journeyUnlocked
                              ? 'JOURNEY · ${kZones[selectedIndex % kZones.length].name}'
                              : 'JOURNEY (LOCKED)',
                          icon: Icons.rocket_launch,
                          colors: [const Color(0xFFDB2777), const Color(0xFF7C3AED)],
                          glowColor: const Color(0xFFEC4899),
                        );
                      }
                    ),
                    if (!game.journeyUnlocked)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Reach the next planet to unlock Journey',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Stats Dashboard Card
                    _buildGlassCard(
                      width: 320,
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _Stat(label: 'BEST', value: '${s.best}'),
                          _Stat(
                              label: 'COINS',
                              value: '${s.coins}',
                              color: Colors.amber),
                          _Stat(label: 'GAMES', value: '${s.totalGames}'),
                          _Stat(label: 'COMBO', value: '${s.bestCombo}'),
                          _Stat(
                              label: 'PLANET',
                              value: game.journeyStartPlanet,
                              color: Colors.purpleAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Missions Card
                    _buildGlassCard(
                      width: 320,
                      child: _MissionPanel(missions: s.currentMissions()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckpointSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              decoration: BoxDecoration(
                color: const Color(0xEC090514), // obsidian translucent
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,
                maxChildSize: 1.0,
                minChildSize: 1.0,
                expand: true,
                builder: (_, controller) {
                  // Group zones by Universe, Galaxy, and System
                  final Map<String, Map<String, Map<String, List<(int, ZoneTheme)>>>> hierarchy = {};
                  
                  for (int i = 0; i < kZones.length; i++) {
                    final zone = kZones[i];
                    hierarchy.putIfAbsent(zone.universeName, () => {});
                    hierarchy[zone.universeName]!.putIfAbsent(zone.galaxyName, () => {});
                    hierarchy[zone.universeName]![zone.galaxyName]!.putIfAbsent(zone.systemName, () => []);
                    hierarchy[zone.universeName]![zone.galaxyName]![zone.systemName]!.add((i, zone));
                  }

                  final furthest = game.furthestPlanet;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'COSMIC CHECKPOINTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select your space journey coordinates',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            controller: controller,
                            children: hierarchy.entries.map((universeEntry) {
                              final universeName = universeEntry.key;
                              final galaxies = universeEntry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(
                                    universeName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  children: galaxies.entries.map((galaxyEntry) {
                                    final galaxyName = galaxyEntry.key;
                                    final systems = galaxyEntry.value;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            galaxyName.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.amberAccent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...systems.entries.map((systemEntry) {
                                            final systemName = systemEntry.key;
                                            final zonesList = systemEntry.value;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Text(
                                                    systemName.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white60,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                ),
                                                ...zonesList.map((pair) {
                                                  final idx = pair.$1;
                                                  final zone = pair.$2;
                                                  final isUnlocked = idx <= furthest;
                                                  
                                                  return ValueListenableBuilder<int>(
                                                    valueListenable: game.selectedJourneyCheckpointNotifier,
                                                    builder: (context, selectedIdx, _) {
                                                      final isSelected = selectedIdx == idx;

                                                      return Container(
                                                        margin: const EdgeInsets.only(bottom: 6),
                                                        decoration: BoxDecoration(
                                                          color: isSelected 
                                                              ? zone.accent.withValues(alpha: 0.08)
                                                              : Colors.transparent,
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(
                                                            color: isSelected 
                                                                ? zone.accent.withValues(alpha: 0.4) 
                                                                : Colors.transparent,
                                                          ),
                                                        ),
                                                        child: ListTile(
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                          leading: Icon(
                                                            isUnlocked ? Icons.public : Icons.lock,
                                                            color: isUnlocked ? zone.accent : Colors.white24,
                                                            size: 20,
                                                          ),
                                                          title: Text(
                                                            zone.name,
                                                            style: TextStyle(
                                                              color: isUnlocked ? Colors.white : Colors.white38,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            isUnlocked 
                                                                ? 'Floor ${idx * kFloorsPerZone} · Speed x${zone.speedMultiplier.toStringAsFixed(2)}'
                                                                : 'Floor ${idx * kFloorsPerZone} (Locked)',
                                                            style: TextStyle(
                                                              color: isUnlocked ? Colors.white54 : Colors.white24,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                          trailing: isUnlocked
                                                              ? (isSelected 
                                                                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                                                                  : const Icon(Icons.play_arrow, color: Colors.white54))
                                                              : null,
                                                          onTap: isUnlocked
                                                              ? () {
                                                                  game.selectedJourneyCheckpointNotifier.value = idx;
                                                                  Navigator.pop(ctx);
                                                                  game.startJourney();
                                                                }
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  );
                                                }),
                                                const SizedBox(height: 6),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

}


class _MissionPanel extends StatelessWidget {
  const _MissionPanel({required this.missions});
  final List<MissionView> missions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.assignment, color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text(
              'MISSIONS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...missions.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.label,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${m.reward}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: m.fraction,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF00FFCC), // glowing cyber cyan progress bar
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m.progress.clamp(0, m.target)} / ${m.target}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
