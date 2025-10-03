'use client';

import { CIStatusWidget } from '../components/widgets/CIStatusWidget';
import { MembersWidget } from '../components/widgets/MembersWidget';

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Willkommen im Admin-Portal von Menschlichkeit Österreich
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <CIStatusWidget status="success" />
        <MembersWidget />
        
        {/* Forum Widget Placeholder */}
        <div className="widget-card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Forum Aktivität</h3>
          <div className="space-y-3">
            <div>
              <p className="text-3xl font-bold text-gray-900">47</p>
              <p className="text-sm text-gray-500">Neue Beiträge (24h)</p>
            </div>
            <div className="grid grid-cols-2 gap-4 pt-3 border-t border-gray-200">
              <div>
                <p className="text-lg font-semibold text-orange-600">12</p>
                <p className="text-xs text-gray-500">Zu moderieren</p>
              </div>
              <div>
                <p className="text-lg font-semibold text-green-600">892</p>
                <p className="text-xs text-gray-500">Aktive User</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="widget-card">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Letzte Aktivitäten</h2>
        <div className="space-y-3">
          {[
            { user: 'Anna M.', action: 'hat sich registriert', time: 'vor 5 Minuten', type: 'success' },
            { user: 'System', action: 'Backup abgeschlossen', time: 'vor 1 Stunde', type: 'info' },
            { user: 'Thomas K.', action: 'Forum-Beitrag gemeldet', time: 'vor 2 Stunden', type: 'warning' },
          ].map((activity, index) => (
            <div key={index} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
              <div className="flex items-center gap-3">
                <div className={`w-2 h-2 rounded-full ${
                  activity.type === 'success' ? 'bg-green-500' :
                  activity.type === 'warning' ? 'bg-orange-500' :
                  'bg-blue-500'
                }`} />
                <div>
                  <p className="text-sm font-medium text-gray-900">
                    <span className="font-semibold">{activity.user}</span> {activity.action}
                  </p>
                  <p className="text-xs text-gray-500">{activity.time}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
