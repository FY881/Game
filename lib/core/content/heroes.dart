import 'package:flutter/material.dart';

class HeroDefinition {
  const HeroDefinition({
    required this.id,
    required this.name,
    required this.title,
    required this.ability,
    required this.note,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String name;
  final String title;
  final String ability;
  final String note;
  final Color accent;
  final IconData icon;
}

class Heroes {
  const Heroes._();

  static const List<HeroDefinition> all = <HeroDefinition>[
    HeroDefinition(id: 'knight', name: 'الفارس', title: 'حامل الدرع', ability: 'درع من ضربة واحدة', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffb8c7dc), icon: Icons.shield_outlined),
    HeroDefinition(id: 'falcon', name: 'الصقر', title: 'عين الريح', ability: 'اندفاع خطوة إضافية بشروط', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xff79c7dd), icon: Icons.flight_outlined),
    HeroDefinition(id: 'sage', name: 'الحكيم', title: 'حافظ الأثر', ability: 'إعادة اختيار بطاقة غير مناسبة', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffbba1df), icon: Icons.auto_stories_outlined),
    HeroDefinition(id: 'guardian', name: 'الحارسة', title: 'سور الواحة', ability: 'حماية خانة لفترة قصيرة', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffe7a1ab), icon: Icons.gpp_good_outlined),
    HeroDefinition(id: 'traveler', name: 'الرحالة', title: 'عابر البوابات', ability: 'استخدام بوابة مرة واحدة', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffd9bd72), icon: Icons.explore_outlined),
    HeroDefinition(id: 'commander', name: 'القائد', title: 'راية الصف', ability: 'دفعة صغيرة لحجر قريب', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffdc8560), icon: Icons.flag_outlined),
    HeroDefinition(id: 'mirage', name: 'السراب', title: 'صانع الوهم', ability: 'حجر وهمي تجميلي', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xff95a9ff), icon: Icons.visibility_outlined),
    HeroDefinition(id: 'sand_guard', name: 'حارس الرمال', title: 'صخرة الصحراء', ability: 'تقليل أثر فخ واحد', note: 'يعرض فقط الآن؛ القدرات ستتحقق على الخادم قبل استخدامها أونلاين.', accent: Color(0xffd8a968), icon: Icons.terrain_outlined),
  ];

  static HeroDefinition byId(String id) => all.firstWhere((HeroDefinition hero) => hero.id == id, orElse: () => all.first);
}
