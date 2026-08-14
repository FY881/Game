// Style philosophy: مختبر المعرفة المعاصر — questions stay focused, legible, and teach something after the answer.
import type { Question } from "./types";

export const questions: Question[] = [
  {
    id: "signal-01",
    level: 1,
    category: "الأنماط",
    prompt: "ما الرقم التالي في السلسلة: 2، 4، 8، 16، ؟",
    options: ["24", "30", "32", "36"],
    answer: 2,
    hint: "كل خطوة تضاعف القيمة السابقة.",
    explanation: "النمط هو الضرب في 2، لذلك 16 × 2 = 32.",
  },
  {
    id: "signal-02",
    level: 1,
    category: "الاستنتاج",
    prompt: "كل العقد الليمونية مضيئة. العقدة A ليمونية. ماذا نستنتج؟",
    options: ["A مضيئة", "A مطفأة", "لا يمكن معرفة شيء", "A زرقاء"],
    answer: 0,
    hint: "طبّق القاعدة على العقدة A مباشرة.",
    explanation: "بما أن كل العقد الليمونية مضيئة، والعقدة A ليمونية، فهي مضيئة.",
  },
  {
    id: "signal-03",
    level: 2,
    category: "اللغة",
    prompt: "أي كلمة لا تنتمي إلى المجموعة؟",
    options: ["بوصلة", "خريطة", "مقياس", "نافذة"],
    answer: 3,
    hint: "ثلاث كلمات تساعدك على التنقل.",
    explanation: "نافذة لا ترتبط بأدوات الملاحة مثل الكلمات الأخرى.",
  },
  {
    id: "signal-04",
    level: 2,
    category: "المنطق",
    prompt: "إذا سبقت مريم خالدًا، وخالد سبق سامر، فمن في المنتصف؟",
    options: ["مريم", "خالد", "سامر", "لا أحد"],
    answer: 1,
    hint: "رتّب الأسماء كما وردت في الجملة.",
    explanation: "الترتيب هو مريم ثم خالد ثم سامر، لذلك خالد في المنتصف.",
  },
  {
    id: "signal-05",
    level: 3,
    category: "الحساب",
    prompt: "لديك 3 عقد، وكل عقدة تتصل بعقدتين جديدتين. كم اتصالًا جديدًا في الجولة الأولى؟",
    options: ["3", "5", "6", "9"],
    answer: 2,
    hint: "اضرب عدد العقد في عدد الاتصالات لكل عقدة.",
    explanation: "3 عقد × اتصالين لكل عقدة = 6 اتصالات جديدة.",
  },
  {
    id: "signal-06",
    level: 3,
    category: "التركيز",
    prompt: "اختر العبارة التي تعكس تفكيرًا أدق.",
    options: ["أسرع إجابة هي الأفضل دائمًا", "الدليل يسبق الحكم", "الحظ يكفي", "كل المسائل متشابهة"],
    answer: 1,
    hint: "ابحث عن العبارة التي تصف منهجًا يمكن التحقق منه.",
    explanation: "البدء بالدليل يقلل التسرع ويقود إلى حكم يمكن مراجعته.",
  },
  {
    id: "signal-07",
    level: 4,
    category: "الأنماط",
    prompt: "ما العنصر المختلف: مثلث، مربع، دائرة، مستطيل؟",
    options: ["مثلث", "مربع", "دائرة", "مستطيل"],
    answer: 2,
    hint: "قارن عدد الأضلاع.",
    explanation: "الدائرة هي الوحيدة التي لا تملك أضلاعًا مستقيمة.",
  },
  {
    id: "signal-08",
    level: 4,
    category: "الاستنتاج",
    prompt: "إذا كانت كل الإشارات الخضراء آمنة، وبعض الإشارات في المسار خضراء، فما الذي نعرفه يقينًا؟",
    options: ["كل المسار آمن", "الإشارات الخضراء آمنة", "لا توجد إشارات حمراء", "المسار قصير"],
    answer: 1,
    hint: "لا تعمم من جزء من المسار إلى كله.",
    explanation: "المعلومة المؤكدة تخص الإشارات الخضراء فقط، ولا تكفي للحكم على باقي المسار.",
  },
];

export function getQuestion(index: number, difficulty = 1) {
  const eligible = questions.filter((question) => question.level <= Math.max(1, difficulty));
  return eligible[index % eligible.length] ?? questions[0];
}
