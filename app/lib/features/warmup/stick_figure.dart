import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';

// Strichfiguren-Animationen für den Aufwärm-Impuls (A20).
//
// STATUS: Platzhalter. Werden durch Illustrationen im Solarctic-Zen-CI
// ersetzt (FEATURES.md §K). Koordinaten im Feld 100 × 100, y nach unten.

enum J {
  head,
  neck,
  lShoulder,
  rShoulder,
  lElbow,
  lHand,
  rElbow,
  rHand,
  hip,
  lKnee,
  lFoot,
  rKnee,
  rFoot,
}

typedef Pose = Map<J, Offset>;

const Pose _stand = {
  J.head: Offset(50, 14),
  J.neck: Offset(50, 25),
  J.lShoulder: Offset(43, 27),
  J.rShoulder: Offset(57, 27),
  J.lElbow: Offset(40, 41),
  J.lHand: Offset(39, 55),
  J.rElbow: Offset(60, 41),
  J.rHand: Offset(61, 55),
  J.hip: Offset(50, 56),
  J.lKnee: Offset(46, 75),
  J.lFoot: Offset(45, 94),
  J.rKnee: Offset(54, 75),
  J.rFoot: Offset(55, 94),
};

Pose _p(Map<J, Offset> changes, [Pose base = _stand]) => {...base, ...changes};

/// Seitenansicht: beide Körperhälften liegen übereinander.
Pose _side(Map<J, Offset> m) => {
  ...m,
  J.lShoulder: m[J.neck]!,
  J.rShoulder: m[J.neck]!,
  J.rElbow: m[J.lElbow]!,
  J.rHand: m[J.lHand]!,
};

@immutable
class StickAnimation {
  const StickAnimation(
    this.frames, {
    this.period = const Duration(milliseconds: 1600),
    this.wall = false,
  });

  final List<Pose> frames;
  final Duration period;

  /// Wand links zeichnen (Liegestütze an der Wand).
  final bool wall;
}

final Map<String, StickAnimation> stickAnimations = {
  'squat': StickAnimation([
    _stand,
    _p({
      J.head: const Offset(50, 34),
      J.neck: const Offset(50, 45),
      J.lShoulder: const Offset(43, 47),
      J.rShoulder: const Offset(57, 47),
      J.lElbow: const Offset(42, 55),
      J.lHand: const Offset(49, 52),
      J.rElbow: const Offset(58, 55),
      J.rHand: const Offset(51, 52),
      J.hip: const Offset(50, 72),
      J.lKnee: const Offset(36, 80),
      J.lFoot: const Offset(41, 94),
      J.rKnee: const Offset(64, 80),
      J.rFoot: const Offset(59, 94),
    }),
  ]),
  'jumping_jack': StickAnimation([
    _stand,
    _p({
      J.head: const Offset(50, 11),
      J.neck: const Offset(50, 22),
      J.lShoulder: const Offset(43, 24),
      J.rShoulder: const Offset(57, 24),
      J.lElbow: const Offset(34, 13),
      J.lHand: const Offset(28, 3),
      J.rElbow: const Offset(66, 13),
      J.rHand: const Offset(72, 3),
      J.hip: const Offset(50, 53),
      J.lKnee: const Offset(40, 72),
      J.lFoot: const Offset(32, 91),
      J.rKnee: const Offset(60, 72),
      J.rFoot: const Offset(68, 91),
    }),
  ], period: const Duration(milliseconds: 1000)),
  'pushup': StickAnimation([
    _side({
      J.head: const Offset(18, 54),
      J.neck: const Offset(26, 58),
      J.lElbow: const Offset(26, 70),
      J.lHand: const Offset(26, 84),
      J.hip: const Offset(58, 64),
      J.lKnee: const Offset(74, 70),
      J.lFoot: const Offset(90, 80),
      J.rKnee: const Offset(74, 70),
      J.rFoot: const Offset(90, 80),
    }),
    _side({
      J.head: const Offset(16, 70),
      J.neck: const Offset(24, 73),
      J.lElbow: const Offset(36, 76),
      J.lHand: const Offset(26, 84),
      J.hip: const Offset(57, 74),
      J.lKnee: const Offset(74, 77),
      J.lFoot: const Offset(90, 80),
      J.rKnee: const Offset(74, 77),
      J.rFoot: const Offset(90, 80),
    }),
  ]),
  'wall_pushup': StickAnimation([
    _side({
      J.head: const Offset(36, 20),
      J.neck: const Offset(40, 30),
      J.lElbow: const Offset(30, 33),
      J.lHand: const Offset(16, 34),
      J.hip: const Offset(56, 58),
      J.lKnee: const Offset(62, 76),
      J.lFoot: const Offset(68, 94),
      J.rKnee: const Offset(62, 76),
      J.rFoot: const Offset(68, 94),
    }),
    _side({
      J.head: const Offset(25, 23),
      J.neck: const Offset(30, 32),
      J.lElbow: const Offset(26, 44),
      J.lHand: const Offset(16, 34),
      J.hip: const Offset(51, 59),
      J.lKnee: const Offset(60, 76),
      J.lFoot: const Offset(68, 94),
      J.rKnee: const Offset(60, 76),
      J.rFoot: const Offset(68, 94),
    }),
  ], wall: true),
  'arm_circles': StickAnimation([
    for (var i = 0; i < 4; i++)
      _p({
        J.lElbow: Offset(33, 27 + 3 * math.sin(i * math.pi / 2)),
        J.lHand: Offset(
          20 + 5 * math.cos(i * math.pi / 2),
          27 + 6 * math.sin(i * math.pi / 2),
        ),
        J.rElbow: Offset(67, 27 + 3 * math.sin(i * math.pi / 2)),
        J.rHand: Offset(
          80 - 5 * math.cos(i * math.pi / 2),
          27 + 6 * math.sin(i * math.pi / 2),
        ),
      }),
  ], period: const Duration(milliseconds: 1400)),
  'march': StickAnimation([
    _p({
      J.lKnee: const Offset(45, 62),
      J.lFoot: const Offset(44, 78),
      J.lElbow: const Offset(42, 40),
      J.lHand: const Offset(44, 52),
      J.rElbow: const Offset(61, 36),
      J.rHand: const Offset(58, 28),
    }),
    _p({
      J.rKnee: const Offset(55, 62),
      J.rFoot: const Offset(56, 78),
      J.rElbow: const Offset(58, 40),
      J.rHand: const Offset(56, 52),
      J.lElbow: const Offset(39, 36),
      J.lHand: const Offset(42, 28),
    }),
  ], period: const Duration(milliseconds: 1100)),
  'lunge': StickAnimation([
    _side({
      J.head: const Offset(50, 14),
      J.neck: const Offset(50, 25),
      J.lElbow: const Offset(50, 40),
      J.lHand: const Offset(50, 54),
      J.hip: const Offset(50, 56),
      J.lKnee: const Offset(48, 75),
      J.lFoot: const Offset(47, 94),
      J.rKnee: const Offset(52, 75),
      J.rFoot: const Offset(53, 94),
    }),
    _side({
      J.head: const Offset(50, 28),
      J.neck: const Offset(50, 39),
      J.lElbow: const Offset(50, 53),
      J.lHand: const Offset(50, 66),
      J.hip: const Offset(50, 68),
      J.lKnee: const Offset(33, 76),
      J.lFoot: const Offset(30, 94),
      J.rKnee: const Offset(64, 88),
      J.rFoot: const Offset(80, 94),
    }),
  ]),
  'shoulder_rolls': StickAnimation([
    for (var i = 0; i < 4; i++)
      _p({
        J.lShoulder: Offset(
          43 - (i == 1 ? 1.5 : 0),
          27 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
        J.rShoulder: Offset(
          57 + (i == 1 ? 1.5 : 0),
          27 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
        J.lElbow: Offset(
          40,
          41 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
        J.rElbow: Offset(
          60,
          41 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
        J.lHand: Offset(
          39,
          55 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
        J.rHand: Offset(
          61,
          55 -
              (i == 0
                  ? 4
                  : i == 1
                  ? 2
                  : 0),
        ),
      }),
  ], period: const Duration(milliseconds: 2400)),
};

/// Interpoliert zwischen den Haltungen einer Schleife (weich, ohne Sprung).
Pose poseAt(StickAnimation a, double t) {
  final n = a.frames.length;
  if (n == 1) return a.frames.first;
  final x = (t % 1) * n;
  final i = x.floor() % n;
  final f = Curves.easeInOut.transform(x - x.floor());
  final from = a.frames[i];
  final to = a.frames[(i + 1) % n];
  return {for (final j in J.values) j: Offset.lerp(from[j], to[j], f)!};
}

/// Animierte Strichfigur. Respektiert «Bewegung reduzieren» (zeigt dann die
/// erste Haltung ohne Bewegung).
class StickFigure extends StatefulWidget {
  const StickFigure({required this.animationKey, this.size = 180, super.key});

  final String animationKey;
  final double size;

  @override
  State<StickFigure> createState() => _StickFigureState();
}

class _StickFigureState extends State<StickFigure>
    with SingleTickerProviderStateMixin {
  StickAnimation? get _anim => stickAnimations[widget.animationKey];

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _anim?.period ?? const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce || _anim == null) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void didUpdateWidget(StickFigure old) {
    super.didUpdateWidget(old);
    if (old.animationKey != widget.animationKey && _anim != null) {
      _c.duration = _anim!.period;
      if (_c.isAnimating) _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final anim = _anim;
    if (anim == null) {
      return SizedBox.square(
        dimension: widget.size,
        child: Icon(
          Icons.directions_run_rounded,
          size: widget.size * 0.6,
          color: p.accentPrimary,
        ),
      );
    }
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _StickPainter(
              pose: poseAt(anim, _c.value),
              wall: anim.wall,
              color: p.accentPrimary,
              ground: p.borderSubtle,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickPainter extends CustomPainter {
  _StickPainter({
    required this.pose,
    required this.wall,
    required this.color,
    required this.ground,
  });

  final Pose pose;
  final bool wall;
  final Color color;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    Offset pt(J j) => pose[j]! * s;
    final line = Paint()
      ..color = color
      ..strokeWidth = 4.5 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final faint = Paint()
      ..color = ground
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(6 * s, 96 * s), Offset(94 * s, 96 * s), faint);
    if (wall) {
      canvas.drawLine(Offset(14 * s, 4 * s), Offset(14 * s, 96 * s), faint);
    }

    void seg(J a, J b) => canvas.drawLine(pt(a), pt(b), line);
    seg(J.head, J.neck);
    seg(J.neck, J.hip);
    seg(J.lShoulder, J.rShoulder);
    seg(J.lShoulder, J.lElbow);
    seg(J.lElbow, J.lHand);
    seg(J.rShoulder, J.rElbow);
    seg(J.rElbow, J.rHand);
    seg(J.hip, J.lKnee);
    seg(J.lKnee, J.lFoot);
    seg(J.hip, J.rKnee);
    seg(J.rKnee, J.rFoot);
    canvas.drawCircle(pt(J.head), 6.5 * s, line..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_StickPainter old) =>
      old.pose != pose || old.color != color;
}
