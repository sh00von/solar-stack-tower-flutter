import 'dart:ui';

/// Projects a point in world space (x = right axis, y = up/height,
/// z = depth axis) to a 2D screen position. Supplied by the game so the model
/// stays free of camera/shake details.
typedef Projector = Offset Function(double x, double y, double z);

/// Which horizontal axis a block slides along. The axis alternates every level,
/// giving the classic Stack "weave" between left-right and front-back motion.
enum SlideAxis { x, z }

/// Optional special ability carried by a sliding block.
/// - [slowMo]  : slows the slide for a few seconds after it's placed.
/// - [wide]    : oversized footprint; a perfect drop regrows the tower's width.
/// - [magnet]  : the next drop auto-snaps to a perfect, wherever you tap.
enum BlockPower { none, slowMo, wide, magnet }

/// A single tower block as a real 3D box, drawn in isometric projection with
/// three shaded faces (top, right, front). This is plain model data — the game
/// owns the list of these and renders them; it is not a Flame component.
class TowerBlock {
  TowerBlock({
    required this.level,
    required this.axis,
    required this.cx,
    required this.cz,
    required this.sx,
    required this.sz,
    required this.color,
    this.power = BlockPower.none,
  });

  final int level; // vertical index, 0 = base
  SlideAxis axis; // axis this block (or its successor) slides on
  double cx; // centre on x
  double cz; // centre on z
  double sx; // footprint size along x
  double sz; // footprint size along z
  Color color;
  BlockPower power;

  // Edge helpers used by the slice math.
  double get xLeft => cx - sx / 2;
  double get xRight => cx + sx / 2;
  double get zNear => cz - sz / 2;
  double get zFar => cz + sz / 2;

  /// World vertical thickness of every block.
  static const double height = 42;

  double get yBottom => level * height;
  double get yTop => yBottom + height;

  /// Draw the box. [alpha] lets falling pieces fade out; [yOffset] lets a
  /// falling piece drop below its placed height.
  void draw(Canvas canvas, Projector project,
      {double alpha = 1, double yOffset = 0}) {
    final hx = sx / 2, hz = sz / 2;
    final yt = yTop + yOffset, yb = yBottom + yOffset;

    // Top-face corners (clockwise from the back corner).
    final ta = project(cx - hx, yt, cz - hz); // back
    final tb = project(cx + hx, yt, cz - hz); // right
    final tc = project(cx + hx, yt, cz + hz); // front (lowest on screen)
    final td = project(cx - hx, yt, cz + hz); // left

    // Matching bottom corners for the two visible vertical faces.
    final bb = project(cx + hx, yb, cz - hz);
    final bc = project(cx + hx, yb, cz + hz);
    final bd = project(cx - hx, yb, cz + hz);

    final top = _shade(color, 1.0, alpha);
    final right = _shade(color, 0.78, alpha); // +x face
    final front = _shade(color, 0.62, alpha); // +z face

    // Painter's order within a box: sides first, top last.
    _poly(canvas, [tb, tc, bc, bb], right);
    _poly(canvas, [tc, td, bd, bc], front);
    _poly(canvas, [ta, tb, tc, td], top);

    // Special blocks get a bright inset diamond on the top face so they read
    // clearly while sliding.
    if (power != BlockPower.none) {
      final c = project(cx, yt, cz);
      final ia = project(cx - hx * 0.4, yt, cz - hz * 0.4);
      final ib = project(cx + hx * 0.4, yt, cz - hz * 0.4);
      final ic = project(cx + hx * 0.4, yt, cz + hz * 0.4);
      final id = project(cx - hx * 0.4, yt, cz + hz * 0.4);
      _poly(canvas, [ia, ib, ic, id], _powerColor(alpha));
      // A small dot in the centre for extra pop.
      canvas.drawCircle(c, 3.5, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  Color _powerColor(double alpha) {
    final a = (255 * alpha).round();
    switch (power) {
      case BlockPower.slowMo:
        return Color.fromARGB(a, 90, 200, 255); // cyan
      case BlockPower.wide:
        return Color.fromARGB(a, 120, 255, 140); // green
      case BlockPower.magnet:
        return Color.fromARGB(a, 255, 210, 80); // gold
      case BlockPower.none:
        return Color.fromARGB(0, 0, 0, 0);
    }
  }

  void _poly(Canvas canvas, List<Offset> pts, Color c) {
    final path = Path()..addPolygon(pts, true);
    canvas.drawPath(path, Paint()..color = c..isAntiAlias = true);
  }

  static Color _shade(Color c, double f, double alpha) => Color.fromARGB(
        ((c.a * 255) * alpha).round(),
        ((c.r * 255) * f).round().clamp(0, 255),
        ((c.g * 255) * f).round().clamp(0, 255),
        ((c.b * 255) * f).round().clamp(0, 255),
      );
}
