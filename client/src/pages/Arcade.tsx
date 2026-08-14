import { useEffect, useState } from "react";
import { Gamepad2, Gem, Grid2X2, Play, Timer, Trophy, Zap } from "lucide-react";
import { startLogin } from "@/const";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker } from "@/components/nexus/NexusShell";
import { trpc } from "@/lib/trpc";

const games = [
  { key: "signal-sprint", name: "سباق الإشارة", description: "اضغط عند ظهور الإشارة لتسجيل أثر سريع.", icon: Zap },
  { key: "gem-cascade", name: "سقوط الجواهر", description: "التقط الجوهرة قبل أن تهبط من المسار.", icon: Gem },
  { key: "logic-grid", name: "شبكة المنطق", description: "اختر العقدة المطابقة للقاعدة بأسرع وقت.", icon: Grid2X2 },
] as const;
type GameKey = typeof games[number]["key"];

export default function Arcade() {
  const { isAuthenticated } = useAuth();
  const [gameKey, setGameKey] = useState<GameKey>("signal-sprint");
  const [running, setRunning] = useState(false);
  const [seconds, setSeconds] = useState(15);
  const [score, setScore] = useState(0);
  const [signalOn, setSignalOn] = useState(false);
  const submit = trpc.arcade.submit.useMutation();
  const leaderboard = trpc.arcade.leaderboard.useQuery({ gameKey });
  const current = games.find((game) => game.key === gameKey) ?? games[0];

  useEffect(() => {
    if (!running) return;
    const timer = window.setInterval(() => setSeconds((value) => value - 1), 1000);
    const signal = window.setInterval(() => setSignalOn((value) => !value), 650);
    return () => { window.clearInterval(timer); window.clearInterval(signal); };
  }, [running]);

  useEffect(() => {
    if (seconds > 0 || !running) return;
    setRunning(false);
    setSignalOn(false);
    if (isAuthenticated && score > 0) submit.mutate({ gameKey, score }, { onSuccess: () => void leaderboard.refetch() });
  }, [seconds, running, isAuthenticated, score, submit, gameKey, leaderboard]);

  function start() { setRunning(true); setSeconds(15); setScore(0); setSignalOn(false); }
  function action() {
    if (!running) return;
    const good = gameKey === "logic-grid" ? true : signalOn;
    setScore((value) => Math.max(0, value + (good ? 12 : -3)));
    if (gameKey !== "logic-grid") setSignalOn(false);
  }

  return <NexusShell><section className="arcade-page"><header className="arcade-hero"><SectionKicker icon={Gamepad2}>صالة الآركيد · سجلات حقيقية</SectionKicker><h1>لعب سريع.<br /><em>أثر محسوب.</em></h1><p>هذه الألعاب تسجل أفضل نتائجك للحساب بعد نهاية الجولة؛ لا توجد لوحة متصدرين تجريبية.</p></header><div className="arcade-layout"><section className="arcade-console panel-surface"><div className="arcade-tabs">{games.map((game) => <button type="button" key={game.key} className={game.key === gameKey ? "is-active" : ""} onClick={() => { if (!running) { setGameKey(game.key); setScore(0); setSeconds(15); } }}><game.icon size={15} /> {game.name}</button>)}</div><div className={`arcade-playfield ${signalOn ? "is-signal-on" : ""}`}><current.icon size={42} /><span>{current.description}</span><strong>{score}</strong><small><Timer size={13} /> {String(seconds).padStart(2, "0")} ثانية</small><Button className="signal-button" onClick={running ? action : start}>{running ? (gameKey === "logic-grid" ? "اختر العقدة الصحيحة" : signalOn ? "ثبّت الإشارة" : "انتظر الإشارة") : <><Play size={15} /> ابدأ اللعبة</>}</Button></div>{!isAuthenticated && <button className="arcade-login" type="button" onClick={startLogin}>سجّل دخولك لحفظ النتيجة في لوحة المتصدرين.</button>}{!running && seconds === 0 && <p className="arcade-result">انتهت الجولة بنتيجة {score}. {isAuthenticated ? "تم إرسالها إذا كانت أكبر من صفر." : "يمكنك تسجيل الدخول ثم المحاولة من جديد."}</p>}</section><section className="panel-surface arcade-board"><SectionKicker icon={Trophy}>أفضل نتائج {current.name}</SectionKicker>{leaderboard.data?.length ? <div className="leaderboard-list">{leaderboard.data.map((entry, index) => <div key={`${entry.userId}-${index}`}><span>#{index + 1}</span><b>{entry.name ?? "لاعب Nexus"}</b><strong>{entry.score}</strong></div>)}</div> : <div className="empty-state">لا توجد نتائج مسجلة لهذه اللعبة بعد.</div>}</section></div></section></NexusShell>;
}
