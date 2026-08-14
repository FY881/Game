// Style philosophy: مختبر المعرفة المعاصر — the home screen is an asymmetric command center, not a centered card wall.
import { ArrowUpLeft, Brain, ChevronLeft, Flame, LockKeyhole, Map, RotateCcw, ShieldCheck, Target, Trophy, Zap } from "lucide-react";
import { Link } from "wouter";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { NexusMark } from "@/components/nexus/Mark";
import { NexusShell, SectionKicker, SignalTrace } from "@/components/nexus/NexusShell";
import { loadProgress } from "@/game/storage";

const missions = [
  { label: "حل عقدتين", value: "2 / 3", progress: 66, icon: Brain },
  { label: "سلسلة من 5", value: "3 / 5", progress: 60, icon: Flame },
  { label: "استكشف مسارًا", value: "0 / 1", progress: 0, icon: Map },
];

export default function Home() {
  const progress = loadProgress();
  return (
    <NexusShell>
      <div className="home-page">
        <section className="command-hero">
          <div className="command-hero__grid" aria-hidden="true"><span /><span /><span /><span /><span /><span /></div>
          <div className="command-hero__copy">
            <SectionKicker icon={Zap}>جلسة اليوم · إشارة نشطة</SectionKicker>
            <h1>العقدة التالية<br /><em>تنتظرك.</em></h1>
            <p>اختبر ملاحظتك، ثبّت السلسلة، واترك أثرًا أوضح من إجابتك السابقة.</p>
            <div className="hero-actions">
              <Button asChild className="signal-button"><Link href="/play"><Brain size={17} /> ابدأ اختبارًا سريعًا <ArrowUpLeft size={16} /></Link></Button>
              <Link href="/adventure" className="text-link">استكشف المسار <ChevronLeft size={15} /></Link>
            </div>
          </div>
          <div className="command-hero__stamp"><SignalTrace label="المستوى المقترح" value="02" /><i /></div>
        </section>

        <section className="dashboard-grid">
          <div className="progress-panel panel-surface">
            <div className="panel-heading"><SectionKicker icon={Target}>إشارة التقدم</SectionKicker><span className="mono-label">LV.{progress.level}</span></div>
            <div className="progress-panel__main"><strong>{progress.xp.toLocaleString("en-US")}</strong><span>نقطة أثر</span><div className="level-pips"><i className="filled" /><i className="filled" /><i /><i /><i /></div></div>
            <Progress value={62} className="nexus-progress" />
            <div className="progress-panel__foot"><span>المستوى التالي</span><span>360 نقطة متبقية</span></div>
          </div>
          <div className="streak-panel panel-surface"><div className="streak-panel__icon"><Flame size={20} /></div><div><span className="eyebrow">سلسلة حالية</span><strong>{progress.streak} <small>أيام</small></strong><span className="muted-line">أفضل سلسلة: {progress.bestStreak}</span></div><div className="streak-panel__trend">+18%</div></div>
          <div className="accuracy-panel panel-surface"><div className="panel-heading"><SectionKicker icon={ShieldCheck}>دقة التفكير</SectionKicker><span className="mono-label">30 يوم</span></div><strong>{progress.accuracy}%</strong><div className="spark-bars" aria-hidden="true">{[36, 48, 42, 62, 57, 76, 69, 84, 78, 92].map((height, index) => <i key={index} style={{ height: `${height}%` }} className={index === 9 ? "is-current" : ""} />)}</div></div>
        </section>

        <section className="section-block missions-block"><div className="section-heading"><div><span className="eyebrow">01 / نبض اليوم</span><h2>ثلاثة آثار صغيرة.</h2></div><span className="heading-note">تتجدد بعد 08:42:16</span></div><div className="missions-list">{missions.map(({ label, value, progress: missionProgress, icon: Icon }) => <div className="mission-row" key={label}><div className="mission-icon"><Icon size={17} /></div><div className="mission-copy"><strong>{label}</strong><div className="mission-track"><span style={{ width: `${missionProgress}%` }} /></div></div><span className="mission-value">{value}</span></div>)}</div><div className="impact-log"><SignalTrace label="آخر أثر / المهارة" value="الاستنتاج · +12%" /><span className="impact-log__time">منذ 18 دقيقة</span><NexusMark compact /></div></section>

        <section className="section-block modes-block"><div className="section-heading"><div><span className="eyebrow">02 / عوالم اللعب</span><h2>اختر زاوية النظر.</h2></div><Link href="/play" className="text-link">كل الأوضاع <ChevronLeft size={15} /></Link></div><div className="modes-layout"><Link href="/play" className="mode-card mode-card--primary"><div className="mode-card__top"><span className="mode-index">A / 01</span><span className="mode-status">جاهز الآن</span></div><div className="mode-card__copy"><span className="mode-icon"><Brain size={21} /></span><h3>اختبار العقدة</h3><p>خمس أسئلة. وقت متكيف. أثر تعليمي بعد كل إجابة.</p><span className="mode-cta">ابدأ الجولة <ArrowUpLeft size={16} /></span></div><div className="mode-card__signal"><span /><span /><span /><span /><span /></div></Link><Link href="/adventure" className="mode-card mode-card--adventure"><div className="mode-map-mini" aria-hidden="true"><i /><i /><i /><i /></div><span className="mode-index">B / 05</span><div className="mode-card__copy"><span className="mode-icon mode-icon--lime"><Map size={19} /></span><h3>خريطة المغامرة</h3><p>محطات فكرية تفتحها إجاباتك.</p></div><ArrowUpLeft className="mode-card__arrow" size={18} /></Link><Link href="/adventure" className="mode-card mode-card--dungeon"><div className="dungeon-art"><NexusMark compact /></div><span className="mode-index">C / 08</span><div className="mode-card__copy"><span className="mode-icon mode-icon--clay"><LockKeyhole size={18} /></span><h3>زنزانة الحكمة</h3><p>حارس جديد. قرار أدق.</p></div><ArrowUpLeft className="mode-card__arrow" size={18} /></Link></div></section>

        <section className="trail-strip panel-surface"><div className="trail-strip__icon"><RotateCcw size={16} /></div><div><span className="eyebrow">آخر أثر</span><strong>الاستنتاج / عقدة 04</strong></div><span className="trail-strip__time">منذ 18 دقيقة</span><Link href="/play" className="icon-button icon-button--inline" aria-label="متابعة اللعب"><ChevronLeft size={17} /></Link></section>
      </div>
    </NexusShell>
  );
}
