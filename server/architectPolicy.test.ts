import { describe, expect, it } from "vitest";
import { DEFAULT_ARCHITECT_POLICY } from "./architectPolicy";

describe("سياسة Nexus Architect", () => {
  it("تحتوي على قائمة صريحة بالإجراءات الممنوعة الحساسة", () => {
    expect(DEFAULT_ARCHITECT_POLICY.prohibited.some((item) => item.includes("حذف البيانات"))).toBe(true);
    expect(DEFAULT_ARCHITECT_POLICY.prohibited.some((item) => item.includes("تغيير أدوار"))).toBe(true);
  });
});
