import 'package:shared_preferences/shared_preferences.dart';

import '../game/missions.dart';

/// Persists all cross-session game state (best score, coins, stats and
/// settings) using shared_preferences. Kept under the name `ScoreManager` since
/// it is referenced widely; it is really the game-wide storage layer.
class ScoreManager {
  static const _bestKey = 'best_score';
  static const _journeyBestKey = 'journey_best';
  static const _coinsKey = 'coins';
  static const _gamesKey = 'total_games';
  static const _bestComboKey = 'best_combo';
  static const _mutedKey = 'muted';
  static const _bestFloorKey = 'best_floor';
  static const _mFloorKey = 'mission_floor';
  static const _mPerfectKey = 'mission_perfect';
  static const _mGamesKey = 'mission_games';
  

  SharedPreferences? _prefs;

  int _best = 0;
  int _journeyBest = 0;
  int _coins = 0;
  int _games = 0;
  int _bestCombo = 0;
  bool _muted = false;
  int _bestFloor = 0;
  int _mFloor = 10; // mission targets (auto-advance on completion)
  int _mPerfect = 5;
  int _mGames = 5;


  int get best => _best;
  int get journeyBest => _journeyBest;
  int get coins => _coins;
  int get totalGames => _games;
  int get bestCombo => _bestCombo;
  bool get muted => _muted;
  bool get soundOn => !_muted;
  int get bestFloor => _bestFloor;


  /// Load all stored values. Safe to call before runApp.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _best = _prefs?.getInt(_bestKey) ?? 0;
    _journeyBest = _prefs?.getInt(_journeyBestKey) ?? 0;
    _coins = _prefs?.getInt(_coinsKey) ?? 0;
    _games = _prefs?.getInt(_gamesKey) ?? 0;
    _bestCombo = _prefs?.getInt(_bestComboKey) ?? 0;
    _muted = _prefs?.getBool(_mutedKey) ?? false;
    _bestFloor = _prefs?.getInt(_bestFloorKey) ?? 0;
    _mFloor = _prefs?.getInt(_mFloorKey) ?? 10;
    _mPerfect = _prefs?.getInt(_mPerfectKey) ?? 5;
    _mGames = _prefs?.getInt(_mGamesKey) ?? 5;

  }

  /// Update the best score if [score] beats it. Returns true on a new record.
  Future<bool> maybeUpdateBest(int score) async {
    if (score > _best) {
      _best = score;
      await _prefs?.setInt(_bestKey, score);
      return true;
    }
    return false;
  }

  Future<bool> maybeUpdateJourneyBest(int score) async {
    if (score > _journeyBest) {
      _journeyBest = score;
      await _prefs?.setInt(_journeyBestKey, score);
      return true;
    }
    return false;
  }

  Future<void> maybeUpdateBestCombo(int combo) async {
    if (combo > _bestCombo) {
      _bestCombo = combo;
      await _prefs?.setInt(_bestComboKey, combo);
    }
  }

  /// Try to spend [amount] coins. Returns false if there aren't enough.
  Future<bool> spendCoins(int amount) async {
    if (_coins < amount) return false;
    _coins -= amount;
    await _prefs?.setInt(_coinsKey, _coins);
    return true;
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _prefs?.setInt(_coinsKey, _coins);
  }


  Future<void> incrementGames() async {
    _games++;
    await _prefs?.setInt(_gamesKey, _games);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    await _prefs?.setBool(_mutedKey, value);
  }

  /// Convenience for a "Sound: On/Off" toggle (on = not muted).
  Future<void> setSoundOn(bool value) => setMuted(!value);

  Future<void> updateBestFloor(int floor) async {
    if (floor > _bestFloor) {
      _bestFloor = floor;
      await _prefs?.setInt(_bestFloorKey, floor);
    }
  }

  /// Current mission snapshots for display (progress uses lifetime bests).
  List<MissionView> currentMissions() => [
        MissionView(
          type: MissionType.floor,
          label: 'Reach floor $_mFloor',
          progress: _bestFloor,
          target: _mFloor,
          reward: MissionConfig.floorReward,
        ),
        MissionView(
          type: MissionType.perfect,
          label: '$_mPerfect perfects in a run',
          progress: _bestCombo,
          target: _mPerfect,
          reward: MissionConfig.perfectReward,
        ),
        MissionView(
          type: MissionType.games,
          label: 'Play $_mGames games',
          progress: _games,
          target: _mGames,
          reward: MissionConfig.gamesReward,
        ),
      ];

  /// Grant rewards for any completed missions and advance their targets.
  /// Call AFTER updating bestFloor / bestCombo / totalGames for this run.
  /// Returns human-readable lines describing what was completed.
  Future<List<String>> claimCompletedMissions() async {
    final msgs = <String>[];
    var reward = 0;

    while (_bestFloor >= _mFloor) {
      msgs.add('Floor $_mFloor reached  +${MissionConfig.floorReward}');
      reward += MissionConfig.floorReward;
      _mFloor += MissionConfig.floorStep;
    }
    while (_bestCombo >= _mPerfect) {
      msgs.add('$_mPerfect-perfect combo  +${MissionConfig.perfectReward}');
      reward += MissionConfig.perfectReward;
      _mPerfect += MissionConfig.perfectStep;
    }
    while (_games >= _mGames) {
      msgs.add('$_mGames games played  +${MissionConfig.gamesReward}');
      reward += MissionConfig.gamesReward;
      _mGames += MissionConfig.gamesStep;
    }

    if (msgs.isNotEmpty) {
      await _prefs?.setInt(_mFloorKey, _mFloor);
      await _prefs?.setInt(_mPerfectKey, _mPerfect);
      await _prefs?.setInt(_mGamesKey, _mGames);
      await addCoins(reward);
    }
    return msgs;
  }
}
