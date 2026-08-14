import { describe, expect, it } from "vitest";
import { architectRunKey, evaluateArchitect } from "./architectLogic";

describe("Nexus Architect", () => {
  it("يخفض الصحة ويقترح خطوات آمنة عند غياب النشاط", () => {
    const result = evaluateArchitect({ users: 0, clans: 0, arcadeScores: 0, tournamentScores: 0, recentAuditEvents: 0 });
    expect(result.status).toBe("attention");
    expect(result.recommendations.some((item) => item.id === "no-players")).toBe(true);
  });

  it("ينتج مفتاح تشغيل ثابتًا لكل ربع ساعة لمنع الازدواجية", () => {
    const one = architectRunKey("task-1", new Date("2026-08-14T03:07:00.000Z"));
    const two = architectRunKey("task-1", new Date("2026-08-14T03:14:59.000Z"));
    expect(one).toBe(two);
  });
});
