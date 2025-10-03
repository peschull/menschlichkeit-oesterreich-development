'use client';

import { UserGroupIcon } from '@heroicons/react/24/outline';

interface MembersWidgetProps {
  total?: number;
  active?: number;
  newThisMonth?: number;
}

export function MembersWidget({
  total = 1247,
  active = 1089,
  newThisMonth = 23,
}: MembersWidgetProps) {
  const activePercentage = Math.round((active / total) * 100);

  return (
    <div className="widget-card">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">Mitglieder</h3>
        <div className="p-2 rounded-lg bg-blue-50">
          <UserGroupIcon className="w-6 h-6 text-blue-600" aria-hidden="true" />
        </div>
      </div>

      <div className="space-y-4">
        <div>
          <p className="text-3xl font-bold text-gray-900">{total.toLocaleString()}</p>
          <p className="text-sm text-gray-500">Gesamtmitglieder</p>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xl font-semibold text-green-600">{active.toLocaleString()}</p>
            <p className="text-xs text-gray-500">Aktiv ({activePercentage}%)</p>
          </div>
          <div>
            <p className="text-xl font-semibold text-blue-600">+{newThisMonth}</p>
            <p className="text-xs text-gray-500">Neu (Monat)</p>
          </div>
        </div>

        <div className="pt-3 border-t border-gray-200">
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-green-500 h-2 rounded-full transition-all"
              style={{ width: `${activePercentage}%` }}
              role="progressbar"
              aria-valuenow={activePercentage}
              aria-valuemin={0}
              aria-valuemax={100}
              aria-label={`${activePercentage}% aktive Mitglieder`}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
