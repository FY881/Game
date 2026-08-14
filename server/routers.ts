import { COOKIE_NAME } from "@shared/const";
import { z } from "zod";
import { getSessionCookieOptions } from "./_core/cookies";
import { systemRouter } from "./_core/systemRouter";
import { adminProcedure, protectedProcedure, publicProcedure, router } from "./_core/trpc";
import { getNexusProgress, saveNexusProgress } from "./db";
import { chooseFreshestProgress } from "./nexusProgress";
import { ARCADE_GAMES, SHOP_ITEMS } from "./nexusMeta";
import { addGold, createClan, getAdminSummary, getArcadeLeaderboard, getMyClan, getRecentAudit, getSetting, getTournamentLeaderboard, getWallet, joinClan, listClans, logAudit, setSetting, spendGold, submitArcadeScore, submitTournamentScore } from "./communityDb";
import { getArchitectOverview, runArchitect, setArchitectEnabled } from "./architectDb";

const progressInput = z.object({
  xp: z.number().int().min(0).max(10_000_000),
  level: z.number().int().min(1).max(100),
  streak: z.number().int().min(0).max(100_000),
  bestStreak: z.number().int().min(0).max(100_000),
  completedToday: z.number().int().min(0).max(100_000),
  totalSolved: z.number().int().min(0).max(10_000_000),
  accuracy: z.number().int().min(0).max(100),
  unlockedStages: z.number().int().min(1).max(100),
  lastPlayedAt: z.string().nullable(),
  updatedAt: z.number().int().min(0),
  energy: z.number().int().min(0).max(100),
  hearts: z.number().int().min(0).max(20),
  gold: z.number().int().min(0).max(10_000_000),
  bossWins: z.number().int().min(0).max(100_000),
  completedStages: z.array(z.number().int().min(1).max(100)).max(100),
  companionStage: z.number().int().min(0).max(10),
});

export const appRouter = router({
    // if you need to use socket.io, read and register route in server/_core/index.ts, all api should start with '/api/' so that the gateway can route correctly
  system: systemRouter,
  auth: router({
    me: publicProcedure.query(opts => opts.ctx.user),
    logout: publicProcedure.mutation(({ ctx }) => {
      const cookieOptions = getSessionCookieOptions(ctx.req);
      ctx.res.clearCookie(COOKIE_NAME, { ...cookieOptions, maxAge: -1 });
      return {
        success: true,
      } as const;
    }),
  }),
  nexus: router({
    bootstrap: protectedProcedure.query(async ({ ctx }) => ({ progress: await getNexusProgress(ctx.user.id) })),
    sync: protectedProcedure.input(progressInput).mutation(async ({ ctx, input }) => {
      const remote = await getNexusProgress(ctx.user.id);
      const resolved = chooseFreshestProgress(input, remote);
      if (resolved.source === "client") await saveNexusProgress(ctx.user.id, resolved.progress);
      return { ...resolved, syncedAt: new Date().toISOString() };
    }),
  }),
  community: router({
    status: publicProcedure.query(async () => ({ maintenance: (await getSetting("maintenance")) === "true" })),
    tournament: publicProcedure.query(getTournamentLeaderboard),
    clans: publicProcedure.query(listClans),
    myClan: protectedProcedure.query(({ ctx }) => getMyClan(ctx.user.id)),
    createClan: protectedProcedure.input(z.object({ name: z.string().trim().min(3).max(32) })).mutation(async ({ ctx, input }) => {
      const clan = await createClan(ctx.user.id, input.name);
      await logAudit(ctx.user.id, "clan.created", { clanId: clan.id });
      return clan;
    }),
    joinClan: protectedProcedure.input(z.object({ clanId: z.number().int().positive() })).mutation(async ({ ctx, input }) => {
      const clan = await joinClan(ctx.user.id, input.clanId);
      await logAudit(ctx.user.id, "clan.joined", { clanId: clan.id });
      return clan;
    }),
    submitTournament: protectedProcedure.input(z.object({ score: z.number().int().min(0).max(100_000) })).mutation(async ({ ctx, input }) => ({ weekKey: await submitTournamentScore(ctx.user.id, input.score) })),
  }),
  arcade: router({
    leaderboard: publicProcedure.input(z.object({ gameKey: z.enum(ARCADE_GAMES) })).query(({ input }) => getArcadeLeaderboard(input.gameKey)),
    submit: protectedProcedure.input(z.object({ gameKey: z.enum(ARCADE_GAMES), score: z.number().int().min(0).max(100_000) })).mutation(async ({ ctx, input }) => {
      await submitArcadeScore(ctx.user.id, input.gameKey, input.score);
      await logAudit(ctx.user.id, "arcade.score", input);
      return { accepted: true };
    }),
  }),
  economy: router({
    wallet: protectedProcedure.query(({ ctx }) => getWallet(ctx.user.id)),
    purchase: protectedProcedure.input(z.object({ itemKey: z.enum(["hint-token", "focus-token", "atlas-skin"]) })).mutation(async ({ ctx, input }) => {
      const item = SHOP_ITEMS[input.itemKey];
      const wallet = await spendGold(ctx.user.id, item.price);
      await logAudit(ctx.user.id, "economy.purchase", { itemKey: input.itemKey, price: item.price });
      return { wallet, item };
    }),
    reward: protectedProcedure.input(z.object({ amount: z.number().int().min(1).max(100) })).mutation(({ ctx, input }) => addGold(ctx.user.id, input.amount)),
  }),
  admin: router({
    summary: adminProcedure.query(getAdminSummary),
    audit: adminProcedure.query(getRecentAudit),
    setMaintenance: adminProcedure.input(z.object({ enabled: z.boolean() })).mutation(async ({ ctx, input }) => {
      await setSetting("maintenance", String(input.enabled));
      await logAudit(ctx.user.id, "admin.maintenance", input);
      return { enabled: input.enabled };
    }),
  }),
  architect: router({
    overview: adminProcedure.query(getArchitectOverview),
    runNow: adminProcedure.mutation(async ({ ctx }) => {
      const overview = await getArchitectOverview();
      const result = await runArchitect(overview.config.id, `manual-${ctx.user.id}-${Date.now()}`);
      await logAudit(ctx.user.id, "architect.manual-run", { runKey: result.runKey });
      return result;
    }),
    setEnabled: adminProcedure.input(z.object({ enabled: z.boolean() })).mutation(async ({ ctx, input }) => {
      const config = await setArchitectEnabled(input.enabled);
      await logAudit(ctx.user.id, "architect.set-enabled", input);
      return config;
    }),
  }),
});

export type AppRouter = typeof appRouter;
