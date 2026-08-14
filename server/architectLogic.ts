export type ArchitectMetrics = {
  users: number;
  clans: number;
  arcadeScores: number;
  tournamentScores: number;
  recentAuditEvents: number;
};

export type ArchitectRecommendation = {
  id: string;
  severity: "info" | "attention";
  title: string;
  detail: string;
  safeAction: string;
};

export function evaluateArchitect(metrics: ArchitectMetrics) {
  const recommendations: ArchitectRecommendation[] = [];
  let healthScore = 100;
  if (metrics.users === 0) {
    healthScore -= 25;
    recommendations.push({ id: "no-players", severity: "attention", title: "لا توجد حسابات لاعبين", detail: "لم تسجل قاعدة البيانات أي حساب موثق بعد.", safeAction: "راجع رابط الدخول وتجربة الانضمام قبل دعوة اللاعبين." });
  }
  if (metrics.arcadeScores === 0) {
    healthScore -= 15;
    recommendations.push({ id: "no-arcade-scores", severity: "info", title: "الآركيد بلا نتائج", detail: "لا توجد نتائج حقيقية في الصالة حتى الآن.", safeAction: "استخدم جولة تعريفية أو شارك رابط الآركيد مع أول المختبرين." });
  }
  if (metrics.clans === 0) {
    healthScore -= 10;
    recommendations.push({ id: "no-clans", severity: "info", title: "العصابات لم تبدأ بعد", detail: "لا توجد عصابات منشأة حاليًا.", safeAction: "فعّل المجتمع بعد إضافة أول مستخدمين موثوقين." });
  }
  if (metrics.tournamentScores === 0) {
    healthScore -= 10;
    recommendations.push({ id: "no-tournament", severity: "info", title: "البطولة بانتظار أول نتيجة", detail: "لم تستقبل البطولة الأسبوعية أي نتيجة بعد.", safeAction: "أكمل جولة اختبار بحساب لاعب بعد تفعيل الدخول." });
  }
  if (metrics.recentAuditEvents === 0) {
    recommendations.push({ id: "quiet-audit", severity: "info", title: "سجل الإدارة هادئ", detail: "لم تسجل أحداث إدارية حديثة، وهو أمر طبيعي في مرحلة الإعداد.", safeAction: "لا يلزم إجراء؛ سيبقى السجل مرجعًا للتغييرات اللاحقة." });
  }
  if (!recommendations.length) recommendations.push({ id: "healthy", severity: "info", title: "الإشارة مستقرة", detail: "المؤشرات الأساسية تملك نشاطًا فعليًا ولا يظهر إجراء آمن مطلوب الآن.", safeAction: "استمر في مراقبة لوحة Architect." });
  return { healthScore: Math.max(0, healthScore), status: healthScore >= 80 ? "healthy" : "attention", recommendations };
}

export function architectRunKey(taskUid: string, now = new Date()) {
  const quarter = Math.floor(now.getUTCMinutes() / 15) * 15;
  return `${taskUid}-${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}${String(now.getUTCDate()).padStart(2, "0")}${String(now.getUTCHours()).padStart(2, "0")}${String(quarter).padStart(2, "0")}`;
}
