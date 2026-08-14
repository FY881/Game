import 'dart:ui';

import 'package:flame/game.dart';

import '../models/match_models.dart';
import '../rules/classic_ludo_rules.dart';

class LudoBoardGame extends FlameGame {
  LudoBoardGame(this.state);

  final MatchState state;

  @override
  Color backgroundColor() => const Color(0xff0b1830);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double side = size.x < size.y ? size.x : size.y;
    final Offset origin = Offset((size.x - side) / 2, (size.y - side) / 2);
    final double cell = side / 15;
    final Paint paper = Paint()..color = const Color(0xfff3e5c7);
    final Paint ink = Paint()..color = const Color(0xff17345a);
    final Paint brass = Paint()..color = const Color(0xffc98a47);

    canvas.drawRRect(RRect.fromRectAndRadius(origin & Size.square(side), const Radius.circular(28)), paper);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx + cell * .35, origin.dy + cell * .35, side - cell * .7, side - cell * .7),
        const Radius.circular(22),
      ),
      Paint()
        ..color = const Color(0xffe3d0a8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * .15,
    );

    for (int index = 0; index < ClassicLudoRules.trackLength; index++) {
      final Offset point = _trackPosition(index, origin, cell);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: point, width: cell * .74, height: cell * .74),
          Radius.circular(cell * .16),
        ),
        ink,
      );
    }

    for (final Player player in state.players) {
      final Paint playerPaint = Paint()..color = player.color.color;
      final Offset base = _baseCenter(player.color, origin, cell);
      canvas.drawCircle(base, cell * 1.75, playerPaint..color = player.color.color.withOpacity(.26));
      for (int index = 0; index < player.pawns.length; index++) {
        final Pawn pawn = player.pawns[index];
        final Offset position = _pawnPosition(pawn, index, origin, cell);
        canvas.drawCircle(position, cell * .29, Paint()..color = player.color.color);
        canvas.drawCircle(position, cell * .29, brass..style = PaintingStyle.stroke..strokeWidth = 1.6);
      }
    }
    canvas.drawCircle(origin + Offset(side / 2, side / 2), cell * 1.05, Paint()..color = const Color(0xff2fb4a5));
    canvas.drawCircle(origin + Offset(side / 2, side / 2), cell * .68, brass);
  }

  Offset _trackPosition(int index, Offset origin, double cell) {
    final List<Offset> points = <Offset>[];
    for (int x = 0; x <= 13; x++) {
      points.add(Offset(x.toDouble(), 0));
    }
    for (int y = 1; y <= 13; y++) {
      points.add(Offset(13, y.toDouble()));
    }
    for (int x = 12; x >= 0; x--) {
      points.add(Offset(x.toDouble(), 13));
    }
    for (int y = 12; y >= 1; y--) {
      points.add(Offset(0, y.toDouble()));
    }
    final Offset logical = points[index % points.length];
    return origin + Offset(logical.dx * cell, logical.dy * cell);
  }

  Offset _baseCenter(PlayerColor color, Offset origin, double cell) => switch (color) {
        PlayerColor.coral => origin + Offset(cell * 3, cell * 3),
        PlayerColor.sapphire => origin + Offset(cell * 12, cell * 3),
        PlayerColor.jade => origin + Offset(cell * 12, cell * 12),
        PlayerColor.gold => origin + Offset(cell * 3, cell * 12),
      };

  Offset _pawnPosition(Pawn pawn, int index, Offset origin, double cell) {
    if (pawn.progress == -1) {
      final Offset base = _baseCenter(pawn.color, origin, cell);
      return base + Offset((index.isEven ? -.45 : .45) * cell, (index < 2 ? -.45 : .45) * cell);
    }
    if (pawn.progress >= ClassicLudoRules.trackLength) {
      final double step = (pawn.progress - ClassicLudoRules.trackLength + 1) * .55;
      return origin + Offset(cell * (7.5 + (pawn.color.index.isEven ? 0 : step)), cell * (7.5 + (pawn.color.index.isEven ? step : 0)));
    }
    return _trackPosition(ClassicLudoRules.trackIndex(pawn.color, pawn.progress), origin, cell);
  }
}
