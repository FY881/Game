import { describe, expect, it } from "vitest";
import { generateQuestions, pickAdaptive, recordAnswer } from "./adaptive";
import type { Question, SkillModel } from "./types";

const bank: Question[] = [
  { id: "logic", level: 1, category: "المنطق", prompt: "q", options: ["a", "b", "c", "d"], answer: 0, hint: "h", explanation: "e" },
  { id: "math", level: 1, category: "الحساب", prompt: "q", options: ["a", "b", "c", "d"], answer: 0, hint: "h", explanation: "e" },
];

describe("محرك Nexus التكيفي", () => {
  it("يسجل الإجابة ويحدث مهارة الفئة", () => {
    const base: SkillModel = { updatedAt: 0, skills: {} };
    const result = recordAnswer("المنطق", true, 8, base);
    expect(result.skills["المنطق"]).toMatchObject({ attempts: 1, correct: 1, recentStreak: 1, averageSeconds: 8 });
  });

  it("يقدم الفئة الأضعف أولًا", () => {
    const model: SkillModel = { updatedAt: 1, skills: { "المنطق": { attempts: 4, correct: 4, averageSeconds: 6, recentStreak: 3 }, "الحساب": { attempts: 4, correct: 1, averageSeconds: 20, recentStreak: 0 } } };
    expect(pickAdaptive(bank, model, 1, 2).map((question) => question.id)[0]).toBe("math");
  });

  it("ينتج أسئلة فريدة مع خيار صحيح صالح", () => {
    const generated = generateQuestions(4, 100);
    expect(new Set(generated.map((question) => question.id)).size).toBe(4);
    generated.forEach((question) => expect(question.options[question.answer]).toBeTruthy());
  });
});
