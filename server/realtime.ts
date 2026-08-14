import type { Server } from "socket.io";
import { sanitizeMessage, sanitizeRoomLabel } from "./nexusMeta";
import { sdk } from "./_core/sdk";

type RoomState = { code: string; label: string; members: string[] };
const rooms = new Map<string, RoomState>();
const lastMessageAt = new Map<string, number>();

function newCode() {
  return Math.random().toString(36).slice(2, 6).toUpperCase();
}

export function attachRealtime(io: Server) {
  io.use(async (socket, next) => {
    try {
      const user = await sdk.authenticateRequest(socket.request as any);
      socket.data.userId = user.id;
      socket.data.playerName = sanitizeRoomLabel(user.name || `لاعب ${user.id}`);
      next();
    } catch {
      next(new Error("UNAUTHORIZED"));
    }
  });

  io.on("connection", (socket) => {
    const playerName = String(socket.data.playerName);
    io.emit("presence:update", { online: io.sockets.sockets.size });

    socket.on("room:create", ({ label }: { label?: string }, reply?: (value: RoomState) => void) => {
      let code = newCode();
      while (rooms.has(code)) code = newCode();
      const room = { code, label: sanitizeRoomLabel(label || "غرفة الإشارة"), members: [playerName] };
      rooms.set(code, room);
      socket.join(code);
      reply?.(room);
      io.emit("rooms:update", Array.from(rooms.values()));
    });

    socket.on("room:join", ({ code }: { code: string }, reply?: (value: { ok: boolean; room?: RoomState; error?: string }) => void) => {
      const room = rooms.get(String(code || "").toUpperCase());
      if (!room) return reply?.({ ok: false, error: "ROOM_NOT_FOUND" });
      socket.join(room.code);
      if (!room.members.includes(playerName)) room.members.push(playerName);
      reply?.({ ok: true, room });
      io.to(room.code).emit("room:update", room);
      io.emit("rooms:update", Array.from(rooms.values()));
    });

    socket.on("rooms:list", (reply?: (value: RoomState[]) => void) => reply?.(Array.from(rooms.values())));
    socket.on("chat:send", ({ roomCode, message }: { roomCode: string; message: string }) => {
      const now = Date.now();
      if (now - (lastMessageAt.get(socket.id) ?? 0) < 700) return;
      const clean = sanitizeMessage(String(message || ""));
      if (!clean || !rooms.has(roomCode)) return;
      lastMessageAt.set(socket.id, now);
      io.to(roomCode).emit("chat:message", { id: `${socket.id}-${now}`, playerName, message: clean, sentAt: new Date(now).toISOString() });
    });

    socket.on("disconnect", () => {
      lastMessageAt.delete(socket.id);
      Array.from(rooms.values()).forEach((room: RoomState) => {
        room.members = room.members.filter((member: string) => member !== playerName);
        if (room.members.length === 0) rooms.delete(room.code);
      });
      io.emit("rooms:update", Array.from(rooms.values()));
      io.emit("presence:update", { online: io.sockets.sockets.size });
    });
  });
}
