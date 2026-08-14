import type { NexusProgress } from "./types";

const ranks = ["مبتدئ", "مستكشف", "مراقب", "محلل", "استراتيجي", "أسطورة"];

export function levelForXp(xp: number) {
  return Math.max(1, Math.min(100, Math.floor(Math.sqrt(Math.max(0, xp) / 120)) + 1));
}

export function rankForLevel(level: number) {
  return ranks[Math.min(ranks.length - 1, Math.floor((Math.max(1, level) - 1) / 17))];
}

export function companionStage(level: number) {
  return Math.min(4, Math.floor((Math.max(1, level) - 1) / 25));
}

export function normalizeProgress(progress: NexusProgress): NexusProgress {
  const level = levelForXp(progress.xp);
  return { ...progress, level, companionStage: companionStage(level) };
}

export function awardAdventureStage(progress: NexusProgress, stageId: number): NexusProgress {
  if (progress.completedStages.includes(stageId)) return normalizeProgress(progress);
  const completedStages = [...progress.completedStages, stageId].sort((a, b) => a - b);
  const xpReward = 120 + stageId * 40;
  return normalizeProgress({
    ...progress,
    xp: progress.xp + xpReward,
    gold: progress.gold + stageId * 25,
    bossWins: progress.bossWins + 1,
    completedStages,
    unlockedStages: Math.min(5, Math.max(progress.unlockedStages, stageId + 1)),
    energy: Math.max(0, progress.energy - 1),
    updatedAt: Date.now(),
  });
}

export function earnedAchievements(progress: NexusProgress) {
  return [
    { id: "first-signal", title: "أول إشارة", unlocked: progress.totalSolved >= 1 },
    { id: "steady-five", title: "سلسلة ثابتة", unlocked: progress.bestStreak >= 5 },
    { id: "atlas", title: "مستكشف الأطلس", unlocked: progress.completedStages.length >= 3 },
    { id: "boss", title: "كاسر الحراس", unlocked: progress.bossWins >= 1 },
  ];
}
