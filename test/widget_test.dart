import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamalik_alnard/app/app.dart';

void main() {
  testWidgets('تظهر شاشة ممالك النرد كبداية للعبة Android', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MamalikApp()));
    await tester.pumpAndSettle();

    expect(find.text('ممالك النرد'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('ابدأ المباراة'), 240);
    expect(find.text('ابدأ المباراة'), findsOneWidget);
  });
}
