import { describe, expect, it } from "vitest";
import { currentWeekKey, sanitizeMessage, sanitizeRoomLabel } from "./nexusMeta";

describe("حواجز مجتمع Nexus", () => {
  it("ينظف رسائل الدردشة دون ترك وسوم HTML", () => {
    expect(sanitizeMessage("  <b>أهلاً</b>   بالعالم ")).toBe("bأهلاً/b بالعالم");
  });

  it("يحد اسم الغرفة ويستبدل الاسم الفارغ", () => {
    expect(sanitizeRoomLabel("***")).toBe("غرفة الإشارة");
    expect(sanitizeRoomLabel("غرفة 1")).toBe("غرفة 1");
  });

  it("ينتج مفتاح بطولة أسبوعي ثابتًا", () => {
    expect(currentWeekKey(new Date("2026-01-01T00:00:00.000Z"))).toBe("2026-W01");
  });
});
