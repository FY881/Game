import { useEffect, useRef, useState } from "react";
import { io, type Socket } from "socket.io-client";
import { Crown, MessageCircle, Plus, Radio, Send, ShieldCheck, Users } from "lucide-react";
import { startLogin } from "@/const";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { NexusShell, SectionKicker } from "@/components/nexus/NexusShell";
import { trpc } from "@/lib/trpc";

type Room = { code: string; label: string; members: string[] };
type ChatMessage = { id: string; playerName: string; message: string; sentAt: string };

export default function Community() {
  const { isAuthenticated, user } = useAuth();
  const tournament = trpc.community.tournament.useQuery();
  const clans = trpc.community.clans.useQuery();
  const myClan = trpc.community.myClan.useQuery(undefined, { enabled: isAuthenticated });
  const utils = trpc.useUtils();
  const createClan = trpc.community.createClan.useMutation({ onSuccess: () => { void utils.community.clans.invalidate(); void utils.community.myClan.invalidate(); } });
  const joinClan = trpc.community.joinClan.useMutation({ onSuccess: () => { void utils.community.clans.invalidate(); void utils.community.myClan.invalidate(); } });
  const [online, setOnline] = useState(0);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [activeRoom, setActiveRoom] = useState<Room | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [roomLabel, setRoomLabel] = useState("");
  const [message, setMessage] = useState("");
  const [clanName, setClanName] = useState("");
  const socketRef = useRef<Socket | null>(null);

  useEffect(() => {
    if (!isAuthenticated) return;
    const socket = io({ path: "/api/socket.io", transports: ["websocket", "polling"], withCredentials: true });
    socketRef.current = socket;
    socket.on("presence:update", ({ online: value }: { online: number }) => setOnline(value));
    socket.on("rooms:update", (next: Room[]) => setRooms(next));
    socket.on("room:update", (next: Room) => setActiveRoom((current) => current?.code === next.code ? next : current));
    socket.on("chat:message", (next: ChatMessage) => setMessages((current) => [...current.slice(-59), next]));
    socket.emit("rooms:list", (next: Room[]) => setRooms(next));
    return () => { socket.disconnect(); };
  }, [isAuthenticated]);

  function createRoom() {
    socketRef.current?.emit("room:create", { label: roomLabel }, (room: Room) => { setActiveRoom(room); setMessages([]); setRoomLabel(""); });
  }

  function joinRoom(code: string) {
    socketRef.current?.emit("room:join", { code }, (response: { ok: boolean; room?: Room }) => {
      if (response.ok && response.room) { setActiveRoom(response.room); setMessages([]); }
    });
  }

  function sendMessage() {
    if (!activeRoom || !message.trim()) return;
    socketRef.current?.emit("chat:send", { roomCode: activeRoom.code, message });
    setMessage("");
  }

  return <NexusShell><section className="community-page"><header className="community-hero"><SectionKicker icon={Radio}>المجتمع الحي · Socket.IO</SectionKicker><h1>العقل لا يلعب<br /><em>وحيدًا.</em></h1><p>أنشئ غرفة موثقة بالحساب، التحق بأعضاء آخرين، وتابع البطولة الأسبوعية دون بيانات تصنيف مصطنعة.</p><div className="community-presence"><span className="connection-chip__dot" /> {isAuthenticated ? `${online} متصلون الآن` : "سجّل دخولك لفتح الغرف الحية"}</div></header><div className="community-grid"><section className="panel-surface community-card community-card--rooms"><SectionKicker icon={MessageCircle}>الغرف المباشرة</SectionKicker>{!isAuthenticated ? <div className="empty-state"><p>تحتاج الغرف والدردشة إلى حساب موثق.</p><Button className="signal-button" onClick={startLogin}>تسجيل الدخول</Button></div> : <><div className="inline-form"><input value={roomLabel} onChange={(event) => setRoomLabel(event.target.value)} maxLength={32} placeholder="اسم الغرفة" /><Button size="sm" className="signal-button signal-button--small" onClick={createRoom}><Plus size={14} /> إنشاء</Button></div><div className="room-list">{rooms.length ? rooms.map((room) => <button type="button" key={room.code} className={`room-row ${activeRoom?.code === room.code ? "is-active" : ""}`} onClick={() => joinRoom(room.code)}><span><b>{room.label}</b><small>{room.code}</small></span><span>{room.members.length} لاعبين</span></button>) : <div className="empty-state">لا توجد غرف مفتوحة الآن. أنشئ أول غرفة.</div>}</div>{activeRoom && <div className="chat-box"><div className="chat-box__head"><b>{activeRoom.label}</b><small>{activeRoom.code}</small></div><div className="chat-scroll">{messages.length ? messages.map((entry) => <div className="chat-entry" key={entry.id}><b>{entry.playerName}</b><span>{entry.message}</span></div>) : <p>الغرفة جاهزة. ابدأ الحديث.</p>}</div><div className="inline-form"><input value={message} onChange={(event) => setMessage(event.target.value)} onKeyDown={(event) => event.key === "Enter" && sendMessage()} maxLength={280} placeholder="رسالة قصيرة ومحترمة" /><Button size="icon" className="signal-button" onClick={sendMessage} aria-label="إرسال"><Send size={15} /></Button></div></div>}</>}</section><section className="panel-surface community-card"><SectionKicker icon={Crown}>بطولة {tournament.data?.weekKey ?? "هذا الأسبوع"}</SectionKicker><div className="leaderboard-list">{tournament.data?.entries?.length ? tournament.data.entries.map((entry, index) => <div key={`${entry.userId}-${index}`}><span>#{index + 1}</span><b>{entry.name ?? "لاعب Nexus"}</b><strong>{entry.score}</strong></div>) : <div className="empty-state">لم تُسجّل نتائج البطولة بعد. أول نتيجة ستظهر هنا.</div>}</div></section><section className="panel-surface community-card"><SectionKicker icon={Users}>العصابات</SectionKicker>{myClan.data ? <div className="clan-current"><ShieldCheck size={18} /><div><b>{myClan.data.name}</b><span>{myClan.data.role === "leader" ? "قائد العصابة" : "عضو"}</span></div></div> : isAuthenticated ? <div className="inline-form"><input value={clanName} onChange={(event) => setClanName(event.target.value)} maxLength={32} placeholder="اسم عصابة جديد" /><Button size="sm" variant="outline" onClick={() => createClan.mutate({ name: clanName })}>تأسيس</Button></div> : <p className="muted-copy">سجّل الدخول للانضمام إلى عصابة أو تأسيسها.</p>}<div className="clan-list">{clans.data?.length ? clans.data.map((clan) => <div key={clan.id} className="clan-row"><div><b>{clan.name}</b><small>{clan.members} أعضاء</small></div>{isAuthenticated && !myClan.data && <Button size="sm" variant="outline" onClick={() => joinClan.mutate({ clanId: clan.id })}>انضم</Button>}</div>) : <div className="empty-state">لا توجد عصابات بعد.</div>}</div></section></div></section></NexusShell>;
}
