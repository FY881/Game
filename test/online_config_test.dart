import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/online/online_api.dart';
import 'package:mamalik_alnard/core/online/online_config.dart';

void main() {
  test('يبقى الأونلاين غير مفعل افتراضيًا إلى أن يضبط عنوان خادم صريح', () {
    expect(OnlineConfig.enabled, isFalse);
    expect(OnlineConfig.isAvailable, isFalse);
  });

  test('يرفض عميل الأونلاين أي طلب عند غياب إعداد الخادم الموثوق', () async {
    final OnlineApi api = OnlineApi();

    expect(() => api.createGuest('ضيف_آمن'), throwsA(isA<OnlineApiFailure>()));
  });
}
