import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/profile/player_profile.dart';
import 'package:mamalik_alnard/core/profile/profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('يتحقق ملف اللاعب من الاسم الآمن قبل الحفظ', () {
    expect(PlayerProfile.validateDisplayName('فا'), isNotNull);
    expect(PlayerProfile.validateDisplayName('فارس_النرد'), isNull);
    expect(PlayerProfile.validateDisplayName('اسم!'), isNotNull);
  });

  test('يحفظ ملف الضيف المحلي ويستعيد تقدمه دون اتصال', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProfileStore store = ProfileStore();
    const PlayerProfile expected = PlayerProfile(
      id: 'guest-1',
      displayName: 'فارس النرد',
      avatarId: 'knight',
      createdAtMilliseconds: 10,
      level: 3,
      experience: 42,
      gold: 120,
      totalMatches: 7,
      totalWins: 4,
    );

    await store.save(expected);
    final PlayerProfile? restored = await store.load();

    expect(restored, isNotNull);
    expect(restored!.displayName, 'فارس النرد');
    expect(restored.avatar.id, 'knight');
    expect(restored.level, 3);
    expect(restored.gold, 120);
    expect(restored.totalWins, 4);
  });
}
