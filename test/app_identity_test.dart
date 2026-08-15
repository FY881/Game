import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const String appName = 'ممالك النرد: صراع الأبطال';

  test('يعرض Android الاسم الملكي بدل الاسم التقني قبل التثبيت وداخل الواجهة',
      () async {
    final String manifest =
        await File('android/app/src/main/AndroidManifest.xml').readAsString();
    final String resources =
        await File('android/app/src/main/res/values/strings.xml').readAsString();
    final String flutterApp = await File('lib/app/app.dart').readAsString();

    expect(manifest, contains('android:label="@string/app_name"'));
    expect(resources, contains('<string name="app_name">$appName</string>'));
    expect(flutterApp, contains("title: '$appName'"));
    expect(manifest, isNot(contains('android:label="mamalik_alnard"')));
  });
}
