// Style philosophy: مختبر المعرفة المعاصر — adventure is a readable path with connected stations, not a decorative card grid.
import { ArrowUpLeft, Check, ChevronLeft, Compass, LockKeyhole, MapPin, Sparkles } from "lucide-react";
import { Link, useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker, SignalTrace } from "@/components/nexus/NexusShell";
import { loadProgress } from "@/game/storage";

const stages = [
  { number: "01", name: "بوابة الملاحظة", type: "الأنماط", status: "complete", detail: "تعلّم رؤية الإشارة قبل أن تتحرك." },
  { number: "02", name: "ممر الاستنتاج", type: "المنطق", status: "active", detail: "أربع عقد تفصل الحقيقة عن الانطباع." },
  { number: "03", name: "حدود اللغة", type: "المفردات", status: "locked", detail: "يفتح بعد إكمال ممر الاستنتاج." },
  { number: "04", name: "مرصد الاحتمال", type: "الحساب", status: "locked", detail: "تحتاج إلى 160 نقطة أثر إضافية." },
  { number: "05", name: "الغرفة الصامتة", type: "التركيز", status: "locked", detail: "آخر محطات المسار الأول." },
];

export default function Adventure() {
  const [, setLocation] = useLocation();
  const progress = loadProgress();
  return <NexusShell><section className="adventure-page"><div className="adventure-intro"><SectionKicker icon={Compass}>B / 05 · مسار المغامرة</SectionKicker><h1>كل محطة تغيّر<br /><em>طريقة النظر.</em></h1><p>خريطة قصيرة من خمس محطات. لا تُقاس بالسرعة فقط؛ بل بقدرتك على الاحتفاظ بالإشارة عندما يتغير السؤال.</p><SignalTrace label="حالة الأطلس" value="02 / 05 · مستقرة" /><div className="adventure-intro__meta"><span><MapPin size={15} /> المحطة الحالية <b>02 / 05</b></span><span><Sparkles size={15} /> التقدم <b>{Math.min(progress.unlockedStages, 2)} محطات</b></span></div></div><div className="adventure-map panel-surface"><div className="atlas-grid" aria-hidden="true" /><div className="map-label"><span className="eyebrow">NEXUS / ATLAS</span><strong>المسار الأول</strong><span>إشارة مستقرة · 02.04</span></div><div className="map-route" aria-label="خريطة محطات المغامرة">{stages.map((stage, index) => <button key={stage.number} type="button" className={`map-node map-node--${stage.status}`} onClick={() => stage.status !== "locked" && setLocation("/play")}><span className="map-node__number">{stage.status === "complete" ? <Check size={15} /> : stage.status === "locked" ? <LockKeyhole size={14} /> : stage.number}</span><span className="map-node__name">{stage.name}</span><small>{stage.type}</small>{index < stages.length - 1 && <i className="map-node__connector" />}</button>)}</div><div className="map-coordinate">N 02° 04′<br />E 16° 09′</div></div><div className="adventure-stages"><div className="section-heading"><div><span className="eyebrow">المحطات</span><h2>اختَر أثرًا.</h2></div><span className="heading-note">{stages.filter((stage) => stage.status === "complete").length} مكتملة</span></div>{stages.map((stage) => <div className={`stage-row stage-row--${stage.status}`} key={stage.number}><span className="stage-row__number">{stage.number}</span><div className="stage-row__copy"><strong>{stage.name}</strong><span>{stage.detail}</span></div><span className="stage-row__type">{stage.type}</span>{stage.status === "active" ? <Button size="sm" className="signal-button signal-button--small" onClick={() => setLocation("/play")}>دخول <ArrowUpLeft size={14} /></Button> : stage.status === "complete" ? <span className="stage-done"><Check size={14} /> منجزة</span> : <LockKeyhole size={15} className="stage-lock" />}</div>)}</div><Link href="/" className="text-link adventure-back"><ChevronLeft size={15} /> العودة إلى المركز</Link></section></NexusShell>;
}
