import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_profile.dart';
import 'profile_store.dart';

final AsyncNotifierProvider<PlayerProfileController, PlayerProfile?> playerProfileProvider =
    AsyncNotifierProvider<PlayerProfileController, PlayerProfile?>(PlayerProfileController.new);

class PlayerProfileController extends AsyncNotifier<PlayerProfile?> {
  final ProfileStore _store = ProfileStore();

  @override
  Future<PlayerProfile?> build() => _store.load();

  Future<String?> createGuest({required String displayName, required String avatarId}) async {
    final String? validation = PlayerProfile.validateDisplayName(displayName);
    if (validation != null) return validation;
    final PlayerProfile profile = PlayerProfile(
      id: 'guest-${DateTime.now().microsecondsSinceEpoch}',
      displayName: displayName.trim(),
      avatarId: avatarId,
      createdAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    state = AsyncData<PlayerProfile?>(profile);
    await _store.save(profile);
    return null;
  }

  Future<String?> updateProfile({required String displayName, required String avatarId}) async {
    final PlayerProfile? current = state.valueOrNull;
    if (current == null) return 'أنشئ الملف المحلي أولًا.';
    final String? validation = PlayerProfile.validateDisplayName(displayName);
    if (validation != null) return validation;
    final PlayerProfile updated = current.copyWith(displayName: displayName.trim(), avatarId: avatarId);
    state = AsyncData<PlayerProfile?>(updated);
    await _store.save(updated);
    return null;
  }

  Future<void> applyMatchReward({required int experience, required int gold, required bool isWin}) async {
    final PlayerProfile? current = state.valueOrNull;
    if (current == null) return;
    final int totalExperience = current.experience + experience;
    final PlayerProfile updated = current.copyWith(
      experience: totalExperience,
      level: 1 + (totalExperience ~/ 100),
      gold: current.gold + gold,
      totalMatches: current.totalMatches + 1,
      totalWins: current.totalWins + (isWin ? 1 : 0),
    );
    state = AsyncData<PlayerProfile?>(updated);
    await _store.save(updated);
  }
}
