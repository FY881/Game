// Style philosophy: مختبر المعرفة المعاصر — keep game state semantic and UI-independent.
export type Question = {
  id: string;
  level: number;
  category: string;
  prompt: string;
  options: string[];
  answer: number;
  hint: string;
  explanation: string;
};

export type NexusProgress = {
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
