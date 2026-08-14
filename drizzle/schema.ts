import { bigint, index, int, mysqlEnum, mysqlTable, text, timestamp, uniqueIndex, varchar } from "drizzle-orm/mysql-core";

/**
 * Core user table backing auth flow.
 * Extend this file with additional tables as your product grows.
 * Columns use camelCase to match both database fields and generated types.
 */
export const users = mysqlTable("users", {
  /**
   * Surrogate primary key. Auto-incremented numeric value managed by the database.
   * Use this for relations between tables.
   */
  id: int("id").autoincrement().primaryKey(),
  /** Manus OAuth identifier (openId) returned from the OAuth callback. Unique per user. */
  openId: varchar("openId", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  loginMethod: varchar("loginMethod", { length: 64 }),
  role: mysqlEnum("role", ["user", "admin"]).default("user").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  lastSignedIn: timestamp("lastSignedIn").defaultNow().notNull(),
});

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;

export const nexusProgress = mysqlTable("nexus_progress", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("userId").notNull().unique(),
  snapshot: text("snapshot").notNull(),
  clientUpdatedAt: bigint("clientUpdatedAt", { mode: "number" }).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

export type NexusProgressRow = typeof nexusProgress.$inferSelect;

export const nexusWallets = mysqlTable("nexus_wallets", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("userId").notNull().unique(),
  gold: int("gold").notNull().default(0),
  gems: int("gems").notNull().default(0),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

export const nexusArcadeScores = mysqlTable("nexus_arcade_scores", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("userId").notNull(),
  gameKey: varchar("gameKey", { length: 48 }).notNull(),
  score: int("score").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
}, (table) => ({
  gameScore: index("nexus_arcade_game_score_idx").on(table.gameKey, table.score),
  playerGame: index("nexus_arcade_player_game_idx").on(table.userId, table.gameKey),
}));

export const nexusTournamentScores = mysqlTable("nexus_tournament_scores", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("userId").notNull(),
  weekKey: varchar("weekKey", { length: 12 }).notNull(),
  score: int("score").notNull().default(0),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
}, (table) => ({
  playerWeek: uniqueIndex("nexus_tournament_player_week_unique").on(table.userId, table.weekKey),
  weekScore: index("nexus_tournament_week_score_idx").on(table.weekKey, table.score),
}));

export const nexusClans = mysqlTable("nexus_clans", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 32 }).notNull().unique(),
  ownerUserId: int("ownerUserId").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export const nexusClanMembers = mysqlTable("nexus_clan_members", {
  id: int("id").autoincrement().primaryKey(),
  clanId: int("clanId").notNull(),
  userId: int("userId").notNull().unique(),
  role: mysqlEnum("role", ["leader", "member"]).notNull().default("member"),
  joinedAt: timestamp("joinedAt").defaultNow().notNull(),
}, (table) => ({ clanMembership: index("nexus_clan_membership_idx").on(table.clanId) }));

export const nexusSettings = mysqlTable("nexus_settings", {
  id: int("id").autoincrement().primaryKey(),
  settingKey: varchar("settingKey", { length: 64 }).notNull().unique(),
  settingValue: text("settingValue").notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

export const nexusAuditLogs = mysqlTable("nexus_audit_logs", {
  id: int("id").autoincrement().primaryKey(),
  actorUserId: int("actorUserId"),
  eventType: varchar("eventType", { length: 64 }).notNull(),
  payload: text("payload").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
}, (table) => ({ auditCreated: index("nexus_audit_created_idx").on(table.createdAt) }));

export const nexusArchitectConfig = mysqlTable("nexus_architect_config", {
  id: int("id").autoincrement().primaryKey(),
  enabled: int("enabled").notNull().default(1),
  cadenceMinutes: int("cadenceMinutes").notNull().default(15),
  scheduleCronTaskUid: varchar("scheduleCronTaskUid", { length: 65 }).unique(),
  lastRunAt: timestamp("lastRunAt"),
  lastStatus: varchar("lastStatus", { length: 24 }),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
}, (table) => ({ architectTaskUid: index("nexus_architect_task_uid_idx").on(table.scheduleCronTaskUid) }));

export const nexusArchitectRuns = mysqlTable("nexus_architect_runs", {
  id: int("id").autoincrement().primaryKey(),
  configId: int("configId").notNull(),
  runKey: varchar("runKey", { length: 48 }).notNull().unique(),
  status: varchar("status", { length: 24 }).notNull(),
  healthScore: int("healthScore").notNull(),
  recommendations: text("recommendations").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
}, (table) => ({ architectRunConfig: index("nexus_architect_run_config_idx").on(table.configId, table.createdAt) }));
