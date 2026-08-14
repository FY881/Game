import '../../core/models/match_models.dart';
import '../../core/rules/classic_ludo_rules.dart';

class TrainingCoach {
  const TrainingCoach._();

  static String instructionFor(MatchState state) {
    if (state.winner != null) {
      return 'أحسنت! أوصلت أحجارك إلى القصر. يمكنك بدء جولة تدريب جديدة أو تجربة الوضع الكلاسيكي.';
    }
    if (state.phase == MatchPhase.selectingPawn) {
      final int legalMoves = ClassicLudoRules.legalPawnIds(state).length;
      return legalMoves == 1
          ? 'الخطوة 2: لديك حركة قانونية واحدة. اختر الحجر المضيء ثم راقب وجهته قبل التأكيد.'
          : 'الخطوة 2: اختر حجرًا قانونيًا. يظهر رقم وجهة كل حجر بجوار اسمه لتتعلم حساب المسافة.';
    }
    if (state.dice == null) {
      return 'الخطوة 1: ارمِ النرد. لدخول حجر من القاعدة في التدريب تحتاج إلى رمية 6.';
    }
    return 'راقب نتيجة الرمية ورسالة القواعد، ثم تابع الدور التالي. يمكنك التراجع عن أي خطوة قمت بها.';
  }
}
