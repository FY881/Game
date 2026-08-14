import 'package:flutter/material.dart';

class BoardMapTheme {
  const BoardMapTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.paper,
    required this.track,
    required this.border,
    required this.center,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final Color background;
  final Color paper;
  final Color track;
  final Color border;
  final Color center;
  final IconData icon;
}

class BoardMaps {
  const BoardMaps._();

  static const List<BoardMapTheme> all = <BoardMapTheme>[
    BoardMapTheme(id: 'sand_palace', name: 'قصر الرمال', description: 'ألواح رملية ونحاس دافئ', background: Color(0xff20150e), paper: Color(0xfff3e5c7), track: Color(0xff17345a), border: Color(0xffc98a47), center: Color(0xff2fb4a5), icon: Icons.account_balance_outlined),
    BoardMapTheme(id: 'sky_city', name: 'مدينة السماء', description: 'رخام سماوي وأبراج بعيدة', background: Color(0xff0a1b32), paper: Color(0xffdceeff), track: Color(0xff264c78), border: Color(0xff8ab6dc), center: Color(0xff75c5ef), icon: Icons.cloud_outlined),
    BoardMapTheme(id: 'moon_oasis', name: 'واحة القمر', description: 'ضوء ليلي ونخيل هادئ', background: Color(0xff101d28), paper: Color(0xffe5e0c8), track: Color(0xff355e5a), border: Color(0xffc9ba7d), center: Color(0xff78b8a1), icon: Icons.nightlight_outlined),
    BoardMapTheme(id: 'mountain_fort', name: 'قلعة الجبال', description: 'حجر داكن وحواف فضية', background: Color(0xff181c24), paper: Color(0xffdedbd4), track: Color(0xff424b59), border: Color(0xffa3acb7), center: Color(0xff748aa3), icon: Icons.fort_outlined),
    BoardMapTheme(id: 'royal_harbor', name: 'الميناء الملكي', description: 'موجات عميقة وحبال ذهبية', background: Color(0xff071d2d), paper: Color(0xffd3e4e3), track: Color(0xff19546a), border: Color(0xffd4a656), center: Color(0xff2fa2a1), icon: Icons.sailing_outlined),
    BoardMapTheme(id: 'star_temple', name: 'معبد النجوم', description: 'بنفسج داكن ونجوم نحاسية', background: Color(0xff17112b), paper: Color(0xffe5dcf0), track: Color(0xff4c3e6f), border: Color(0xffc39de0), center: Color(0xffc78fdd), icon: Icons.auto_awesome_outlined),
  ];

  static BoardMapTheme byId(String id) => all.firstWhere((BoardMapTheme map) => map.id == id, orElse: () => all.first);
}
