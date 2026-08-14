import 'package:flutter/material.dart';

class CosmeticDefinition {
  const CosmeticDefinition({required this.id, required this.name, required this.description, required this.icon, required this.accent});

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accent;
}

class Cosmetics {
  const Cosmetics._();

  static const List<CosmeticDefinition> pawnStyles = <CosmeticDefinition>[
    CosmeticDefinition(id: 'royal_orb', name: 'كرة ملكية', description: 'الحجر الكلاسيكي الدائري', icon: Icons.circle_outlined, accent: Color(0xffd8b16d)),
    CosmeticDefinition(id: 'desert_seal', name: 'ختم الرمال', description: 'حجر مربع بحواف حادة', icon: Icons.crop_square, accent: Color(0xffd99359)),
    CosmeticDefinition(id: 'moon_drop', name: 'قطرة القمر', description: 'حجر بحدود لؤلؤية', icon: Icons.water_drop_outlined, accent: Color(0xffabc6ea)),
  ];

  static const List<CosmeticDefinition> diceStyles = <CosmeticDefinition>[
    CosmeticDefinition(id: 'brass_dice', name: 'نرد نحاسي', description: 'لمسة القصر الافتراضية', icon: Icons.casino_outlined, accent: Color(0xffc98a47)),
    CosmeticDefinition(id: 'jade_dice', name: 'نرد زمردي', description: 'لمسة واحة هادئة', icon: Icons.casino_outlined, accent: Color(0xff45b98b)),
    CosmeticDefinition(id: 'starlight_dice', name: 'نرد نجمي', description: 'لمسة بنفسجية مضيئة', icon: Icons.casino_outlined, accent: Color(0xffb693db)),
  ];

  static CosmeticDefinition pawnById(String id) => pawnStyles.firstWhere((CosmeticDefinition item) => item.id == id, orElse: () => pawnStyles.first);
  static CosmeticDefinition diceById(String id) => diceStyles.firstWhere((CosmeticDefinition item) => item.id == id, orElse: () => diceStyles.first);
}

class GameLoadout {
  const GameLoadout({
    this.heroId = 'knight',
    this.mapId = 'sand_palace',
    this.pawnStyleId = 'royal_orb',
    this.diceStyleId = 'brass_dice',
  });

  final String heroId;
  final String mapId;
  final String pawnStyleId;
  final String diceStyleId;

  GameLoadout copyWith({String? heroId, String? mapId, String? pawnStyleId, String? diceStyleId}) => GameLoadout(
        heroId: heroId ?? this.heroId,
        mapId: mapId ?? this.mapId,
        pawnStyleId: pawnStyleId ?? this.pawnStyleId,
        diceStyleId: diceStyleId ?? this.diceStyleId,
      );
}
