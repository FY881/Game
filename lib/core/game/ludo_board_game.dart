import 'dart:ui';

import 'package:flame/game.dart';

import '../content/maps.dart';
import '../models/match_models.dart';
import '../rules/classic_ludo_rules.dart';
import '../settings/game_settings.dart';

class LudoBoardGame extends FlameGame {
  LudoBoardGame(this.state, {required this.colorVisionMode, required this.batterySaver});

  final MatchState state;
  final ColorVisionMode colorVisionMode;
  final bool batterySaver;
  double _batteryAccumulator = 0;

  @override
  Color backgroundColor() => BoardMaps.byId(state.config.mapId).background;

  @override
  void update(double dt) {
    if (batterySaver) {
      _batteryAccumulator += dt;
      if (_batteryAccumulator < 1 / 30) return;
      _batteryAccumulator = 0;
      super.update(1 / 30);
      return;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double side = size.x < size.y ? size.x : size.y;
    final Offset origin = Offset((size.x - side) / 2, (size.y - side) / 2);
    final double cell = side / 15;
    final BoardMapTheme map = BoardMaps.byId(state.config.mapId);
    final Paint paper = Paint()..color = map.paper;
    final Paint ink = Paint()..color = map.track;
    final Paint brass = Paint()..color = map.border;

    canvas.drawRRect(RRect.fromRectAndRadius(origin & Size.square(side), const Radius.circular(28)), paper);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origin.dx + cell * .35, origin.dy + cell * .35, side - cell * .7, side - cell * .7),
        const Radius.circular(22),
      ),
      Paint()
        ..color = map.border.withValues(alpha: .72)
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
      final Color playerColor = _playerColor(player.color);
      final Paint playerPaint = Paint()..color = playerColor;
      final Offset base = _baseCenter(player.color, origin, cell);
      canvas.drawCircle(base, cell * 1.75, playerPaint..color = playerColor.withValues(alpha: .26));
      for (int index = 0; index < player.pawns.length; index++) {
        final Pawn pawn = player.pawns[index];
        final Offset position = _pawnPosition(pawn, index, origin, cell);
        _drawPawn(canvas, position, cell, playerColor, brass, state.config.pawnStyleId);
      }
    }
    canvas.drawCircle(origin + Offset(side / 2, side / 2), cell * 1.05, Paint()..color = map.center);
    canvas.drawCircle(origin + Offset(side / 2, side / 2), cell * .68, brass);
  }

  Color _playerColor(PlayerColor player) => switch (colorVisionMode) {
        ColorVisionMode.standard => player.color,
        ColorVisionMode.deuteranopia => switch (player) {
            PlayerColor.coral => const Color(0xff0072b2),
            PlayerColor.sapphire => const Color(0xff56b4e9),
            PlayerColor.jade => const Color(0xfff0e442),
            PlayerColor.gold => const Color(0xffd55e00),
          },
        ColorVisionMode.highContrast => switch (player) {
            PlayerColor.coral => const Color(0xffff4b4b),
            PlayerColor.sapphire => const Color(0xff44b5ff),
            PlayerColor.jade => const Color(0xff3eea88),
            PlayerColor.gold => const Color(0xffffde3d),
          },
      };

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

  void _drawPawn(Canvas canvas, Offset position, double cell, Color playerColor, Paint brass, String styleId) {
    final Paint fill = Paint()..color = playerColor;
    final Paint outline = Paint()
      ..color = brass.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    if (styleId == 'desert_seal') {
      final RRect shape = RRect.fromRectAndRadius(Rect.fromCenter(center: position, width: cell * .56, height: cell * .56), Radius.circular(cell * .10));
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, outline);
      return;
    }
    canvas.drawCircle(position, cell * .29, fill);
    if (styleId == 'moon_drop') {
      canvas.drawCircle(position, cell * .18, Paint()..color = const Color(0xfff8f1da).withValues(alpha: .55));
    }
    canvas.drawCircle(position, cell * .29, outline);
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
