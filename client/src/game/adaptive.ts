import type { Question } from "./types";

const SKILL_MODEL_KEY = "nexus-skill-model-v1";

export type SkillStats = {
  attempts: number;
  correct: number;
  averageSeconds: number;
  recentStreak: number;
};

export type SkillModel = {
  updatedAt: number;
  skills: Record<string, SkillStats>;
};

const emptyModel: SkillModel = { updatedAt: 0, skills: {} };

export function loadSkillModel(): SkillModel {
  if (typeof window === "undefined") return emptyModel;
  try {
    const parsed = JSON.parse(window.localStorage.getItem(SKILL_MODEL_KEY) ?? "null") as SkillModel | null;
    return parsed && parsed.skills ? parsed : emptyModel;
  } catch {
    return emptyModel;
  }
}

export function recordAnswer(category: string, correct: boolean, elapsedSeconds: number, source = loadSkillModel()): SkillModel {
  const previous = source.skills[category] ?? { attempts: 0, correct: 0, averageSeconds: 0, recentStreak: 0 };
  const attempts = previous.attempts + 1;
  const next: SkillStats = {
    attempts,
    correct: previous.correct + (correct ? 1 : 0),
    averageSeconds: Math.round(((previous.averageSeconds * previous.attempts) + Math.max(0, elapsedSeconds)) / attempts),
    recentStreak: correct ? previous.recentStreak + 1 : 0,
  };
  const model = { updatedAt: Date.now(), skills: { ...source.skills, [category]: next } };
  if (typeof window !== "undefined") window.localStorage.setItem(SKILL_MODEL_KEY, JSON.stringify(model));
  return model;
}

export function skillScore(stats?: SkillStats) {
  if (!stats?.attempts) return 50;
  const accuracy = stats.correct / stats.attempts;
  const pace = Math.max(0, Math.min(1, 1 - stats.averageSeconds / 30));
  return Math.round((accuracy * 78 + pace * 22) * 100) / 100;
}

export function pickAdaptive(questions: Question[], model: SkillModel, difficulty: number, count = 5): Question[] {
  const eligible = questions.filter((question) => question.level <= Math.max(1, difficulty));
  const ranked = [...eligible].sort((a, b) => {
    const scoreDelta = skillScore(model.skills[a.category]) - skillScore(model.skills[b.category]);
    return scoreDelta || a.level - b.level || a.id.localeCompare(b.id);
  });
  const unique = new Map<string, Question>();
  [...ranked, ...eligible].forEach((question) => unique.set(question.id, question));
  return Array.from(unique.values()).slice(0, Math.min(count, unique.size));
}

export function generateQuestions(count: number, seed = Date.now()): Question[] {
  return Array.from({ length: count }, (_, index) => {
    const serial = Math.abs(seed + index * 17);
    if (index % 2 === 0) {
      const start = 2 + (serial % 7);
      const factor = 2 + (serial % 3);
      const next = start * factor * factor;
      const options = [next - factor, next + factor, next, next + factor * 2];
      return {
        id: `generated-pattern-${serial}`,
        level: 2 + (serial % 3),
        category: "الأنماط",
        prompt: `ما الحد التالي في السلسلة: ${start}، ${start * factor}، ${start * factor * factor}، ؟`,
        options: options.map(String),
        answer: 2,
        hint: `كل حد يُضرب في ${factor}.`,
        explanation: `${start * factor * factor} × ${factor} = ${next}.`,
      };
    }
    const left = 7 + (serial % 11);
    const right = 3 + ((serial * 3) % 9);
    const total = left + right;
    return {
      id: `generated-math-${serial}`,
      level: 2 + (serial % 3),
      category: "الحساب",
      prompt: `لديك ${left} نقاط أثر ثم تكسب ${right} نقاط إضافية. كم يصبح المجموع؟`,
      options: [total - 2, total, total + 1, total + 3].map(String),
      answer: 1,
      hint: "اجمع الرصيدين فقط.",
      explanation: `${left} + ${right} = ${total}.`,
    };
  });
}

export function buildAdaptiveRound(bank: Question[], difficulty: number, count = 5, model = loadSkillModel()) {
  const selected = pickAdaptive(bank, model, difficulty, count);
  if (selected.length >= count) return selected;
  return [...selected, ...generateQuestions(count - selected.length)].slice(0, count);
}

export function generateSmartReport(model = loadSkillModel()) {
  const entries = Object.entries(model.skills);
  if (!entries.length) return { headline: "ابدأ بجولة قصيرة لتظهر خريطة مهاراتك.", focus: "لا توجد بيانات كافية بعد." };
  const [weakest] = [...entries].sort(([, a], [, b]) => skillScore(a) - skillScore(b));
  const [category, stats] = weakest;
  const accuracy = Math.round((stats.correct / stats.attempts) * 100);
  return { headline: `أوضح مسار للمراجعة الآن: ${category}.`, focus: `دقتك في هذه الفئة ${accuracy}% عبر ${stats.attempts} محاولة؛ اختر جولة أخرى لتحسينها.` };
}
