import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

describe("واجهة Nexus Architect", () => {
  it("لا تستدعي إلا إجراءات Architect المسموحة", () => {
    const pagePath = fileURLToPath(new URL("../client/src/pages/ArchitectConsole.tsx", import.meta.url));
    const source = readFileSync(pagePath, "utf8");
    const calls = [...source.matchAll(/trpc\.architect\.([A-Za-z]+)/g)].map((match) => match[1]);
    expect([...new Set(calls)].sort()).toEqual(["overview", "runNow", "setEnabled"]);
    expect(source).not.toContain("trpc.admin.setMaintenance");
    expect(source).not.toContain("trpc.economy");
    expect(source).not.toContain("trpc.community");
  });
});
