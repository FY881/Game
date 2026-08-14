import type { ReactNode } from "react";
import { Construction } from "lucide-react";
import { useAuth } from "@/_core/hooks/useAuth";
import { trpc } from "@/lib/trpc";

export function MaintenanceGate({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const status = trpc.community.status.useQuery(undefined, { refetchInterval: 30_000 });
  if (status.data?.maintenance && user?.role !== "admin") {
    return <section className="maintenance-panel panel-surface"><Construction size={28} /><span className="eyebrow">NEXUS / MAINTENANCE</span><h1>نضبط الإشارة الآن.</h1><p>المسارات العامة متوقفة مؤقتًا للصيانة. عد بعد قليل؛ تقدمك المحلي والسحابي لا يُحذف.</p></section>;
  }
  return <>{children}</>;
}
