import { describe, expect, it } from "vitest";
import { chooseFreshestProgress, type NexusProgressPayload } from "./nexusProgress";

const local: NexusProgressPayload = {
  xp: 1200,
  level: 2,
  streak: 3,
  bestStreak: 6,
  completedToday: 1,
  totalSolved: 20,
  accuracy: 75,
  unlockedStages: 2,
  lastPlayedAt: "2026-08-14T00:00:00.000Z",
  updatedAt: 100,
};

describe("chooseFreshestProgress", () => {
  it("keeps the local snapshot when no cloud snapshot exists", () => {
    expect(chooseFreshestProgress(local, null)).toEqual({ source: "client", progress: local });
  });

  it("restores only a strictly newer cloud snapshot", () => {
    const remote = { ...local, xp: 1600, updatedAt: 101 };
    expect(chooseFreshestProgress(local, remote)).toEqual({ source: "server", progress: remote });
  });
});
