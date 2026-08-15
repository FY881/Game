# إعداد Google OAuth لتطبيق «ممالك النرد» على Android

**الغرض من هذا الدليل** هو إنشاء معرّف عميل Google الصحيح لتطبيق Android، ثم تمرير هذا المعرّف إلى خادم ممالك النرد كي يتحقق من رمز هوية المستخدم. لا يلزم إنشاء أو إرسال كلمة مرور أو ملف مفاتيح للخادم في هذه المرحلة.

> المطلوب في النهاية هو سطر واحد فقط يبدأ غالبًا بـ `...apps.googleusercontent.com` وهو **Client ID**. لا ترسل `Client Secret` ولا تنشر ملف JSON ولا ترسل كلمة مرور حساب Google.

## أولًا: افتح أو أنشئ مشروع Google Cloud

1. افتح [Google Cloud Console](https://console.cloud.google.com/) وسجّل الدخول بالحساب الذي تريد أن يمتلك إعدادات اللعبة.
2. من الشريط العلوي، اضغط اسم المشروع الحالي ثم اضغط **New Project**. إذا كان لديك مشروع خاص باللعبة بالفعل، اختره بدلًا من ذلك.
3. اكتب اسمًا واضحًا، مثل `Mamalik Al-Nard`، ثم اضغط **Create**.
4. انتظر قليلًا، ثم اضغط أيقونة الإشعارات أو قائمة المشاريع واختر المشروع الجديد. تأكد من أن اسمه يظهر في أعلى الصفحة قبل إكمال الخطوات.

## ثانيًا: إعداد شاشة الموافقة

1. من القائمة الجانبية، افتح **Google Auth Platform** ثم **Branding**. قد تظهر هذه الصفحة في بعض الحسابات القديمة باسم **APIs & Services → OAuth consent screen**.
2. في قسم الجمهور، اختر **External** إذا كانت اللعبة ستُتاح لاحقًا لأي لاعب يحمل حساب Google. اختر **Internal** فقط إن كان التطبيق مخصصًا لأعضاء مؤسسة Google Workspace واحدة.
3. في بيانات التطبيق، أدخل اسم التطبيق: `ممالك النرد: صراع الأبطال`، ثم أدخل بريد الدعم وبريد التواصل الخاص بالمطوّر.
4. احفظ التغييرات. أثناء مرحلة الاختبار أضف بريدك وبريد أي مختبرين من **Audience → Test users**؛ الحسابات غير المضافة قد لا تتمكن من تسجيل الدخول قبل نشر شاشة الموافقة.
5. لا تطلب صلاحيات إضافية مثل Drive أو Contacts. تسجيل الدخول يحتاج عادةً معلومات الهوية الأساسية فقط، مثل `openid` و`email` و`profile`.[1]

| القرار | الخيار المناسب الآن | السبب |
|---|---|---|
| نوع الجمهور | External | اللعبة موجهة للاعبين عمومًا، لا لموظفي مؤسسة واحدة. |
| حالة النشر | Testing أثناء التطوير | تسمح بالتجربة مع حسابات محددة قبل الإطلاق. |
| الصلاحيات | الهوية الأساسية فقط | تقلل شاشة الموافقة ولا تمنح اللعبة وصولًا إلى بيانات لا تحتاجها. |

## ثالثًا: اعرف اسم حزمة Android قبل إنشاء العميل

يجب أن يطابق **اسم الحزمة** ما هو في مشروع Flutter حرفيًا. افتح الملف التالي في مشروع اللعبة:

```text
android/app/build.gradle.kts
```

ابحث عن أحد السطرين التاليين:

```kotlin
applicationId = "..."
```

أو:

```kotlin
namespace = "..."
```

انسخ قيمة `applicationId` نفسها، من دون علامات الاقتباس. لا تخمّن الاسم ولا تستخدم اسم المشروع في GitHub؛ Google يطابق اسم الحزمة مع شهادة التوقيع.

## رابعًا: استخرج بصمة SHA-1 لشهادة Debug

افتح Terminal داخل جهاز التطوير واكتب الأمر التالي كما هو:

```bash
keytool -list -v \
  -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android \
  -keypass android
```

إذا طلب منك النظام تأكيد المسار، وافق. ابحث في المخرجات عن سطر مشابه لهذا:

```text
SHA1: AA:BB:CC:DD:...:FF
```

انسخ **القيمة بعد `SHA1:` كاملة بما فيها النقطتان**. شهادة debug الافتراضية تستخدم كلمة المرور `android`، وهذا ينطبق فقط على شهادة الاختبار الافتراضية.[2]

> إذا لم تجد `debug.keystore`، شغّل التطبيق مرة واحدة عبر Android Studio أو نفّذ `flutter run`، ثم أعد الأمر. بديلًا عن ذلك يمكنك تشغيل `./gradlew signingReport` داخل مجلد `android` وعرض سطر `SHA1` الخاص بمتغير `debug`.[2]

## خامسًا: أنشئ عميل OAuth من نوع Android

1. عد إلى Google Cloud Console ثم افتح **Google Auth Platform → Clients**. في الواجهة القديمة افتح **APIs & Services → Credentials**.
2. اضغط **Create client** أو **Create credentials → OAuth client ID**.
3. عند **Application type** اختر **Android**. لا تختَر **Web application** أو **Desktop app** لتطبيق Flutter على Android.[3]
4. عند **Name** اكتب: `Mamalik Al-Nard Android Debug`.
5. عند **Package name** ألصق قيمة `applicationId` التي نسختها في الخطوة الثالثة.
6. عند **SHA-1 certificate fingerprint** ألصق بصمة debug التي نسختها في الخطوة الرابعة.
7. اضغط **Create**. ستظهر نافذة تحتوي **Client ID**. انسخ هذا المعرّف وحده واحفظه مؤقتًا.

## سادسًا: ما الذي ترسله إليّ؟

أرسل في المحادثة هذه الصيغة فقط، بعد استبدال المثال بالقيمة الحقيقية:

```text
GOOGLE_ANDROID_CLIENT_ID=123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
```

يُستخدم عميل Android لتوثيق تطابق اسم الحزمة وبصمة التوقيع عند Google. أمّا الخادم فيتحقق من **ID token** باستخدام معرّف عميل Web مستقل بصفته الجمهور (`audience`)؛ لذلك لا يوضع عميل Android في كود الخادم ولا في رمز التطبيق. يستقبل الخادم رمز الهوية عبر HTTPS ويتحقق منه على الخادم؛ ولا يعتمد على ادعاء التطبيق بأن المستخدم سجّل دخوله.[4]

## بناء APK اختبار الأونلاين بصورة قابلة للتكرار

يبقى الأونلاين معطلاً في البناء الافتراضي. لإنشاء **APK Debug** لاختبار الربط فقط، عرّف عنوان الخادم المنشور ومعرّف عميل Web عند البناء من دون إضافتهما إلى الملفات أو المستودع:

```bash
export GOOGLE_WEB_CLIENT_ID='ضع_معرّف_عميل_Web_هنا'
flutter build apk --debug \
  --dart-define=MAMALIK_ONLINE_ENABLED=true \
  --dart-define=MAMALIK_SERVER_URL=https://mamaliknar-kje7gbv8.manus.space \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID"
```

يتأكد هذا البناء من أن التطبيق يطلب رمز الهوية لجمهور Web الذي يتحقق منه الخادم، بينما يبقى عميل Android مسجلاً في Google Cloud عبر اسم الحزمة وSHA-1. لا تضع **Client Secret** أو مفاتيح توقيع أو قيمة حقيقية لمعّرف العميل داخل Git أو في لقطات الشاشة.

### سجل التحقق — بيئة Debug

في **14 أغسطس 2026**، تمت مراجعة صفحة عميل Android في Google Cloud. وتطابقت قيمة اسم الحزمة المعروضة مع `com.example.mamalik_alnard`، كما تطابقت بصمة SHA‑1 المعروضة مع شهادة Debug التي استُخرجت من بيئة بناء التطبيق. يثبت ذلك صحة تسجيل عميل Android لبناء Debug فقط. يبقى اختبار تسجيل الدخول على هاتف أو محاكي يحمل Google Play services مطلوبًا قبل فتح الأونلاين العام، كما يلزم إنشاء عميل أو بصمة منفصلة لتوقيع Google Play عند الإصدار.[2]

## سابعًا: قبل النشر على Google Play

عند رفع AAB إلى Google Play مع **Play App Signing**، ستكون شهادة توقيع المستخدمين مختلفة عن شهادة upload أو debug. افتح **Play Console → Release → Setup → App integrity** ثم انسخ SHA-1 الموجود تحت **App signing key certificate**. أنشئ عميل Android إضافيًا بالقيمة نفسها لاسم الحزمة وببصمة Play SHA-1، أو أضف البصمة وفق واجهة Google Cloud المتاحة.[2]

احتفظ بعميل debug للاختبارات وعميل Play للإصدار. لا تحذف عميل debug قبل أن تنتهي من الاختبار المحلي.

## حل المشاكل الشائعة

| العرض | التحقق المطلوب |
|---|---|
| تظهر رسالة `DEVELOPER_ERROR` أو تسجيل الدخول يفشل فورًا | تأكد من تطابق اسم الحزمة وSHA-1؛ حرف واحد مختلف يجعل العميل غير مطابق. |
| حسابك لا يظهر ضمن حسابات Google | أضف بريد الحساب إلى **Test users** طالما شاشة الموافقة في وضع Testing. |
| يعمل Debug ولا يعمل التطبيق من Google Play | أضف SHA-1 لشهادة **App signing key certificate** من Play Console، وليس SHA-1 الخاص بمفتاح الرفع فقط. |
| يطلب Google صلاحيات كثيرة | راجع Scopes، واحتفظ بالهوية الأساسية؛ لا تطلب صلاحيات Google API ما لم توجد ميزة حقيقية تحتاجها. |

## المراجع

[1]: https://developers.google.com/identity/protocols/oauth2 "Google OAuth 2.0: Using OAuth 2.0 to Access Google APIs"
[2]: https://developers.google.com/android/guides/client-auth "Google Play services: Client authentication and SHA-1 certificates"
[3]: https://support.google.com/googleapi/answer/6158849?hl=en "Google API Console Help: Setting up OAuth 2.0"
[4]: https://developer.android.com/identity/legacy/one-tap/idtoken-auth "Android Developers: Authenticate with a backend using ID tokens"
