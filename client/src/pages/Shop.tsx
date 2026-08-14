import { Gem, ShoppingBag, Sparkles, Wallet } from "lucide-react";
import { startLogin } from "@/const";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker } from "@/components/nexus/NexusShell";
import { trpc } from "@/lib/trpc";

const items = [
  { key: "hint-token" as const, label: "رمز تلميح", price: 45, description: "احتفظ بتلميح واحد لجولة صعبة." },
  { key: "focus-token" as const, label: "شحنة تركيز", price: 80, description: "تذكرة تجريبية لتمديد مسار التدريب." },
  { key: "atlas-skin" as const, label: "مظهر الأطلس", price: 180, description: "مظهر محلي لمسار الممالك." },
];

export default function Shop() {
  const { isAuthenticated } = useAuth();
  const wallet = trpc.economy.wallet.useQuery(undefined, { enabled: isAuthenticated });
  const utils = trpc.useUtils();
  const purchase = trpc.economy.purchase.useMutation({ onSuccess: () => void utils.economy.wallet.invalidate() });
  return <NexusShell><section className="shop-page"><header className="shop-hero"><SectionKicker icon={ShoppingBag}>اقتصاد داخلي · لا مدفوعات خارجية</SectionKicker><h1>الذهب يفتح<br /><em>اختيارات أدق.</em></h1><p>الذهب يُكتسب من اللعب والآركيد؛ الماس معروض كعملة بطولات مستقبلية ولا توجد عمليات شراء حقيقية.</p><div className="wallet-display"><Wallet size={18} /><strong>{isAuthenticated ? wallet.data?.gold ?? "—" : "—"}</strong><span>ذهب</span><Gem size={16} /><strong>{isAuthenticated ? wallet.data?.gems ?? "—" : "—"}</strong><span>ماس</span></div></header>{!isAuthenticated ? <div className="panel-surface empty-state"><p>سجّل دخولك لفتح المحفظة والشراء من الرصيد الحقيقي.</p><Button className="signal-button" onClick={startLogin}>تسجيل الدخول</Button></div> : <div className="shop-grid">{items.map((item) => <article key={item.key} className="shop-item panel-surface"><Sparkles size={18} /><h2>{item.label}</h2><p>{item.description}</p><div><strong>{item.price}</strong><span> ذهب</span></div><Button className="signal-button" disabled={purchase.isPending || (wallet.data?.gold ?? 0) < item.price} onClick={() => purchase.mutate({ itemKey: item.key })}>شراء</Button></article>)}</div>}</section></NexusShell>;
}
