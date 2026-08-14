// Style philosophy: مختبر المعرفة المعاصر — the question owns the hierarchy, and feedback leaves a visible learning trace.
import { useEffect, useMemo, useState } from "react";
import { ArrowRight, Check, ChevronLeft, Clock3, Flame, Lightbulb, RotateCcw, X } from "lucide-react";
import { Link } from "wouter";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker, SignalTrace } from "@/components/nexus/NexusShell";
import { getQuestion, questions } from "@/game/questions";
import { defaultProgress, loadProgress, saveProgress } from "@/game/storage";
import type { NexusProgress } from "@/game/types";

export default function Play() {
  const [started, setStarted] = useState(false);
  const [questionIndex, setQuestionIndex] = useState(0);
  const [seconds, setSeconds] = useState(30);
  const [selected, setSelected] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [streak, setStreak] = useState(0);
  const [completed, setCompleted] = useState(false);
  const [progress, setProgress] = useState<NexusProgress>(() => loadProgress());
  const question = useMemo(() => getQuestion(questionIndex, 3), [questionIndex]);
  const total = 5;

  useEffect(() => {
    if (!started || selected !== null || completed) return;
    const interval = window.setInterval(() => setSeconds((value) => value - 1), 1000);
    return () => window.clearInterval(interval);
  }, [started, selected, completed]);

  useEffect(() => {
    if (started && seconds <= 0 && selected === null) handleAnswer(-1);
    // The timer is intentionally tied to one question and stops as soon as feedback appears.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [seconds, started]);

  function startRound() {
    setStarted(true); setSeconds(30); setQuestionIndex(0); setSelected(null); setScore(0); setStreak(0); setCompleted(false);
  }

  function handleAnswer(option: number) {
    if (selected !== null || completed) return;
    const correct = option === question.answer;
    setSelected(option);
    const nextStreak = correct ? streak + 1 : 0;
    const nextScore = correct ? score + 100 + Math.max(0, seconds * 2) : score;
    setStreak(nextStreak); setScore(nextScore);
    const current = progress ?? defaultProgress;
    const nextProgress: NexusProgress = { ...current, xp: current.xp + (correct ? 32 : 8), totalSolved: current.totalSolved + 1, accuracy: Math.round(((current.accuracy / 100 * current.totalSolved + (correct ? 1 : 0)) / (current.totalSolved + 1)) * 100), bestStreak: Math.max(current.bestStreak, nextStreak), lastPlayedAt: new Date().toISOString() };
    setProgress(nextProgress); saveProgress(nextProgress);
    window.setTimeout(() => {
      if (questionIndex >= total - 1) setCompleted(true);
      else { setQuestionIndex((index) => index + 1); setSelected(null); setSeconds(30); }
    }, 850);
  }

  if (!started) return <NexusShell><section className="play-landing"><div className="play-landing__rail"><span className="eyebrow">A / 01</span><div className="vertical-word">اختبار العقدة</div><div className="rail-calibration"><i /><i /><i /><i /><i /></div></div><div className="play-landing__content"><SectionKicker icon={Lightbulb}>جلسة قصيرة · {questions.length} عقد جاهزة</SectionKicker><h1>لا تطارد الإجابة.<br /><em>اقترب منها.</em></h1><p>جولة من خمس عقد، مؤقت يتكيف مع مستواك، وتفسير صغير يوضح لماذا كانت إجابتك منطقية أو تحتاج مراجعة.</p><SignalTrace label="حالة المسار" value="مستقرة · جاهزة" /><div className="play-landing__stats"><div><strong>05</strong><span>عقد</span></div><div><strong>30<span>ث</span></strong><span>لكل عقدة</span></div><div><strong>x2</strong><span>أثر السلسلة</span></div></div><div className="hero-actions"><Button className="signal-button" onClick={startRound}><span>ابدأ الجولة</span><ArrowRight size={16} /></Button><Link href="/" className="text-link"><ChevronLeft size={15} /> العودة للمركز</Link></div></div><div className="play-landing__note"><span className="note-index">i</span><p>يمكنك إيقاف الجولة في أي وقت. تقدمك يُحفظ محليًا على هذا الجهاز.</p><div className="note-trace"><span /><span /><span /></div></div></section></NexusShell>;

  if (completed) return <NexusShell><section className="result-panel"><div className="result-panel__marker"><Check size={25} /></div><SectionKicker icon={Flame}>الأثر اكتمل</SectionKicker><h1>جولة هادئة،<br /><em>نتيجة واضحة.</em></h1><div className="result-score"><span>النتيجة</span><strong>{score.toLocaleString("en-US")}</strong><small>نقطة أثر</small></div><div className="result-stats"><span>العقد المحلولة <b>05 / 05</b></span><span>أفضل سلسلة <b>{streak}</b></span><span>XP المكتسب <b>+{streak * 32 + 8}</b></span></div><div className="hero-actions"><Button className="signal-button" onClick={startRound}><RotateCcw size={16} /> جولة جديدة</Button><Link href="/" className="text-link"><ChevronLeft size={15} /> مركز Nexus</Link></div></section></NexusShell>;

  const percent = Math.max(0, Math.min(100, (seconds / 30) * 100));
  return <NexusShell><section className="play-screen"><div className="play-screen__top"><div><SectionKicker icon={Clock3}>الاختبار السريع / الجولة 01</SectionKicker><div className="node-count">عقدة <strong>{String(questionIndex + 1).padStart(2, "0")}</strong><span>/ {String(total).padStart(2, "0")}</span></div></div><div className="play-top-signal"><SignalTrace label="آخر أثر" value={`سلسلة ×${Math.max(1, streak)}`} /><Link href="/" className="text-link"><X size={15} /> إنهاء الجولة</Link></div></div><div className="question-layout"><aside className="question-rail"><div className={`timer-readout ${seconds <= 8 ? "is-low" : ""}`}><span>الوقت</span><strong>{String(seconds).padStart(2, "0")}</strong><small>ثانية</small></div><div className="timer-vertical"><span style={{ height: `${percent}%` }} /></div><div className="question-rail__meta"><span>المستوى</span><b>03</b><span>الفئة</span><b>{question.category}</b></div></aside><div className="question-card panel-surface"><div className="question-card__header"><span className="category-tag">{question.category}</span><span className="score-readout"><Flame size={14} /> {score.toLocaleString("en-US")} <small>أثر</small></span></div><h1>{question.prompt}</h1><div className="options-list" role="group" aria-label="خيارات الإجابة">{question.options.map((option, index) => { const isCorrect = index === question.answer; const isSelected = selected === index; const state = selected === null ? "" : isCorrect ? "is-correct" : isSelected ? "is-wrong" : "is-muted"; return <button key={option} type="button" className={`option-row ${state}`} onClick={() => handleAnswer(index)} disabled={selected !== null}><span className="option-key">{String.fromCharCode(65 + index)}</span><span>{option}</span>{selected !== null && isCorrect && <Check size={17} />} {selected !== null && isSelected && !isCorrect && <X size={17} />}</button>; })}</div>{selected !== null && <div className={`learning-trace ${selected === question.answer ? "is-correct" : "is-wrong"}`}><div className="trace-icon">{selected === question.answer ? <Check size={17} /> : <Lightbulb size={17} />}</div><div><strong>{selected === question.answer ? "إشارة صحيحة." : "توقف قصير للمراجعة."}</strong><p>{question.explanation}</p></div></div>}<div className="question-card__footer"><span><Lightbulb size={14} /> تلميح: {question.hint}</span><span className="mono-label">السلسلة ×{Math.max(1, streak)}</span></div></div></div></section></NexusShell>;
}
