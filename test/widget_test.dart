import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/app/app.dart';

void main() {
  testWidgets('تظهر شاشة ممالك النرد كبداية للعبة Android', (WidgetTester tester) async {
    await tester.pumpWidget(const MamalikApp());

    expect(find.text('ممالك النرد'), findsOneWidget);
    expect(find.text('ابدأ مباراة أوفلاين'), findsOneWidget);
  });
}
