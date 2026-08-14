import 'package:flutter/material.dart';

class SafeAvatar {
  const SafeAvatar({required this.id, required this.label, required this.icon, required this.color});

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.displayName,
    required this.avatarId,
    required this.createdAtMilliseconds,
    this.level = 1,
    this.experience = 0,
    this.gold = 0,
    this.totalMatches = 0,
    this.totalWins = 0,
  });

  static const List<SafeAvatar> safeAvatars = <SafeAvatar>[
    SafeAvatar(id: 'falcon', label: 'الصقر', icon: Icons.flutter_dash_outlined, color: Color(0xff75c5ef)),
    SafeAvatar(id: 'knight', label: 'الفارس', icon: Icons.shield_outlined, color: Color(0xffb8c7dc)),
    SafeAvatar(id: 'palm', label: 'النخلة', icon: Icons.park_outlined, color: Color(0xff78b8a1)),
    SafeAvatar(id: 'star', label: 'النجمة', icon: Icons.auto_awesome_outlined, color: Color(0xffc78fdd)),
    SafeAvatar(id: 'fort', label: 'القلعة', icon: Icons.fort_outlined, color: Color(0xffd8a968)),
    SafeAvatar(id: 'sail', label: 'الميناء', icon: Icons.sailing_outlined, color: Color(0xff76c5c5)),
  ];

  final String id;
  final String displayName;
  final String avatarId;
  final int createdAtMilliseconds;
  final int level;
  final int experience;
  final int gold;
  final int totalMatches;
  final int totalWins;

  double get progressToNextLevel => (experience % 100) / 100;

  SafeAvatar get avatar => safeAvatars.firstWhere((SafeAvatar item) => item.id == avatarId, orElse: () => safeAvatars.first);

  PlayerProfile copyWith({
    String? displayName,
    String? avatarId,
    int? level,
    int? experience,
    int? gold,
    int? totalMatches,
    int? totalWins,
  }) =>
      PlayerProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarId: avatarId ?? this.avatarId,
        createdAtMilliseconds: createdAtMilliseconds,
        level: level ?? this.level,
        experience: experience ?? this.experience,
        gold: gold ?? this.gold,
        totalMatches: totalMatches ?? this.totalMatches,
        totalWins: totalWins ?? this.totalWins,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        'avatarId': avatarId,
        'createdAt': createdAtMilliseconds,
        'level': level,
        'experience': experience,
        'gold': gold,
        'totalMatches': totalMatches,
        'totalWins': totalWins,
      };

  factory PlayerProfile.fromMap(Map<String, dynamic> map) => PlayerProfile(
        id: map['id'] as String,
        displayName: map['displayName'] as String,
        avatarId: map['avatarId'] as String,
        createdAtMilliseconds: map['createdAt'] as int,
        level: map['level'] as int? ?? 1,
        experience: map['experience'] as int? ?? 0,
        gold: map['gold'] as int? ?? 0,
        totalMatches: map['totalMatches'] as int? ?? 0,
        totalWins: map['totalWins'] as int? ?? 0,
      );

  static String? validateDisplayName(String raw) {
    final String name = raw.trim();
    if (name.length < 3 || name.length > 14) return 'استخدم اسمًا من 3 إلى 14 حرفًا.';
    if (!RegExp(r'^[\u0621-\u064Aa-zA-Z0-9_ ]+$').hasMatch(name)) return 'استخدم حروفًا أو أرقامًا أو مسافة أو شرطة سفلية فقط.';
    return null;
  }
}
