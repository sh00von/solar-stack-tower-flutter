import 'block.dart';

/// A sliced-off overhang piece. It keeps its 3D box shape and falls under
/// gravity while drifting outward and fading, then is culled.
class FallingPiece {
  FallingPiece({
    required this.block,
    required this.driftX,
    required this.driftZ,
  });

  final TowerBlock block;
  final double driftX; // outward sideways velocity (world units/s)
  final double driftZ;

  double vy = 0; // vertical velocity (world units/s), grows with gravity
  double alpha = 1;
  bool get dead => alpha <= 0;

  static const double _gravity = 900;

  /// Advance physics. Returns once fully faded so the game can cull it.
  void update(double dt) {
    vy += _gravity * dt;
    block.cx += driftX * dt;
    block.cz += driftZ * dt;
    // Falling = world height decreasing; mutate the level fractionally via a
    // private vertical offset baked into yBottom through `fallY`.
    fallY -= vy * dt;
    alpha -= dt * 0.9;
    if (alpha < 0) alpha = 0;
  }

  /// Extra vertical offset (negative = below its placed position).
  double fallY = 0;
}
