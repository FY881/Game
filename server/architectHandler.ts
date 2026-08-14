import type { Request, Response } from "express";
import { getArchitectConfigByTaskUid, runArchitect } from "./architectDb";
import { sdk } from "./_core/sdk";

export async function architectScheduledHandler(req: Request, res: Response) {
  try {
    const user = await sdk.authenticateRequest(req);
    if (!user.isCron || !user.taskUid) return res.status(403).json({ error: "cron-only" });
    const config = await getArchitectConfigByTaskUid(user.taskUid);
    if (!config) return res.json({ ok: true, skipped: "orphan" });
    if (!config.enabled) return res.json({ ok: true, skipped: "disabled" });
    const result = await runArchitect(config.id, user.taskUid);
    return res.json({ ok: true, ...result });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(500).json({ error: message, context: { url: req.originalUrl }, timestamp: new Date().toISOString() });
  }
}
