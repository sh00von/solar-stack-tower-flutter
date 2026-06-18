import 'dart:ui';

/// A tiny debris particle in world space (x = right, y = up, z = depth),
/// spawned on slices for extra "crunch". Drawn as a small square via the game's
/// isometric projector.
class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.color,
    required this.size,
  });

  double x, y, z;
  double vx, vy, vz;
  double life = 1; // 1 -> 0
  final Color color;
  final double size;

  static const double _gravity = 700;

  bool get dead => life <= 0;

  void update(double dt) {
    vy -= _gravity * dt; // gravity pulls down in world space (y is up)
    x += vx * dt;
    y += vy * dt;
    z += vz * dt;
    life -= dt * 1.6;
  }
}
