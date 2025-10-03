'use client';

import { useState } from 'react';
import {
  HomeIcon,
  UserGroupIcon,
  CurrencyEuroIcon,
  ChatBubbleLeftRightIcon,
  ChartBarIcon,
  Cog6ToothIcon,
  Bars3Icon,
  XMarkIcon,
} from '@heroicons/react/24/outline';

interface SidebarProps {
  collapsed?: boolean;
  onToggle?: () => void;
}

const menuItems = [
  { id: 'dashboard', label: 'Dashboard', icon: HomeIcon, href: '/' },
  { id: 'members', label: 'Mitglieder', icon: UserGroupIcon, href: '/members' },
  { id: 'dues', label: 'Beiträge', icon: CurrencyEuroIcon, href: '/dues' },
  { id: 'forum', label: 'Forum', icon: ChatBubbleLeftRightIcon, href: '/forum' },
  { id: 'analytics', label: 'Analytics', icon: ChartBarIcon, href: '/analytics' },
  { id: 'settings', label: 'Einstellungen', icon: Cog6ToothIcon, href: '/settings' },
];

export function Sidebar({ collapsed = false, onToggle }: SidebarProps) {
  const [activeItem, setActiveItem] = useState('dashboard');

  return (
    <aside
      className={`admin-sidebar transition-all duration-300 ${
        collapsed ? 'w-16' : 'w-64'
      }`}
    >
      <div className="p-4">
        {/* Logo */}
        <div className="flex items-center justify-between mb-8">
          {!collapsed && (
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-r from-brand-red to-orange-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">M🇦🇹</span>
              </div>
              <span className="font-bold text-lg">Admin Portal</span>
            </div>
          )}
          <button
            onClick={onToggle}
            className="p-2 rounded-lg hover:bg-gray-100"
            aria-label={collapsed ? 'Sidebar erweitern' : 'Sidebar einklappen'}
          >
            {collapsed ? (
              <Bars3Icon className="w-5 h-5" />
            ) : (
              <XMarkIcon className="w-5 h-5" />
            )}
          </button>
        </div>

        {/* Menu Items */}
        <nav className="space-y-1">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeItem === item.id;
            
            return (
              <a
                key={item.id}
                href={item.href}
                onClick={(e) => {
                  e.preventDefault();
                  setActiveItem(item.id);
                }}
                className={`admin-sidebar-item ${isActive ? 'active' : ''}`}
                aria-current={isActive ? 'page' : undefined}
              >
                <Icon className="w-5 h-5" aria-hidden="true" />
                {!collapsed && <span>{item.label}</span>}
              </a>
            );
          })}
        </nav>
      </div>
    </aside>
  );
}
