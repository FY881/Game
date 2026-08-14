import { Award, Brain, Crown, Flame, Heart, ShieldCheck, Sparkles, Trophy, Zap } from "lucide-react";
import { Link } from "wouter";
import { NexusShell, SectionKicker, SignalTrace } from "@/components/nexus/NexusShell";
import { earnedAchievements, rankForLevel } from "@/game/progression";
import { loadProgress } from "@/game/storage";

export default function Profile() {
  const progress = loadProgress();
  const achievements = earnedAchievements(progress);
  const rank = rankForLevel(progress.level);
  return <NexusShell><section className="profile-page"><div className="profile-hero panel-surface"><div className="profile-companion" data-stage={progress.companionStage}><Sparkles size={27} /><span>نبضة</span></div><div><SectionKicker icon={Crown}>ملف اللاعب</SectionKicker><h1>{rank}<br /><em>المستوى {String(progress.level).padStart(2, "0")}</em></h1><p>يتطور رفيقك مع كل مرحلة؛ هذه البيانات تقرأ من تقدمك الفعلي، لا من ملف تجريبي.</p></div><SignalTrace label="إشارة الرفيق" value={`الطور ${progress.companionStage + 1} / 5`} /></div><div className="profile-metrics"><div className="panel-surface"><Brain size={18} /><strong>{progress.totalSolved}</strong><span>عقد محلولة</span></div><div className="panel-surface"><Flame size={18} /><strong>{progress.bestStreak}</strong><span>أفضل سلسلة</span></div><div className="panel-surface"><Trophy size={18} /><strong>{progress.bossWins}</strong><span>حراس مهزومون</span></div><div className="panel-surface"><Zap size={18} /><strong>{progress.energy}</strong><span>طاقة متاحة</span></div></div><div className="profile-grid"><section className="panel-surface"><SectionKicker icon={Award}>شارات المسار</SectionKicker><div className="achievement-list">{achievements.map((achievement) => <div key={achievement.id} className={`achievement ${achievement.unlocked ? "is-earned" : ""}`}><ShieldCheck size={16} /><span>{achievement.title}</span><small>{achievement.unlocked ? "مكتسبة" : "قيد الفتح"}</small></div>)}</div></section><section className="panel-surface"><SectionKicker icon={Heart}>سجل الأطلس</SectionKicker><p className="profile-copy">أكملت {progress.completedStages.length} من خمس محطات وجمعت {progress.gold} ذهبًا من مواجهات الحراس.</p><Link href="/adventure" className="text-link">العودة إلى الممالك</Link></section></div></section></NexusShell>;
}
