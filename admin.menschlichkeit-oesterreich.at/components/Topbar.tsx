'use client';

import { MagnifyingGlassIcon, BellIcon, UserCircleIcon } from '@heroicons/react/24/outline';

interface TopbarProps {
  orgName?: string;
}

export function Topbar({ orgName = 'Menschlichkeit Österreich' }: TopbarProps) {
  return (
    <header className="admin-topbar">
      {/* Search */}
      <div className="flex-1 max-w-2xl">
        <div className="relative">
          <MagnifyingGlassIcon
            className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
            aria-hidden="true"
          />
          <input
            type="search"
            placeholder="Suchen..."
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            aria-label="Suche"
          />
        </div>
      </div>

      {/* Right Section */}
      <div className="flex items-center gap-4 ml-6">
        {/* Organization Switcher */}
        <div className="hidden md:flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg">
          <span className="text-sm font-medium text-gray-700">{orgName}</span>
        </div>

        {/* Notifications */}
        <button
          className="relative p-2 rounded-lg hover:bg-gray-100 transition-colors"
          aria-label="Benachrichtigungen"
        >
          <BellIcon className="w-6 h-6 text-gray-600" aria-hidden="true" />
          <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full" aria-label="3 neue Benachrichtigungen" />
        </button>

        {/* User Menu */}
        <button
          className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-100 transition-colors"
          aria-label="Benutzerprofil öffnen"
        >
          <UserCircleIcon className="w-8 h-8 text-gray-600" aria-hidden="true" />
          <span className="hidden md:block text-sm font-medium text-gray-700">Admin</span>
        </button>
      </div>
    </header>
  );
}
