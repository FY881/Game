import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamalik_alnard/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('تظهر بوابة أول تشغيل لإنشاء ملف ضيف محلي', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ProviderScope(child: MamalikApp()));
    await tester.pumpAndSettle();

    expect(find.text('مرحبًا بك في ممالك النرد'), findsOneWidget);
    expect(find.text('أنشئ ملفي وابدأ التدريب'), findsOneWidget);
  });

  testWidgets('تظهر الشاشة الرئيسية عند وجود ملف لاعب محلي', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mamalik_local_profile_v1': jsonEncode(<String, dynamic>{
        'id': 'guest-test',
        'displayName': 'فارس النرد',
        'avatarId': 'falcon',
        'createdAt': 1,
        'level': 1,
        'experience': 0,
        'gold': 0,
        'totalMatches': 0,
        'totalWins': 0,
      }),
    });

    await tester.pumpWidget(const ProviderScope(child: MamalikApp()));
    await tester.pumpAndSettle();

    expect(find.text('ممالك النرد'), findsOneWidget);
    expect(find.text('ابدأ مواجهة الآن'), findsOneWidget);
  });
}
