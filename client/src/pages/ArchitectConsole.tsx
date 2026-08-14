import { Activity, Bot, CircleCheck, Clock3, Lightbulb, PauseCircle, PlayCircle, ShieldCheck } from "lucide-react";
import { Link } from "wouter";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker } from "@/components/nexus/NexusShell";
import { trpc } from "@/lib/trpc";

type Recommendation = { id: string; severity: "info" | "attention"; title: string; detail: string; safeAction: string };
type ArchitectPolicy = { version: number; permitted: readonly string[]; prohibited: readonly string[] };
const fallbackPolicy: ArchitectPolicy = {
  version: 1,
  permitted: ["قراءة مؤشرات الاستخدام والنتائج وسجل التدقيق.", "حساب درجة صحة وتسجيل توصيات غير تنفيذية.", "تشغيل فحص صحي يدوي أو دوري موثق.", "إيقاف أو استئناف الفحص الدوري من حساب المالك."],
  prohibited: ["نشر كود أو إنشاء نقطة نشر جديدة.", "تعديل بنية قاعدة البيانات أو حذف البيانات.", "تنفيذ عمليات مالية أو تغيير أرصدة اللاعبين.", "تغيير أدوار المستخدمين أو تجاوز ضوابط المصادقة.", "إرسال محتوى أو رسائل خارجية بالنيابة عن المستخدم."],
};

export default function ArchitectConsole() {
  const { user } = useAuth();
  const allowed = user?.role === "admin";
  const overview = trpc.architect.overview.useQuery(undefined, { enabled: allowed });
  const utils = trpc.useUtils();
  const runNow = trpc.architect.runNow.useMutation({ onSuccess: () => void utils.architect.overview.invalidate() });
  const setEnabled = trpc.architect.setEnabled.useMutation({ onSuccess: () => void utils.architect.overview.invalidate() });
  if (!allowed) return <NexusShell><section className="owner-denied panel-surface"><ShieldCheck size={28} /><h1>Architect محمي.</h1><p>المراقب الدوري يقرأ صحة المنصة وسجلها، لذلك لا يظهر إلا للمالك من الخادم.</p><Link href="/" className="text-link">العودة إلى المركز</Link></section></NexusShell>;
  const latest = overview.data?.runs?.[0];
  const recommendations = (latest?.recommendations ?? []) as Recommendation[];
  const policy = (overview.data?.policy as ArchitectPolicy | undefined) ?? fallbackPolicy;
  return <NexusShell><section className="architect-page"><header className="architect-hero"><SectionKicker icon={Bot}>Nexus Architect · مراقب محدود</SectionKicker><h1>يراقب الإشارة.<br /><em>لا يغيّرها وحده.</em></h1><p>هذا المراقب يعمل كل 15 دقيقة بعد تفعيله، ويكتب توصيات ومؤشرات صحية فقط. لا ينشر كودًا، ولا يحذف بيانات، ولا ينفذ عمليات مالية، ولا يغير الصلاحيات تلقائيًا.</p><div className="architect-actions"><Button className="signal-button" onClick={() => runNow.mutate()} disabled={runNow.isPending}><Activity size={16} /> فحص آمن الآن</Button><Button variant="outline" onClick={() => setEnabled.mutate({ enabled: !(overview.data?.config.enabled ?? 1) })} disabled={setEnabled.isPending}>{overview.data?.config.enabled ? <><PauseCircle size={16} /> إيقاف الفحص الدوري</> : <><PlayCircle size={16} /> تفعيل الفحص الدوري</>}</Button></div></header><div className="architect-grid"><section className="panel-surface architect-score"><SectionKicker icon={CircleCheck}>آخر تقييم</SectionKicker><strong>{latest?.healthScore ?? "—"}</strong><span>/ 100</span><p>{latest ? (latest.status === "healthy" ? "الإشارة مستقرة." : "تحتاج المنصة إلى مراجعة آمنة.") : "لم يجر الفحص بعد."}</p></section><section className="panel-surface architect-config"><SectionKicker icon={Clock3}>الجدولة</SectionKicker><div><span>التكرار</span><b>{overview.data?.config.cadenceMinutes ?? 15} دقيقة</b></div><div><span>الحالة</span><b>{overview.data?.config.enabled ? "مفعّل" : "متوقف"}</b></div><div><span>آخر تشغيل</span><b>{overview.data?.config.lastRunAt ? new Date(overview.data.config.lastRunAt).toLocaleString("ar") : "بانتظار أول تشغيل"}</b></div><small>لا يمكن من هذه اللوحة تغيير نطاق الصلاحيات أو نشر تغييرات تلقائيًا.</small></section><section className="panel-surface architect-recommendations"><SectionKicker icon={Lightbulb}>التوصيات الآمنة</SectionKicker>{recommendations.length ? recommendations.map((item) => <article key={item.id} className={`architect-recommendation is-${item.severity}`}><b>{item.title}</b><p>{item.detail}</p><small>{item.safeAction}</small></article>) : <div className="empty-state">شغّل الفحص الأول للحصول على توصيات حقيقية من بيانات المنصة.</div>}</section><section className="panel-surface architect-policy"><SectionKicker icon={ShieldCheck}>السياسة المخزنة · v{policy.version}</SectionKicker><div><b>مسموح</b>{policy.permitted.map((item) => <span key={item}>• {item}</span>)}</div><div><b>ممنوع</b>{policy.prohibited.map((item) => <span key={item}>• {item}</span>)}</div></section></div></section></NexusShell>;
}
