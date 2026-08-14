import { and, count, desc, eq, gte } from "drizzle-orm";
import { nexusArcadeScores, nexusArchitectConfig, nexusArchitectRuns, nexusAuditLogs, nexusClans, nexusSettings, nexusTournamentScores, users } from "../drizzle/schema";
import { getDb } from "./db";
import { architectRunKey, evaluateArchitect } from "./architectLogic";
import { ARCHITECT_POLICY_KEY, DEFAULT_ARCHITECT_POLICY } from "./architectPolicy";

async function ensureArchitectPolicy() {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  await db.insert(nexusSettings).values({ settingKey: ARCHITECT_POLICY_KEY, settingValue: JSON.stringify(DEFAULT_ARCHITECT_POLICY) }).onDuplicateKeyUpdate({ set: { settingKey: ARCHITECT_POLICY_KEY } });
  const rows = await db.select().from(nexusSettings).where(eq(nexusSettings.settingKey, ARCHITECT_POLICY_KEY)).limit(1);
  try {
    return JSON.parse(rows[0]?.settingValue ?? "") as typeof DEFAULT_ARCHITECT_POLICY;
  } catch {
    return DEFAULT_ARCHITECT_POLICY;
  }
}

export async function getOrCreateArchitectConfig() {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const existing = await db.select().from(nexusArchitectConfig).limit(1);
  if (existing[0]) return existing[0];
  const created = await db.insert(nexusArchitectConfig).values({ enabled: 1, cadenceMinutes: 15 });
  const rows = await db.select().from(nexusArchitectConfig).where(eq(nexusArchitectConfig.id, Number(created[0].insertId))).limit(1);
  if (!rows[0]) throw new Error("Architect config creation failed");
  return rows[0];
}

export async function getArchitectConfigByTaskUid(taskUid: string) {
  const db = await getDb();
  if (!db) return null;
  const rows = await db.select().from(nexusArchitectConfig).where(eq(nexusArchitectConfig.scheduleCronTaskUid, taskUid)).limit(1);
  return rows[0] ?? null;
}

export async function setArchitectTaskUid(taskUid: string) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const config = await getOrCreateArchitectConfig();
  await db.update(nexusArchitectConfig).set({ scheduleCronTaskUid: taskUid }).where(eq(nexusArchitectConfig.id, config.id));
  return { ...config, scheduleCronTaskUid: taskUid };
}

export async function setArchitectEnabled(enabled: boolean) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const config = await getOrCreateArchitectConfig();
  await db.update(nexusArchitectConfig).set({ enabled: enabled ? 1 : 0 }).where(eq(nexusArchitectConfig.id, config.id));
  return { ...config, enabled: enabled ? 1 : 0 };
}

export async function runArchitect(configId: number, taskUid: string, now = new Date()) {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  await ensureArchitectPolicy();
  const since = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  const [usersCount, clansCount, arcadeCount, tournamentCount, auditCount] = await Promise.all([
    db.select({ value: count() }).from(users),
    db.select({ value: count() }).from(nexusClans),
    db.select({ value: count() }).from(nexusArcadeScores),
    db.select({ value: count() }).from(nexusTournamentScores),
    db.select({ value: count() }).from(nexusAuditLogs).where(gte(nexusAuditLogs.createdAt, since)),
  ]);
  const evaluation = evaluateArchitect({
    users: Number(usersCount[0]?.value ?? 0),
    clans: Number(clansCount[0]?.value ?? 0),
    arcadeScores: Number(arcadeCount[0]?.value ?? 0),
    tournamentScores: Number(tournamentCount[0]?.value ?? 0),
    recentAuditEvents: Number(auditCount[0]?.value ?? 0),
  });
  const runKey = architectRunKey(taskUid, now);
  await db.insert(nexusArchitectRuns).values({ configId, runKey, status: evaluation.status, healthScore: evaluation.healthScore, recommendations: JSON.stringify(evaluation.recommendations) }).onDuplicateKeyUpdate({ set: { status: evaluation.status, healthScore: evaluation.healthScore, recommendations: JSON.stringify(evaluation.recommendations) } });
  await db.update(nexusArchitectConfig).set({ lastRunAt: now, lastStatus: evaluation.status }).where(eq(nexusArchitectConfig.id, configId));
  await db.insert(nexusAuditLogs).values({ actorUserId: null, eventType: "architect.health-check", payload: JSON.stringify({ runKey, score: evaluation.healthScore, status: evaluation.status }) });
  return { runKey, ...evaluation };
}

export async function getArchitectOverview() {
  const db = await getDb();
  if (!db) throw new Error("Database is unavailable");
  const [config, policy] = await Promise.all([getOrCreateArchitectConfig(), ensureArchitectPolicy()]);
  const runs = await db.select().from(nexusArchitectRuns).where(eq(nexusArchitectRuns.configId, config.id)).orderBy(desc(nexusArchitectRuns.createdAt)).limit(12);
  return {
    config,
    runs: runs.map((run) => ({ ...run, recommendations: JSON.parse(run.recommendations) })),
    policy,
  };
}
