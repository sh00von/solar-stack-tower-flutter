import 'dart:ui';

/// A visual zone: background gradient, block colour parameters and an accent
/// (used for particles / highlights). The tower marches through these as it
/// climbs, giving each stretch of floors a distinct mood like a real game.
class ZoneTheme {
  const ZoneTheme({
    required this.name,
    required this.systemName,
    required this.galaxyName,
    required this.universeName,
    required this.bgTop,
    required this.bgBottom,
    required this.blockHue,
    required this.blockSat,
    required this.blockLight,
    required this.accent,
    this.speedMultiplier = 1.0,
    this.magnetChanceBias = 0.0,
    this.slowMoChanceBias = 0.0,
    this.wideChanceBias = 0.0,
  });

  final String name;
  final String systemName;
  final String galaxyName;
  final String universeName;
  final Color bgTop;
  final Color bgBottom;
  final double blockHue; // base hue; per-level march is added on top
  final double blockSat;
  final double blockLight;
  final Color accent;

  // Gameplay modifiers
  final double speedMultiplier;
  final double magnetChanceBias; // additive offset to selection probability
  final double slowMoChanceBias;
  final double wideChanceBias;

  static ZoneTheme lerp(ZoneTheme a, ZoneTheme b, double t) => ZoneTheme(
        name: t < 0.5 ? a.name : b.name,
        systemName: t < 0.5 ? a.systemName : b.systemName,
        galaxyName: t < 0.5 ? a.galaxyName : b.galaxyName,
        universeName: t < 0.5 ? a.universeName : b.universeName,
        bgTop: Color.lerp(a.bgTop, b.bgTop, t)!,
        bgBottom: Color.lerp(a.bgBottom, b.bgBottom, t)!,
        blockHue: _lerpHue(a.blockHue, b.blockHue, t),
        blockSat: lerpDouble(a.blockSat, b.blockSat, t)!,
        blockLight: lerpDouble(a.blockLight, b.blockLight, t)!,
        accent: Color.lerp(a.accent, b.accent, t)!,
        speedMultiplier: lerpDouble(a.speedMultiplier, b.speedMultiplier, t)!,
        magnetChanceBias: lerpDouble(a.magnetChanceBias, b.magnetChanceBias, t)!,
        slowMoChanceBias: lerpDouble(a.slowMoChanceBias, b.slowMoChanceBias, t)!,
        wideChanceBias: lerpDouble(a.wideChanceBias, b.wideChanceBias, t)!,
      );

  static double _lerpHue(double a, double b, double t) {
    // Shortest path around the colour wheel.
    var diff = b - a;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (a + diff * t) % 360;
  }
}

/// Planets/zones the tower travels through as it climbs.
/// 26 zones grouped into 12 systems, 6 galaxies, and 3 universes.
const List<ZoneTheme> kZones = [
  // === UNIVERSE 1: THE SOL-VEIL (Real Space) ===
  // GALAXY 1: MILKY WAY
  // System 1.1: Solar System
  ZoneTheme(
    name: 'EARTH',
    systemName: 'Solar System',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF8FD3FF),
    bgBottom: Color(0xFF2E7D55),
    blockHue: 200,
    blockSat: 0.55,
    blockLight: 0.62,
    accent: Color(0xFFBFEFFF),
  ),
  ZoneTheme(
    name: 'MOON',
    systemName: 'Solar System',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF3A3F4A),
    bgBottom: Color(0xFF0C0E14),
    blockHue: 220,
    blockSat: 0.10,
    blockLight: 0.70,
    accent: Color(0xFFE6E9F0),
    slowMoChanceBias: 0.1, // easy zone, more slow-mo
  ),
  ZoneTheme(
    name: 'MARS',
    systemName: 'Solar System',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFFD97B4A),
    bgBottom: Color(0xFF5A1E12),
    blockHue: 18,
    blockSat: 0.62,
    blockLight: 0.58,
    accent: Color(0xFFFFC9A3),
    speedMultiplier: 1.05,
  ),
  ZoneTheme(
    name: 'JUPITER',
    systemName: 'Solar System',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFFC9A36B),
    bgBottom: Color(0xFF6E3B2A),
    blockHue: 35,
    blockSat: 0.55,
    blockLight: 0.60,
    accent: Color(0xFFFFE2B0),
    speedMultiplier: 1.10,
    wideChanceBias: 0.1, // big planet, more wide blocks
  ),

  // System 1.2: Proxima Reach
  ZoneTheme(
    name: 'PROXIMA B',
    systemName: 'Proxima Reach',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF632B30),
    bgBottom: Color(0xFF190B0D),
    blockHue: 345,
    blockSat: 0.50,
    blockLight: 0.45,
    accent: Color(0xFFFF8A93),
    speedMultiplier: 1.15,
  ),
  ZoneTheme(
    name: 'CENTAURI PRIME',
    systemName: 'Proxima Reach',
    galaxyName: 'Milky Way',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF1E3F66),
    bgBottom: Color(0xFF0E1E38),
    blockHue: 210,
    blockSat: 0.60,
    blockLight: 0.50,
    accent: Color(0xFF8CE2FF),
    speedMultiplier: 1.20,
    magnetChanceBias: 0.15,
  ),

  // GALAXY 2: ANDROMEDA
  // System 1.3: Kepler Void
  ZoneTheme(
    name: 'KEPLER-186F',
    systemName: 'Kepler Void',
    galaxyName: 'Andromeda',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF1D5A3A),
    bgBottom: Color(0xFF092414),
    blockHue: 145,
    blockSat: 0.50,
    blockLight: 0.48,
    accent: Color(0xFF8DFFC4),
    speedMultiplier: 1.25,
  ),
  ZoneTheme(
    name: 'KEPLER-452B',
    systemName: 'Kepler Void',
    galaxyName: 'Andromeda',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF7A6A32),
    bgBottom: Color(0xFF2E260D),
    blockHue: 48,
    blockSat: 0.52,
    blockLight: 0.44,
    accent: Color(0xFFFFF099),
    speedMultiplier: 1.30,
    wideChanceBias: 0.15,
  ),

  // System 1.4: Orion Dust
  ZoneTheme(
    name: 'ORION PULSAR',
    systemName: 'Orion Dust',
    galaxyName: 'Andromeda',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF4A154B),
    bgBottom: Color(0xFF1A051C),
    blockHue: 290,
    blockSat: 0.55,
    blockLight: 0.50,
    accent: Color(0xFFF78FFF),
    speedMultiplier: 1.35,
    magnetChanceBias: 0.1,
  ),
  ZoneTheme(
    name: 'HELIX EYE',
    systemName: 'Orion Dust',
    galaxyName: 'Andromeda',
    universeName: 'The Sol-Veil',
    bgTop: Color(0xFF0D5C75),
    bgBottom: Color(0xFF031A24),
    blockHue: 195,
    blockSat: 0.70,
    blockLight: 0.45,
    accent: Color(0xFF7DFAFF),
    speedMultiplier: 1.40,
    slowMoChanceBias: 0.15,
  ),

  // === UNIVERSE 2: THE QUANTUM REALMS ===
  // GALAXY 3: SHADOW VALE
  // System 2.1: Void Core
  ZoneTheme(
    name: 'EVENT HORIZON',
    systemName: 'Void Core',
    galaxyName: 'Shadow Vale',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF120024),
    bgBottom: Color(0xFF020005),
    blockHue: 275,
    blockSat: 0.90,
    blockLight: 0.35,
    accent: Color(0xFFD683FF),
    speedMultiplier: 1.45,
  ),
  ZoneTheme(
    name: 'ANTI-MATTER',
    systemName: 'Void Core',
    galaxyName: 'Shadow Vale',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF2C0A0A),
    bgBottom: Color(0xFF0A0202),
    blockHue: 0,
    blockSat: 0.85,
    blockLight: 0.40,
    accent: Color(0xFFFF5252),
    speedMultiplier: 1.50,
    magnetChanceBias: 0.2, // highly polarized magnetic fields!
  ),

  // System 2.2: Abyss Deeps
  ZoneTheme(
    name: 'DARK MATTER',
    systemName: 'Abyss Deeps',
    galaxyName: 'Shadow Vale',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF0F172A),
    bgBottom: Color(0xFF020617),
    blockHue: 220,
    blockSat: 0.30,
    blockLight: 0.25,
    accent: Color(0xFF94A3B8),
    speedMultiplier: 1.55,
  ),
  ZoneTheme(
    name: 'SINGULARITY',
    systemName: 'Abyss Deeps',
    galaxyName: 'Shadow Vale',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF000000),
    bgBottom: Color(0xFF130F26),
    blockHue: 250,
    blockSat: 0.95,
    blockLight: 0.30,
    accent: Color(0xFFBB86FC),
    speedMultiplier: 1.60,
    slowMoChanceBias: 0.2, // time slows down near singularity
  ),

  // GALAXY 4: QUANTUM WEAVE
  // System 2.3: String Fields
  ZoneTheme(
    name: 'MICROCOSM',
    systemName: 'String Fields',
    galaxyName: 'Quantum Weave',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF0B2E24),
    bgBottom: Color(0xFF010A07),
    blockHue: 165,
    blockSat: 0.65,
    blockLight: 0.40,
    accent: Color(0xFF5DFFA6),
    speedMultiplier: 1.65,
  ),
  ZoneTheme(
    name: 'SUPERSTRING',
    systemName: 'String Fields',
    galaxyName: 'Quantum Weave',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF3B0764),
    bgBottom: Color(0xFF0F051D),
    blockHue: 270,
    blockSat: 0.80,
    blockLight: 0.45,
    accent: Color(0xFFE879F9),
    speedMultiplier: 1.70,
    wideChanceBias: 0.2,
  ),

  // System 2.4: Hadron Soup
  ZoneTheme(
    name: 'QUARK CORE',
    systemName: 'Hadron Soup',
    galaxyName: 'Quantum Weave',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF831843),
    bgBottom: Color(0xFF2D0616),
    blockHue: 330,
    blockSat: 0.85,
    blockLight: 0.48,
    accent: Color(0xFFF472B6),
    speedMultiplier: 1.75,
  ),
  ZoneTheme(
    name: 'GLUON CLOUD',
    systemName: 'Hadron Soup',
    galaxyName: 'Quantum Weave',
    universeName: 'Quantum Realms',
    bgTop: Color(0xFF7C2D12),
    bgBottom: Color(0xFF2C0F05),
    blockHue: 15,
    blockSat: 0.80,
    blockLight: 0.45,
    accent: Color(0xFFFB923C),
    speedMultiplier: 1.80,
    slowMoChanceBias: 0.1,
    magnetChanceBias: 0.1,
  ),

  // === UNIVERSE 3: THE MULTIVERSE ===
  // GALAXY 5: CYBER SPHERE
  // System 3.1: Neon Grid
  ZoneTheme(
    name: 'GLITCH CITY',
    systemName: 'Neon Grid',
    galaxyName: 'Cyber Sphere',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF0F172A),
    bgBottom: Color(0xFF090D16),
    blockHue: 180,
    blockSat: 0.90,
    blockLight: 0.50,
    accent: Color(0xFF06B6D4),
    speedMultiplier: 1.85,
  ),
  ZoneTheme(
    name: 'VECTOR EDGE',
    systemName: 'Neon Grid',
    galaxyName: 'Cyber Sphere',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF1E1E1E),
    bgBottom: Color(0xFF0A0A0A),
    blockHue: 120,
    blockSat: 0.95,
    blockLight: 0.45,
    accent: Color(0xFF22C55E),
    speedMultiplier: 1.90,
    slowMoChanceBias: 0.25,
  ),

  // System 3.2: Memory Bank
  ZoneTheme(
    name: 'DATA STREAM',
    systemName: 'Memory Bank',
    galaxyName: 'Cyber Sphere',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF172554),
    bgBottom: Color(0xFF070B1E),
    blockHue: 225,
    blockSat: 0.85,
    blockLight: 0.48,
    accent: Color(0xFF3B82F6),
    speedMultiplier: 1.95,
  ),
  ZoneTheme(
    name: 'MAINBOARD',
    systemName: 'Memory Bank',
    galaxyName: 'Cyber Sphere',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF064E3B),
    bgBottom: Color(0xFF021E14),
    blockHue: 155,
    blockSat: 0.90,
    blockLight: 0.42,
    accent: Color(0xFF10B981),
    speedMultiplier: 2.00,
    magnetChanceBias: 0.25,
  ),

  // GALAXY 6: ELYSIUM
  // System 3.3: Celestial Gate
  ZoneTheme(
    name: 'ETHER DUST',
    systemName: 'Celestial Gate',
    galaxyName: 'Elysium',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF1E1B4B),
    bgBottom: Color(0xFF0A0822),
    blockHue: 250,
    blockSat: 0.75,
    blockLight: 0.55,
    accent: Color(0xFF818CF8),
    speedMultiplier: 2.05,
  ),
  ZoneTheme(
    name: 'AURELIA',
    systemName: 'Celestial Gate',
    galaxyName: 'Elysium',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF451A03),
    bgBottom: Color(0xFF140500),
    blockHue: 30,
    blockSat: 0.80,
    blockLight: 0.58,
    accent: Color(0xFFFBBF24),
    speedMultiplier: 2.10,
    wideChanceBias: 0.25,
  ),

  // System 3.4: Eternity
  ZoneTheme(
    name: 'CHRONOS',
    systemName: 'Eternity',
    galaxyName: 'Elysium',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF311042),
    bgBottom: Color(0xFF100316),
    blockHue: 285,
    blockSat: 0.70,
    blockLight: 0.50,
    accent: Color(0xFFD946EF),
    speedMultiplier: 2.15,
  ),
  ZoneTheme(
    name: 'ENDPOINT',
    systemName: 'Eternity',
    galaxyName: 'Elysium',
    universeName: 'The Multiverse',
    bgTop: Color(0xFF000000),
    bgBottom: Color(0xFF050505),
    blockHue: 0,
    blockSat: 0.0,
    blockLight: 0.90,
    accent: Color(0xFFFFFFFF),
    speedMultiplier: 2.25,
    slowMoChanceBias: 0.2,
    magnetChanceBias: 0.2,
    wideChanceBias: 0.2,
  ),
];

const int kFloorsPerZone = 15;

/// Smoothly interpolated theme for a given tower [height]. Transitions over the
/// last few floors of each zone so the change isn't abrupt.
ZoneTheme themeForHeight(int height) {
  final zoneFloat = height / kFloorsPerZone;
  final idx = zoneFloat.floor();
  final a = kZones[idx % kZones.length];
  final b = kZones[(idx + 1) % kZones.length];
  final frac = zoneFloat - idx;
  // Hold the zone, then blend across the final 25% into the next one.
  const blendStart = 0.75;
  if (frac < blendStart) return a;
  final t = (frac - blendStart) / (1 - blendStart);
  return ZoneTheme.lerp(a, b, t);
}

/// True on the exact floor a new zone begins (for the "ENTERING …" banner).
bool isZoneBoundary(int height) =>
    height > 0 && height % kFloorsPerZone == 0;

String zoneName(int height) =>
    kZones[(height ~/ kFloorsPerZone) % kZones.length].name;
