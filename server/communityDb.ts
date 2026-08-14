import { count, desc, eq } from "drizzle-orm";
import { nexusArcadeScores, nexusAuditLogs, nexusClanMembers, nexusClans, nexusSettings, nexusTournamentScores, nexusWallets, users } from "../drizzle/schema";
import { getDb } from "./db";
import { type ArcadeGameKey, currentWeekKey } from "./nexusMeta";

export async function getWallet(userId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  await db.insert(nexusWallets).values({ userId, gold: 250, gems: 0 }).onDuplicateKeyUpdate({ set: { userId } });
  const rows = await db.select().from(nexusWallets).where(eq(nexusWallets.userId, userId)).limit(1);
  return rows[0];
}

export async function spendGold(userId: number, price: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const wallet = await getWallet(userId);
  if (!wallet || wallet.gold < price) throw new Error("INSUFFICIENT_GOLD");
  await db.update(nexusWallets).set({ gold: wallet.gold - price }).where(eq(nexusWallets.userId, userId));
  return { gold: wallet.gold - price, gems: wallet.gems };
}

export async function addGold(userId: number, amount: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const wallet = await getWallet(userId);
  if (!wallet) throw new Error("Wallet not found");
  await db.update(nexusWallets).set({ gold: wallet.gold + amount }).where(eq(nexusWallets.userId, userId));
  return { gold: wallet.gold + amount, gems: wallet.gems };
}

export async function submitArcadeScore(userId: number, gameKey: ArcadeGameKey, score: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  await db.insert(nexusArcadeScores).values({ userId, gameKey, score });
  await addGold(userId, Math.max(1, Math.floor(score / 25)));
}

export async function getArcadeLeaderboard(gameKey: ArcadeGameKey) {
  const db = await getDb();
  if (!db) return [];
  return db.select({ score: nexusArcadeScores.score, name: users.name, userId: nexusArcadeScores.userId, createdAt: nexusArcadeScores.createdAt }).from(nexusArcadeScores).innerJoin(users, eq(nexusArcadeScores.userId, users.id)).where(eq(nexusArcadeScores.gameKey, gameKey)).orderBy(desc(nexusArcadeScores.score)).limit(20);
}

export async function submitTournamentScore(userId: number, score: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const weekKey = currentWeekKey();
  const existing = await db.select().from(nexusTournamentScores).where(eq(nexusTournamentScores.userId, userId)).limit(10);
  const thisWeek = existing.find((entry) => entry.weekKey === weekKey);
  if (!thisWeek) await db.insert(nexusTournamentScores).values({ userId, weekKey, score });
  else if (score > thisWeek.score) await db.update(nexusTournamentScores).set({ score }).where(eq(nexusTournamentScores.id, thisWeek.id));
  return weekKey;
}

export async function getTournamentLeaderboard() {
  const db = await getDb();
  if (!db) return { weekKey: currentWeekKey(), entries: [] };
  const weekKey = currentWeekKey();
  const entries = await db.select({ score: nexusTournamentScores.score, name: users.name, userId: nexusTournamentScores.userId }).from(nexusTournamentScores).innerJoin(users, eq(nexusTournamentScores.userId, users.id)).where(eq(nexusTournamentScores.weekKey, weekKey)).orderBy(desc(nexusTournamentScores.score)).limit(30);
  return { weekKey, entries };
}

export async function listClans() {
  const db = await getDb();
  if (!db) return [];
  const clans = await db.select().from(nexusClans).orderBy(desc(nexusClans.createdAt)).limit(30);
  return Promise.all(clans.map(async (clan) => {
    const members = await db.select({ value: count() }).from(nexusClanMembers).where(eq(nexusClanMembers.clanId, clan.id));
    return { ...clan, members: Number(members[0]?.value ?? 0) };
  }));
}

export async function getMyClan(userId: number) {
  const db = await getDb();
  if (!db) return null;
  const memberships = await db.select().from(nexusClanMembers).where(eq(nexusClanMembers.userId, userId)).limit(1);
  const membership = memberships[0];
  if (!membership) return null;
  const clans = await db.select().from(nexusClans).where(eq(nexusClans.id, membership.clanId)).limit(1);
  return clans[0] ? { ...clans[0], role: membership.role } : null;
}

export async function createClan(userId: number, name: string) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  if (await getMyClan(userId)) throw new Error("ALREADY_IN_CLAN");
  const created = await db.insert(nexusClans).values({ name, ownerUserId: userId });
  const clanId = Number(created[0].insertId);
  await db.insert(nexusClanMembers).values({ clanId, userId, role: "leader" });
  return { id: clanId, name, role: "leader" as const };
}

export async function joinClan(userId: number, clanId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  if (await getMyClan(userId)) throw new Error("ALREADY_IN_CLAN");
  const clan = await db.select().from(nexusClans).where(eq(nexusClans.id, clanId)).limit(1);
  if (!clan[0]) throw new Error("CLAN_NOT_FOUND");
  await db.insert(nexusClanMembers).values({ clanId, userId, role: "member" });
  return { ...clan[0], role: "member" as const };
}

export async function getSetting(key: string) {
  const db = await getDb();
  if (!db) return null;
  const rows = await db.select().from(nexusSettings).where(eq(nexusSettings.settingKey, key)).limit(1);
  return rows[0]?.settingValue ?? null;
}

export async function setSetting(key: string, value: string) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  await db.insert(nexusSettings).values({ settingKey: key, settingValue: value }).onDuplicateKeyUpdate({ set: { settingValue: value, updatedAt: new Date() } });
}

export async function logAudit(actorUserId: number | null, eventType: string, payload: Record<string, unknown>) {
  const db = await getDb();
  if (!db) return;
  await db.insert(nexusAuditLogs).values({ actorUserId, eventType, payload: JSON.stringify(payload) });
}

export async function getAdminSummary() {
  const db = await getDb();
  if (!db) return { users: 0, clans: 0, arcadeScores: 0 };
  const [userCount, clanCount, scoreCount] = await Promise.all([
    db.select({ value: count() }).from(users),
    db.select({ value: count() }).from(nexusClans),
    db.select({ value: count() }).from(nexusArcadeScores),
  ]);
  return { users: Number(userCount[0]?.value ?? 0), clans: Number(clanCount[0]?.value ?? 0), arcadeScores: Number(scoreCount[0]?.value ?? 0) };
}

export async function getRecentAudit() {
  const db = await getDb();
  if (!db) return [];
  return db.select().from(nexusAuditLogs).orderBy(desc(nexusAuditLogs.createdAt)).limit(30);
}
