// Style philosophy: مختبر المعرفة المعاصر — progress is durable, explicit, and never hidden behind a fake network state.
import type { NexusProgress } from "./types";

const STORAGE_KEY = "nexus-progress-v2";

export const defaultProgress: NexusProgress = {
  xp: 1240,
  level: 2,
  streak: 4,
  bestStreak: 9,
  completedToday: 2,
  totalSolved: 86,
  accuracy: 78,
  unlockedStages: 2,
  lastPlayedAt: null,
};

export function loadProgress(): NexusProgress {
  if (typeof window === "undefined") return defaultProgress;
  try {
    const parsed = JSON.parse(window.localStorage.getItem(STORAGE_KEY) ?? "null") as Partial<NexusProgress> | null;
    return parsed ? { ...defaultProgress, ...parsed } : defaultProgress;
  } catch {
    return defaultProgress;
  }
}

export function saveProgress(progress: NexusProgress) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
}
