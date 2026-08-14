// Style philosophy: مختبر المعرفة المعاصر — asymmetric navigation keeps the question central and the wayfinding calm.
import { Activity, Compass, Gamepad2, Home, Moon, Settings2, Sparkles, UserRound } from "lucide-react";
import { Link, useLocation } from "wouter";
import { NexusMark } from "./Mark";

const navItems = [
  { href: "/", label: "المركز", icon: Home },
  { href: "/play", label: "اختبار العقدة", icon: Activity },
  { href: "/adventure", label: "المغامرة", icon: Compass },
];

export function NexusShell({ children }: { children: React.ReactNode }) {
  const [location] = useLocation();
  return (
    <div className="nexus-app">
      <aside className="nexus-rail">
        <Link href="/" className="nexus-brand" aria-label="العودة إلى مركز Nexus">
          <NexusMark />
          <span className="nexus-brand__name">NEXUS</span>
        </Link>
        <div className="nexus-rail__label">المسار</div>
        <nav className="nexus-nav" aria-label="التنقل الرئيسي">
          {navItems.map(({ href, label, icon: Icon }) => (
            <Link key={href} href={href} className={`nexus-nav__item ${location === href ? "is-active" : ""}`}>
              <Icon size={17} strokeWidth={1.8} />
              <span>{label}</span>
            </Link>
          ))}
        </nav>
        <div className="nexus-rail__spacer" />
        <div className="nexus-rail__signal"><span /> الجلسة محلية</div>
        <button className="nexus-nav__item nexus-nav__item--muted" type="button" onClick={() => document.documentElement.classList.toggle("dim-mode")}>
          <Moon size={17} strokeWidth={1.8} />
          <span>مظهر هادئ</span>
        </button>
      </aside>
      <main className="nexus-main">
        <header className="nexus-topbar">
          <div>
            <span className="eyebrow">NEXUS / 02</span>
            <span className="topbar-context">مختبر المعرفة المعاصر</span>
          </div>
          <div className="nexus-topbar__actions">
            <span className="connection-chip"><span className="connection-chip__dot" /> محفوظ محليًا</span>
            <button className="icon-button" type="button" aria-label="الإعدادات"><Settings2 size={17} /></button>
            <button className="avatar-button" type="button" aria-label="ملف اللاعب"><UserRound size={17} /></button>
          </div>
        </header>
        {children}
        <footer className="nexus-footer"><span>© NEXUS</span><span>كل إجابة تترك أثرًا.</span><span><Gamepad2 size={13} /> وضع آمن للتجربة</span></footer>
      </main>
    </div>
  );
}

export function SectionKicker({ icon: Icon = Sparkles, children }: { icon?: typeof Sparkles; children: React.ReactNode }) {
  return <div className="section-kicker"><Icon size={14} /> <span>{children}</span></div>;
}

export function SignalTrace({ label, value }: { label: string; value: string }) {
  return <div className="signal-trace"><span className="signal-trace__mark" /><i /><div><span>{label}</span><strong>{value}</strong></div></div>;
}
