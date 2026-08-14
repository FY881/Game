export const ARCADE_GAMES = ["signal-sprint", "gem-cascade", "logic-grid"] as const;
export type ArcadeGameKey = (typeof ARCADE_GAMES)[number];

export const SHOP_ITEMS = {
  "hint-token": { label: "رمز تلميح", price: 45 },
  "focus-token": { label: "شحنة تركيز", price: 80 },
  "atlas-skin": { label: "مظهر الأطلس", price: 180 },
} as const;

export function currentWeekKey(date = new Date()) {
  const start = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const days = Math.floor((date.getTime() - start.getTime()) / 86_400_000);
  return `${date.getUTCFullYear()}-W${String(Math.floor(days / 7) + 1).padStart(2, "0")}`;
}

export function sanitizeMessage(value: string) {
  return value.replace(/[<>]/g, "").replace(/\s+/g, " ").trim().slice(0, 280);
}

export function sanitizeRoomLabel(value: string) {
  return value.replace(/[^a-zA-Z0-9\u0600-\u06FF\s_-]/g, "").replace(/\s+/g, " ").trim().slice(0, 32) || "غرفة الإشارة";
}
