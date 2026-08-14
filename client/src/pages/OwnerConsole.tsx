import { Activity, Bot, LockKeyhole, ShieldCheck, Users } from "lucide-react";
import { Link } from "wouter";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker } from "@/components/nexus/NexusShell";
import { trpc } from "@/lib/trpc";

export default function OwnerConsole() {
  const { user } = useAuth();
  const allowed = user?.role === "admin";
  const summary = trpc.admin.summary.useQuery(undefined, { enabled: allowed });
  const audit = trpc.admin.audit.useQuery(undefined, { enabled: allowed });
  const status = trpc.community.status.useQuery();
  const utils = trpc.useUtils();
  const toggle = trpc.admin.setMaintenance.useMutation({ onSuccess: () => { void utils.community.status.invalidate(); void utils.admin.audit.invalidate(); } });
  if (!allowed) return <NexusShell><section className="owner-denied panel-surface"><LockKeyhole size={28} /><h1>القاعـة الذهبية محمية.</h1><p>هذه اللوحة لا تظهر إلا للحسابات التي تحمل دور المالك أو المشرف من الخادم.</p><Link href="/" className="text-link">العودة إلى المركز</Link></section></NexusShell>;
  return <NexusShell><section className="owner-page"><header className="owner-hero"><SectionKicker icon={ShieldCheck}>القاعـة الذهبية</SectionKicker><h1>تحكم واضح.<br /><em>سجل قابل للمراجعة.</em></h1></header><div className="owner-grid"><section className="panel-surface"><SectionKicker icon={Activity}>حالة المنصة</SectionKicker><strong className={status.data?.maintenance ? "status-danger" : "status-safe"}>{status.data?.maintenance ? "وضع الصيانة مفعل" : "المنصة متاحة"}</strong><p>عند التفعيل، تُظهر الواجهة العامة حالة صيانة، بينما يبقى حساب المالك قادرًا على المراجعة.</p><Button variant={status.data?.maintenance ? "outline" : "destructive"} onClick={() => toggle.mutate({ enabled: !status.data?.maintenance })}>{status.data?.maintenance ? "إنهاء الصيانة" : "تفعيل الصيانة"}</Button></section><section className="panel-surface"><SectionKicker icon={Bot}>Nexus Architect</SectionKicker><p className="muted-copy">مراقب دوري محدود يولد توصيات قابلة للمراجعة ولا ينفذ تغييرات تلقائية.</p><Link href="/architect" className="text-link">فتح لوحة Architect</Link></section><section className="panel-surface"><SectionKicker icon={Users}>ملخص حي</SectionKicker><div className="admin-metrics"><span><b>{summary.data?.users ?? 0}</b> لاعبون</span><span><b>{summary.data?.clans ?? 0}</b> عصابات</span><span><b>{summary.data?.arcadeScores ?? 0}</b> نتائج آركيد</span></div></section><section className="panel-surface owner-log"><SectionKicker icon={Activity}>سجل الإدارة</SectionKicker>{audit.data?.length ? audit.data.map((entry) => <div key={entry.id}><b>{entry.eventType}</b><span>{new Date(entry.createdAt).toLocaleString("ar")}</span></div>) : <div className="empty-state">لم تُسجّل أوامر إدارية بعد.</div>}</section></div></section></NexusShell>;
}
