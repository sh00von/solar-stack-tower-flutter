import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import 'score_manager.dart';

/// Thin wrapper around FlameAudio that never throws if a sound file is missing
/// and respects the user's mute setting.
class AudioManager {
  AudioManager(this.storage);

  /// Read for the mute setting.
  final ScoreManager storage;

  static const _click = 'click.wav';
  static const _perfect = 'perfect.wav';
  static const _coin = 'coin.wav';
  static const _powerUp = 'powerup.wav';
  static const _gameOver = 'gameover.wav';

  final _available = <String>{};

  /// Preload sounds. Missing files are skipped so the game keeps working.
  Future<void> preload() async {
    for (final f in [_click, _perfect, _coin, _powerUp, _gameOver]) {
      try {
        await FlameAudio.audioCache.load(f);
        _available.add(f);
      } catch (_) {
        // Asset not present yet — that sound stays silent.
      }
    }
  }

  void playClick() => _safePlay(_click);
  void playCoin() => _safePlay(_coin, volume: 0.6);
  void playPowerUp() => _safePlay(_powerUp);
  void playGameOver() => _safePlay(_gameOver);

  /// Perfect chime whose pitch rises with the [streak] — the signature Stack
  /// feedback. Implemented via the audioplayers playback rate.
  void playPerfect(int streak) {
    if (storage.muted || !_available.contains(_perfect)) return;
    final rate = (1.0 + streak * 0.06).clamp(1.0, 2.0);
    try {
      // Both the play() future AND the inner setPlaybackRate() future must have
      // error handlers; otherwise an async rejection (audio focus loss, codec
      // error, too many players) becomes an uncaught exception that crashes.
      unawaited(
        FlameAudio.play(_perfect, volume: 0.8).then(
          (player) => unawaited(
            player.setPlaybackRate(rate).catchError((Object _) {}),
          ),
          onError: (Object _) {},
        ),
      );
    } catch (_) {/* ignore */}
  }

  void _safePlay(String file, {double volume = 0.8}) {
    if (storage.muted || !_available.contains(file)) return;
    try {
      // Handle both synchronous throws and asynchronous future rejections.
      unawaited(
        FlameAudio.play(file, volume: volume).then(
          (_) {},
          onError: (Object _) {},
        ),
      );
    } catch (_) {/* ignore */}
  }
}
