// Style philosophy: مختبر المعرفة المعاصر — the mark is a visible, geometric signal rather than decorative noise.
export function NexusMark({ compact = false }: { compact?: boolean }) {
  return (
    <div className={`nexus-mark ${compact ? "nexus-mark--compact" : ""}`} aria-label="Nexus">
      <span className="nexus-mark__node nexus-mark__node--a" />
      <span className="nexus-mark__link" />
      <span className="nexus-mark__node nexus-mark__node--b" />
    </div>
  );
}
