import { useCallback, useEffect, useRef, useState } from "react";
import { Cloud, CloudOff, LogIn, LogOut, RefreshCw } from "lucide-react";
import { startLogin } from "@/const";
import { useAuth } from "@/_core/hooks/useAuth";
import { trpc } from "@/lib/trpc";
import { loadProgress, saveProgress } from "@/game/storage";

type SyncState = "local" | "syncing" | "synced" | "restored" | "offline";

export function CloudSyncStatus() {
  const { isAuthenticated, loading, user, logout } = useAuth();
  const bootstrap = trpc.nexus.bootstrap.useQuery(undefined, { enabled: isAuthenticated, retry: false });
  const { mutateAsync, isPending } = trpc.nexus.sync.useMutation();
  const [syncState, setSyncState] = useState<SyncState>("local");
  const hydrated = useRef(false);

  const syncNow = useCallback(async () => {
    if (!isAuthenticated || isPending) return;
    setSyncState("syncing");
    try {
      const response = await mutateAsync(loadProgress());
      saveProgress(response.progress, { notify: false });
      setSyncState(response.source === "server" ? "restored" : "synced");
    } catch {
      setSyncState("offline");
    }
  }, [isAuthenticated, isPending, mutateAsync]);

  useEffect(() => {
    if (!isAuthenticated) hydrated.current = false;
  }, [isAuthenticated]);

  useEffect(() => {
    if (!isAuthenticated || !bootstrap.isSuccess || hydrated.current) return;
    hydrated.current = true;
    const remote = bootstrap.data?.progress;
    const local = loadProgress();
    if (remote && remote.updatedAt > local.updatedAt) {
      saveProgress(remote, { notify: false });
      setSyncState("restored");
    } else {
      void syncNow();
    }
  }, [bootstrap.data, bootstrap.isSuccess, isAuthenticated, syncNow]);

  useEffect(() => {
    if (!isAuthenticated) return;
    const onProgressSaved = () => void syncNow();
    const interval = window.setInterval(() => void syncNow(), 60_000);
    window.addEventListener("nexus:progress-saved", onProgressSaved);
    return () => {
      window.clearInterval(interval);
      window.removeEventListener("nexus:progress-saved", onProgressSaved);
    };
  }, [isAuthenticated, syncNow]);

  if (loading) return <span className="connection-chip"><RefreshCw size={13} className="is-spinning" /> تجهيز الحساب</span>;
  if (!isAuthenticated) {
    return <button type="button" className="connection-chip connection-chip--button" onClick={startLogin}><CloudOff size={13} /> محليًا فقط <LogIn size={13} /></button>;
  }

  const label = syncState === "syncing" ? "جارٍ الحفظ" : syncState === "offline" ? "الحفظ السحابي متوقف" : syncState === "restored" ? "تمت استعادة التقدم" : "متزامن";
  return <div className="cloud-sync"><button type="button" className="connection-chip connection-chip--button" onClick={() => void syncNow()} disabled={isPending} title="مزامنة التقدم الآن"><Cloud size={13} /><span className="connection-chip__dot" /> {label}</button><button type="button" className="avatar-button" onClick={() => logout()} title={`تسجيل الخروج: ${user?.name ?? "اللاعب"}`} aria-label="تسجيل الخروج"><LogOut size={15} /></button></div>;
}
