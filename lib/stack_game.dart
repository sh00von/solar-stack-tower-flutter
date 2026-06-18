import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/block.dart';
import 'components/falling_block.dart';
import 'components/particle.dart';
import 'game/theme_zones.dart';
import 'managers/ad_manager.dart';
import 'managers/audio_manager.dart';
import 'managers/score_manager.dart';

/// High-level game phases. Overlays are keyed off these.
enum GamePhase { menu, playing, gameOver }

/// Overlay identifier constants (must match keys registered in main.dart).
class Overlays {
  static const menu = 'menu';
  static const hud = 'hud';
  static const gameOver = 'gameOver';
  static const pause = 'pause';
}

/// Isometric 3D "Stack" game with the full hyper-casual feature set: rising
/// pitch combos, a score multiplier + milestones, coins + revive, power-up
/// blocks, themed visual zones with particles, and haptics. Rendering is done
/// by hand on the canvas in [render] for the proper 3-face isometric look.
class StackGame extends FlameGame {
  StackGame({
    required this.scoreManager,
    required this.audioManager,
    required this.adManager,
  });

  final ScoreManager scoreManager;
  final AudioManager audioManager;
  final AdManager adManager;

  // ---- Isometric projection tunables ----------------------------------
  static const double _isoX = 0.62;
  static const double _isoY = 0.31;

  // ---- Gameplay tunables ----------------------------------------------
  static const double initialFootprint = 200;
  static const double perfectTolerance = 9;
  static const double baseSpeed = 150;
  static const double speedStep = 18;
  static const int blocksPerSpeedUp = 4;
  static const double slideAmplitude = 180;
  static const double wideRecovery = 60; // width a `wide` block can regrow
  static const int reviveCost = 15; // coins
  static const int maxRevives = 1;
  static const List<int> milestones = [10, 25, 50, 100, 200, 350, 500];

  // ---- Reactive state for the Flutter overlays ------------------------
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> comboNotifier = ValueNotifier(0);
  final ValueNotifier<int> multiplierNotifier = ValueNotifier(1);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<String?> bannerNotifier = ValueNotifier(null);
  final ValueNotifier<BlockPower> powerNotifier =
      ValueNotifier(BlockPower.none);
  final ValueNotifier<bool> slowMoNotifier = ValueNotifier(false);
  final ValueNotifier<String> planetNotifier = ValueNotifier(kZones.first.name);
  /// Selected checkpoint index for Journey starting level.
  final ValueNotifier<int> selectedJourneyCheckpointNotifier = ValueNotifier(0);

  /// Missions completed in the run that just ended (shown on game over).
  List<String> lastCompletedMissions = [];

  GamePhase phase = GamePhase.menu;

  // ---- Internal state --------------------------------------------------
  final _rng = Random();
  final List<TowerBlock> _blocks = [];
  final List<FallingPiece> _falling = [];
  final List<Particle> _particles = [];
  TowerBlock? _moving;
  double _slideDir = 1;
  double _speed = baseSpeed;
  int _perfectStreak = 0;
  int _maxCombo = 0;
  int _coinsThisRun = 0;
  int _revivesUsed = 0;
  int _blocksSincePower = 0;
  int _nextMilestone = 0;
  int _zoneIdx = 0;
  double _slowMoTimer = 0;
  double _bannerTimer = 0;
  bool _paused = false;
  bool _journeyMode = false;

  bool get isPaused => _paused;

  // Camera + juice
  double _camY = 0;
  double _shake = 0;
  double _flash = 0;
  double _popScale = 1;
  ZoneTheme _theme = kZones.first;

  TowerBlock get _top => _blocks.last;

  // Revive availability (read by the game-over overlay).
  bool get canReviveWithCoins =>
      phase == GamePhase.gameOver &&
      _revivesUsed < maxRevives &&
      scoreManager.coins >= reviveCost;
  bool get canReviveWithAd =>
      phase == GamePhase.gameOver && _revivesUsed < maxRevives;
  int get coinsThisRun => _coinsThisRun;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _theme = themeForHeight(0);
    selectedJourneyCheckpointNotifier.value = furthestPlanet;
    overlays.add(Overlays.menu);
  }

  // ---------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------

  /// Furthest planet (zone index) the player has unlocked, derived from the
  /// best floor ever reached. 0 = Earth.
  int get furthestPlanet => scoreManager.bestFloor ~/ kFloorsPerZone;

  /// Journey is available once at least one planet beyond Earth is unlocked.
  bool get journeyUnlocked => furthestPlanet >= 1;

  bool get isJourney => _journeyMode;

  /// Best score for the current mode (used by the game-over screen).
  int get currentBest =>
      _journeyMode ? scoreManager.journeyBest : scoreManager.best;

  /// Planet name a Journey run would resume at.
  String get journeyStartPlanet => zoneName(selectedJourneyCheckpointNotifier.value * kFloorsPerZone);

  /// Start a fresh Classic run (from Earth, pure high score).
  void startClassic() {
    _journeyMode = false;
    _begin();
  }

  /// Start a Journey run, resuming from the furthest unlocked planet.
  void startJourney() {
    _journeyMode = true;
    _begin();
  }

  /// Restart the run in whatever mode was last played (used by RETRY).
  void startGame() => _begin();

  void _begin() {
    _blocks.clear();
    _falling.clear();
    _particles.clear();
    _slideDir = 1;
    _perfectStreak = 0;
    _maxCombo = 0;
    _coinsThisRun = 0;
    _revivesUsed = 0;
    _blocksSincePower = 0;
    _nextMilestone = 0;
    _slowMoTimer = 0;
    _bannerTimer = 0;
    _flash = 0;
    _shake = 0;
    _popScale = 1;
    scoreNotifier.value = 0;
    comboNotifier.value = 0;
    multiplierNotifier.value = 1;
    coinsNotifier.value = 0;
    bannerNotifier.value = null;
    slowMoNotifier.value = false;
    lastCompletedMissions = [];

    // Journey starts at the selected checkpoint floor; Classic at Earth (0).
    final startLevel =
        _journeyMode ? selectedJourneyCheckpointNotifier.value * kFloorsPerZone : 0;
    _zoneIdx = startLevel ~/ kFloorsPerZone;
    
    // Base speed scaled by the planet's specific speedMultiplier.
    final basePlanetTheme = kZones[_zoneIdx % kZones.length];
    _speed = (baseSpeed + speedStep * (startLevel ~/ blocksPerSpeedUp)) * basePlanetTheme.speedMultiplier;

    _theme = themeForHeight(startLevel);
    planetNotifier.value = zoneName(startLevel);

    _blocks.add(TowerBlock(
      level: startLevel,
      axis: SlideAxis.x,
      cx: 0,
      cz: 0,
      sx: initialFootprint,
      sz: initialFootprint,
      color: _blockColor(startLevel),
    ));
    _camY = _targetCamY();
    _spawnMoving();

    phase = GamePhase.playing;
    overlays
      ..remove(Overlays.menu)
      ..remove(Overlays.gameOver)
      ..add(Overlays.hud);
  }

  // ---------------------------------------------------------------------
  // Pause / settings / quit (in-game UX)
  // ---------------------------------------------------------------------

  void pauseGame() {
    if (phase != GamePhase.playing || _paused) return;
    _paused = true;
    pauseEngine(); // freeze the game loop
    overlays.add(Overlays.pause);
  }

  void resumeGame() {
    if (!_paused) return;
    _paused = false;
    overlays.remove(Overlays.pause);
    resumeEngine();
  }

  /// Abandon the current run and return to the menu.
  void quitToMenu() {
    _paused = false;
    resumeEngine();
    phase = GamePhase.menu;
    _moving = null;
    overlays
      ..remove(Overlays.pause)
      ..remove(Overlays.hud)
      ..remove(Overlays.gameOver)
      ..add(Overlays.menu);
  }

  void _spawnMoving() {
    final below = _top;
    final nextLevel = below.level + 1;
    final axis = below.axis == SlideAxis.x ? SlideAxis.z : SlideAxis.x;

    // Maybe grant a power-up. Not too early, and never back-to-back.
    var power = BlockPower.none;
    _blocksSincePower++;
    if (nextLevel >= 4 && _blocksSincePower >= 7 && _rng.nextDouble() < 0.8) {
      final slowMoWeight = 1.0 + _theme.slowMoChanceBias;
      final wideWeight = 1.0 + _theme.wideChanceBias;
      final magnetWeight = 1.0 + _theme.magnetChanceBias;
      final totalWeight = slowMoWeight + wideWeight + magnetWeight;

      final val = _rng.nextDouble() * totalWeight;
      if (val < slowMoWeight) {
        power = BlockPower.slowMo;
      } else if (val < slowMoWeight + wideWeight) {
        power = BlockPower.wide;
      } else {
        power = BlockPower.magnet;
      }

      _blocksSincePower = 0;
      audioManager.playPowerUp();
    }

    var sx = below.sx;
    var sz = below.sz;
    if (power == BlockPower.wide) {
      if (axis == SlideAxis.x) {
        sx = min(below.sx + wideRecovery, initialFootprint);
      } else {
        sz = min(below.sz + wideRecovery, initialFootprint);
      }
    }

    final moving = TowerBlock(
      level: nextLevel,
      axis: axis,
      cx: below.cx,
      cz: below.cz,
      sx: sx,
      sz: sz,
      color: _blockColor(nextLevel),
      power: power,
    );
    if (axis == SlideAxis.x) {
      moving.cx = below.cx - slideAmplitude;
    } else {
      moving.cz = below.cz - slideAmplitude;
    }
    _slideDir = 1;
    _moving = moving;
    powerNotifier.value = power;
  }

  // ---------------------------------------------------------------------
  // Update loop
  // ---------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);

    if (_slowMoTimer > 0) {
      _slowMoTimer = max(0, _slowMoTimer - dt);
      if (_slowMoTimer == 0) slowMoNotifier.value = false;
    }

    final m = _moving;
    if (phase == GamePhase.playing && m != null) {
      final centre = m.axis == SlideAxis.x ? _top.cx : _top.cz;
      final lo = centre - slideAmplitude;
      final hi = centre + slideAmplitude;
      final speed = _speed * (_slowMoTimer > 0 ? 0.45 : 1.0);
      final delta = _slideDir * speed * dt;
      if (m.axis == SlideAxis.x) {
        m.cx += delta;
        if (m.cx >= hi) {
          m.cx = hi;
          _slideDir = -1;
        } else if (m.cx <= lo) {
          m.cx = lo;
          _slideDir = 1;
        }
      } else {
        m.cz += delta;
        if (m.cz >= hi) {
          m.cz = hi;
          _slideDir = -1;
        } else if (m.cz <= lo) {
          m.cz = lo;
          _slideDir = 1;
        }
      }
    }

    _camY = lerpDouble(_camY, _targetCamY(), (dt * 6).clamp(0, 1))!;

    if (_shake > 0) _shake = max(0, _shake - dt);
    if (_flash > 0) _flash = max(0, _flash - dt * 3);
    if (_popScale != 1) {
      _popScale = lerpDouble(_popScale, 1, (dt * 8).clamp(0, 1))!;
    }
    if (_bannerTimer > 0) {
      _bannerTimer -= dt;
      if (_bannerTimer <= 0) bannerNotifier.value = null;
    }

    // Ease the visual theme toward the current height's zone.
    final target = themeForHeight(_blocks.length);
    _theme = ZoneTheme.lerp(_theme, target, (dt * 2.5).clamp(0, 1));

    for (final f in _falling) {
      f.update(dt);
    }
    _falling.removeWhere((f) => f.dead);
    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.dead);
  }

  // ---------------------------------------------------------------------
  // Player input: a tap drops the current block.
  // ---------------------------------------------------------------------

  void onTapDrop() {
    if (phase != GamePhase.playing || _paused) return;
    final m = _moving;
    if (m == null) return;

    audioManager.playClick();
    _shake = 0.16;

    final onX = m.axis == SlideAxis.x;
    final movingC = onX ? m.cx : m.cz;
    final belowC = onX ? _top.cx : _top.cz;
    final delta = (movingC - belowC).abs();
    final isMagnet = m.power == BlockPower.magnet;

    // --- Perfect stack (or magnet auto-perfect) -------------------------
    if (delta <= perfectTolerance || isMagnet) {
      if (onX) {
        m.cx = _top.cx;
      } else {
        m.cz = _top.cz;
      }
      _perfectStreak++;
      _maxCombo = max(_maxCombo, _perfectStreak);
      _flash = 0.6;
      _popScale = 1.10 + min(_perfectStreak, 8) * 0.02;
      audioManager.playPerfect(_perfectStreak);

      final mult = 1 + _perfectStreak ~/ 2;
      multiplierNotifier.value = mult;
      comboNotifier.value = _perfectStreak;
      _addScore((1 + 1) * mult); // base + perfect bonus, times multiplier
      _earnCoins(1);
      _spawnPerfectParticles(m);

      _place(m);
      return;
    }

    _perfectStreak = 0;
    comboNotifier.value = 0;
    multiplierNotifier.value = 1;

    // --- Normal drop: keep only the overlap on the active axis -----------
    final movingLo = onX ? m.xLeft : m.zNear;
    final movingHi = onX ? m.xRight : m.zFar;
    final belowLo = onX ? _top.xLeft : _top.zNear;
    final belowHi = onX ? _top.xRight : _top.zFar;

    final overlapLo = max(movingLo, belowLo);
    final overlapHi = min(movingHi, belowHi);
    final overlap = overlapHi - overlapLo;

    if (overlap <= 0) {
      _addFalling(m, onX ? (movingC < belowC ? -1 : 1) : 0,
          onX ? 0 : (movingC < belowC ? -1 : 1));
      _moving = null;
      _gameOver();
      return;
    }

    final overhang = (onX ? m.sx : m.sz) - overlap;
    if (overhang > 0.5) {
      final cutLow = movingLo < belowLo;
      final pieceCentre =
          cutLow ? overlapLo - overhang / 2 : overlapHi + overhang / 2;
      final piece = TowerBlock(
        level: m.level,
        axis: m.axis,
        cx: onX ? pieceCentre : m.cx,
        cz: onX ? m.cz : pieceCentre,
        sx: onX ? overhang : m.sx,
        sz: onX ? m.sz : overhang,
        color: m.color,
      );
      final sign = cutLow ? -1.0 : 1.0;
      _addFalling(piece, onX ? sign : 0, onX ? 0 : sign);
      _spawnSliceParticles(onX ? overlapLo + (cutLow ? 0 : overlap) : m.cx,
          onX ? m.cz : overlapLo + (cutLow ? 0 : overlap), m.yTop);
    }

    final newCentre = (overlapLo + overlapHi) / 2;
    if (onX) {
      m.sx = overlap;
      m.cx = newCentre;
    } else {
      m.sz = overlap;
      m.cz = newCentre;
    }
    _addScore(1);
    _place(m);
  }

  void _place(TowerBlock m) {
    _blocks.add(m);

    // Slow-mo activates once its block is placed.
    if (m.power == BlockPower.slowMo) {
      _slowMoTimer = 4.0;
      slowMoNotifier.value = true;
    }

    if ((_blocks.length - 1) % blocksPerSpeedUp == 0) {
      _speed += speedStep;
    }

    // Zone change banner.
    final z = _top.level ~/ kFloorsPerZone;
    if (z != _zoneIdx) {
      final oldTheme = kZones[_zoneIdx % kZones.length];
      _zoneIdx = z;
      final newTheme = themeForHeight(_top.level);
      planetNotifier.value = newTheme.name;
      
      // Determine hierarchical scale of transition
      if (newTheme.universeName != oldTheme.universeName) {
        _banner('ENTERED ${newTheme.universeName.toUpperCase()}');
      } else if (newTheme.galaxyName != oldTheme.galaxyName) {
        _banner('GALAXY: ${newTheme.galaxyName.toUpperCase()}');
      } else if (newTheme.systemName != oldTheme.systemName) {
        _banner('SYSTEM: ${newTheme.systemName.toUpperCase()}');
      } else {
        _banner('ARRIVING AT ${newTheme.name}');
      }
      
      _flash = max(_flash, 0.4);
    }

    _spawnMoving();
  }

  void _addScore(int points) {
    scoreNotifier.value += points;
    // Milestone rewards.
    while (_nextMilestone < milestones.length &&
        scoreNotifier.value >= milestones[_nextMilestone]) {
      final ms = milestones[_nextMilestone];
      _banner('$ms!');
      _earnCoins(5);
      _flash = max(_flash, 0.5);
      _nextMilestone++;
    }
  }

  void _earnCoins(int n) {
    _coinsThisRun += n;
    coinsNotifier.value = _coinsThisRun;
    audioManager.playCoin();
  }

  void _banner(String text) {
    bannerNotifier.value = text;
    _bannerTimer = 1.6;
  }

  void _addFalling(TowerBlock block, double dx, double dz) {
    block.power = BlockPower.none; // debris shouldn't show power markers
    _falling.add(FallingPiece(
      block: block,
      driftX: dx * (60 + _rng.nextDouble() * 50),
      driftZ: dz * (60 + _rng.nextDouble() * 50),
    ));
  }

  // ---------------------------------------------------------------------
  // Particles
  // ---------------------------------------------------------------------

  void _spawnSliceParticles(double x, double z, double y) {
    for (var i = 0; i < 10; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        z: z,
        vx: (_rng.nextDouble() - 0.5) * 160,
        vy: 60 + _rng.nextDouble() * 160,
        vz: (_rng.nextDouble() - 0.5) * 160,
        color: _theme.accent,
        size: 3 + _rng.nextDouble() * 3,
      ));
    }
  }

  void _spawnPerfectParticles(TowerBlock m) {
    for (var i = 0; i < 14; i++) {
      _particles.add(Particle(
        x: m.cx + (_rng.nextDouble() - 0.5) * m.sx,
        y: m.yTop,
        z: m.cz + (_rng.nextDouble() - 0.5) * m.sz,
        vx: (_rng.nextDouble() - 0.5) * 120,
        vy: 120 + _rng.nextDouble() * 160,
        vz: (_rng.nextDouble() - 0.5) * 120,
        color: const Color(0xFFFFFFFF),
        size: 3 + _rng.nextDouble() * 3,
      ));
    }
  }


  // ---------------------------------------------------------------------
  // Game over + revive
  // ---------------------------------------------------------------------

  Future<void> _gameOver() async {
    phase = GamePhase.gameOver;
    _moving = null;
    powerNotifier.value = BlockPower.none;
    slowMoNotifier.value = false;
    audioManager.playGameOver();
    adManager.onGameOver();

    final runFloor = _blocks.isEmpty ? 0 : _top.level;
    if (_journeyMode) {
      await scoreManager.maybeUpdateJourneyBest(scoreNotifier.value);
    } else {
      await scoreManager.maybeUpdateBest(scoreNotifier.value);
    }
    await scoreManager.maybeUpdateBestCombo(_maxCombo);
    await scoreManager.updateBestFloor(runFloor);
    selectedJourneyCheckpointNotifier.value = furthestPlanet;
    await scoreManager.incrementGames();
    await scoreManager.addCoins(_coinsThisRun);
    _coinsThisRun = 0;

    // Evaluate missions after lifetime stats are updated.
    lastCompletedMissions = await scoreManager.claimCompletedMissions();

    overlays
      ..remove(Overlays.hud)
      ..add(Overlays.gameOver);
  }

  /// Continue by spending coins.
  Future<void> continueWithCoins() async {
    if (!canReviveWithCoins) return;
    final ok = await scoreManager.spendCoins(reviveCost);
    if (ok) _revive();
  }

  /// Continue by watching a rewarded ad.
  void continueWithAd() {
    if (!canReviveWithAd) return;
    adManager.showRewarded(onRewarded: _revive);
  }

  void _revive() {
    _revivesUsed++;
    phase = GamePhase.playing;
    _perfectStreak = 0;
    comboNotifier.value = 0;
    multiplierNotifier.value = 1;
    _spawnMoving();
    overlays
      ..remove(Overlays.gameOver)
      ..add(Overlays.hud);
  }

  // ---------------------------------------------------------------------
  // Rendering (isometric, hand-drawn)
  // ---------------------------------------------------------------------

  double _targetCamY() => _blocks.isEmpty ? 0 : _top.yTop.toDouble();

  Offset _project(double x, double y, double z) {
    final originX = size.x / 2;
    final originY = size.y * 0.66;
    final sx = (_shake > 0) ? (_rng.nextDouble() - 0.5) * _shake * 60 : 0.0;
    final sy = (_shake > 0) ? (_rng.nextDouble() - 0.5) * _shake * 60 : 0.0;
    return Offset(
      originX + (x - z) * _isoX + sx,
      originY + (x + z) * _isoY - y + _camY + sy,
    );
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_theme.bgTop, _theme.bgBottom],
        ).createShader(rect),
    );

    super.render(canvas);

    for (final b in _blocks) {
      b.draw(canvas, _project);
    }

    final m = _moving;
    if (m != null) {
      if (_popScale != 1) {
        final ox = m.sx, oz = m.sz;
        m.sx = ox * _popScale;
        m.sz = oz * _popScale;
        m.draw(canvas, _project);
        m.sx = ox;
        m.sz = oz;
      } else {
        m.draw(canvas, _project);
      }
    }

    for (final f in _falling) {
      f.block.draw(canvas, _project, alpha: f.alpha, yOffset: f.fallY);
    }

    for (final p in _particles) {
      final o = _project(p.x, p.y, p.z);
      canvas.drawRect(
        Rect.fromCenter(center: o, width: p.size, height: p.size),
        Paint()
          ..color = p.color.withValues(alpha: p.life.clamp(0, 1)),
      );
    }

    if (_flash > 0) {
      canvas.drawRect(
        rect,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: _flash * 0.35),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Colour helpers (driven by the current zone theme)
  // ---------------------------------------------------------------------

  Color _blockColor(int index) {
    final hue = (_theme.blockHue + index * 5) % 360;
    return HSLColor.fromAHSL(1, hue, _theme.blockSat, _theme.blockLight)
        .toColor();
  }
}
