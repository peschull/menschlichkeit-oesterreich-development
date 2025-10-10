import React from 'react';
import { api } from '../../services/api';

type MCPStatus = 'ok' | 'warn' | 'error';

interface StatusPayload {
  status: MCPStatus;
  summary: { oks: number; warns: number; errs: number };
  ts?: string;
}

function statusColor(status: MCPStatus): string {
  switch (status) {
    case 'ok':
      return 'bg-green-100 text-green-800 border-green-300';
    case 'warn':
      return 'bg-yellow-100 text-yellow-800 border-yellow-300';
    case 'error':
    default:
      return 'bg-red-100 text-red-800 border-red-300';
  }
}

export const MCPStatusBadge: React.FC = () => {
  const [data, setData] = React.useState<StatusPayload | null>(null);
  const [error, setError] = React.useState<string | null>(null);
  const [loading, setLoading] = React.useState(true);

  const load = React.useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.mcpStatus();
      setData({ status: res.status, summary: res.summary, ts: res.ts });
    } catch {
      setError('Status nicht verfügbar');
    } finally {
      setLoading(false);
    }
  }, []);

  React.useEffect(() => {
    void load();
    const id = setInterval(load, 60_000); // Refresh minütlich
    return () => clearInterval(id);
  }, [load]);

  if (loading) {
    return (
      <span className="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-gray-100 text-gray-700 border border-gray-300 text-sm">
        <span className="w-2 h-2 rounded-full bg-gray-400 animate-pulse" />
        MCP Status lädt…
      </span>
    );
  }

  if (error || !data) {
    return (
      <span className="inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-red-100 text-red-800 border border-red-300 text-sm">
        <span className="w-2 h-2 rounded-full bg-red-500" />
        MCP Status: Fehler
      </span>
    );
  }

  return (
    <span
      className={`inline-flex items-center gap-3 px-3 py-1 rounded-lg border text-sm ${statusColor(
        data.status
      )}`}
      title={`OK: ${data.summary.oks} · Warn: ${data.summary.warns} · Fehler: ${data.summary.errs}${
        data.ts ? ` · ${new Date(data.ts).toLocaleString('de-AT')}` : ''
      }`}
    >
      <span
        className={`w-2 h-2 rounded-full ${
          data.status === 'ok'
            ? 'bg-green-500'
            : data.status === 'warn'
            ? 'bg-yellow-500'
            : 'bg-red-500'
        }`}
      />
      <span className="font-medium">MCP: {data.status.toUpperCase()}</span>
      <span className="text-xs opacity-80">OK {data.summary.oks}</span>
      <span className="text-xs opacity-80">⚠ {data.summary.warns}</span>
      <span className="text-xs opacity-80">✗ {data.summary.errs}</span>
    </span>
  );
};

export default MCPStatusBadge;
