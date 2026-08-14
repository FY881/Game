import { describe, expect, it } from "vitest";
import { awardAdventureStage, rankForLevel } from "./progression";
import { defaultProgress } from "./storage";

describe("تقدم Nexus", () => {
  it("يفتح المحطة التالية ويمنح المكافأة مرة واحدة", () => {
    const once = awardAdventureStage({ ...defaultProgress, completedStages: [], unlockedStages: 1 }, 1);
    const twice = awardAdventureStage(once, 1);
    expect(once).toMatchObject({ unlockedStages: 2, bossWins: 1, gold: 25 });
    expect(twice.xp).toBe(once.xp);
  });

  it("يعرض الرتبة الملائمة للمستوى", () => {
    expect(rankForLevel(1)).toBe("مبتدئ");
    expect(rankForLevel(100)).toBe("أسطورة");
  });
});
