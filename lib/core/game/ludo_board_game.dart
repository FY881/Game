import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';

import '../content/maps.dart';
import '../models/match_models.dart';
import '../rules/classic_ludo_rules.dart';
import '../settings/game_settings.dart';

class LudoBoardGame extends FlameGame with TapCallbacks {
  LudoBoardGame(
    this.state, {
    required this.colorVisionMode,
    required this.batterySaver,
    required this.onPawnSelected,
  });

  MatchState state;
  ColorVisionMode colorVisionMode;
  bool batterySaver;
  final void Function(String pawnId) onPawnSelected;
  final Map<String, _PawnMotion> _motions = <String, _PawnMotion>{};
  double _batteryAccumulator = 0;
  double _pulseClock = 0;

  void syncState(
    MatchState next, {
    required ColorVisionMode nextColorVisionMode,
    required bool nextBatterySaver,
  }) {
    if (next != state) {
      final Map<String, Pawn> previousPawns = <String, Pawn>{
        for (final Player player in state.players)
          for (final Pawn pawn in player.pawns) pawn.id: pawn,
      };
      for (final Player player in next.players) {
        for (final Pawn pawn in player.pawns) {
          final Pawn? previous = previousPawns[pawn.id];
          if (previous != null && previous.progress != pawn.progress) {
            _motions[pawn.id] = _PawnMotion(from: previous, to: pawn);
          }
        }
      }
      state = next;
    }
    colorVisionMode = nextColorVisionMode;
    batterySaver = nextBatterySaver;
  }

  @override
  Color backgroundColor() => BoardMaps.byId(state.config.mapId).background;

  @override
  void update(double dt) {
    _pulseClock += dt;
    _motions.removeWhere((_, _PawnMotion motion) => motion.advance(dt));
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
    final double side = math.min(size.x, size.y);
    final Offset origin = Offset((size.x - side) / 2, (size.y - side) / 2);
    final double cell = side / 15;
    final BoardMapTheme map = BoardMaps.byId(state.config.mapId);
    final Paint paper = Paint()..color = map.paper;
    final Paint ink = Paint()..color = map.track;
    final Paint brass = Paint()..color = map.border;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          origin & Size.square(side), const Radius.circular(28)),
      paper,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx + cell * .35,
          origin.dy + cell * .35,
          side - cell * .7,
          side - cell * .7,
        ),
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

    final List<String> legalPawnIds = state.activePlayer.isHuman
        ? ClassicLudoRules.legalPawnIds(state)
        : const <String>[];
    for (final Player player in state.players) {
      final Color playerColor = _playerColor(player.color);
      final Offset base = _baseCenter(player.color, origin, cell);
      canvas.drawCircle(
        base,
        cell * 1.75,
        Paint()..color = playerColor.withValues(alpha: .24),
      );
      for (int index = 0; index < player.pawns.length; index++) {
        final Pawn pawn = player.pawns[index];
        final Offset position =
            _animatedPawnPosition(pawn, index, origin, cell);
        if (legalPawnIds.contains(pawn.id)) {
          final double halo = cell * (.43 + math.sin(_pulseClock * 5) * .05);
          canvas.drawCircle(
            position,
            halo,
            Paint()..color = const Color(0xffffe7a4).withValues(alpha: .42),
          );
          canvas.drawCircle(
            position,
            halo,
            Paint()
              ..color = const Color(0xffffd46d)
              ..style = PaintingStyle.stroke
              ..strokeWidth = cell * .06,
          );
        }
        _drawPawn(canvas, position, cell, playerColor, brass,
            state.config.pawnStyleId);
      }
    }
    final Offset center = origin + Offset(side / 2, side / 2);
    canvas.drawCircle(center, cell * 1.05, Paint()..color = map.center);
    canvas.drawCircle(center, cell * .68, brass);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!state.activePlayer.isHuman ||
        state.phase != MatchPhase.selectingPawn ||
        size.x <= 0 ||
        size.y <= 0) {
      return;
    }
    final List<String> legalPawnIds = ClassicLudoRules.legalPawnIds(state);
    if (legalPawnIds.isEmpty) {
      return;
    }
    final double side = math.min(size.x, size.y);
    final Offset origin = Offset((size.x - side) / 2, (size.y - side) / 2);
    final double cell = side / 15;
    final Offset tap = Offset(event.localPosition.x, event.localPosition.y);
    String? closestId;
    double closestDistance = double.infinity;
    for (int index = 0; index < state.activePlayer.pawns.length; index++) {
      final Pawn pawn = state.activePlayer.pawns[index];
      if (!legalPawnIds.contains(pawn.id)) continue;
      final Offset pawnPosition =
          _animatedPawnPosition(pawn, index, origin, cell);
      final double distance = (tap - pawnPosition).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestId = pawn.id;
      }
    }
    if (closestId != null && closestDistance <= cell * .72) {
      onPawnSelected(closestId);
    }
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

  void _drawPawn(
    Canvas canvas,
    Offset position,
    double cell,
    Color playerColor,
    Paint brass,
    String styleId,
  ) {
    final Paint fill = Paint()..color = playerColor;
    final Paint outline = Paint()
      ..color = brass.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    if (styleId == 'desert_seal') {
      final RRect shape = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: position, width: cell * .56, height: cell * .56),
        Radius.circular(cell * .10),
      );
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, outline);
      return;
    }
    canvas.drawCircle(position, cell * .29, fill);
    if (styleId == 'moon_drop') {
      canvas.drawCircle(
        position,
        cell * .18,
        Paint()..color = const Color(0xfff8f1da).withValues(alpha: .55),
      );
    }
    canvas.drawCircle(position, cell * .29, outline);
  }

  Offset _baseCenter(PlayerColor color, Offset origin, double cell) =>
      switch (color) {
        PlayerColor.coral => origin + Offset(cell * 3, cell * 3),
        PlayerColor.sapphire => origin + Offset(cell * 12, cell * 3),
        PlayerColor.jade => origin + Offset(cell * 12, cell * 12),
        PlayerColor.gold => origin + Offset(cell * 3, cell * 12),
      };

  Offset _pawnPosition(Pawn pawn, int index, Offset origin, double cell) {
    if (pawn.progress == -1) {
      final Offset base = _baseCenter(pawn.color, origin, cell);
      return base +
          Offset(
            (index.isEven ? -.45 : .45) * cell,
            (index < 2 ? -.45 : .45) * cell,
          );
    }
    if (pawn.progress >= ClassicLudoRules.trackLength) {
      final double step =
          (pawn.progress - ClassicLudoRules.trackLength + 1) * .55;
      return origin +
          Offset(
            cell * (7.5 + (pawn.color.index.isEven ? 0 : step)),
            cell * (7.5 + (pawn.color.index.isEven ? step : 0)),
          );
    }
    return _trackPosition(
        ClassicLudoRules.trackIndex(pawn.color, pawn.progress), origin, cell);
  }

  Offset _animatedPawnPosition(
      Pawn pawn, int index, Offset origin, double cell) {
    final _PawnMotion? motion = _motions[pawn.id];
    if (motion == null) return _pawnPosition(pawn, index, origin, cell);
    final double curve = Curves.easeOutCubic.transform(motion.progress);
    return Offset.lerp(
      _pawnPosition(motion.from, index, origin, cell),
      _pawnPosition(motion.to, index, origin, cell),
      curve,
    )!;
  }
}

class _PawnMotion {
  _PawnMotion({required this.from, required this.to});

  final Pawn from;
  final Pawn to;
  double elapsed = 0;

  double get progress => (elapsed / .34).clamp(0, 1);

  bool advance(double dt) {
    elapsed += dt;
    return elapsed >= .34;
  }
}
