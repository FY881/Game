export type NexusProgressPayload = {
  xp: number;
  level: number;
  streak: number;
  bestStreak: number;
  completedToday: number;
  totalSolved: number;
  accuracy: number;
  unlockedStages: number;
  lastPlayedAt: string | null;
  updatedAt: number;
  energy: number;
  hearts: number;
  gold: number;
  bossWins: number;
  completedStages: number[];
  companionStage: number;
};

export function chooseFreshestProgress(local: NexusProgressPayload, remote: NexusProgressPayload | null) {
  if (remote && remote.updatedAt > local.updatedAt) {
    return { source: "server" as const, progress: remote };
  }
  return { source: "client" as const, progress: local };
}
