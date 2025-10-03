'use client';

import { CheckCircleIcon, XCircleIcon, ClockIcon } from '@heroicons/react/24/outline';

interface CIStatusWidgetProps {
  status?: 'success' | 'failed' | 'running';
  workflow?: string;
  branch?: string;
  duration?: string;
}

export function CIStatusWidget({
  status = 'success',
  workflow = 'CI/CD Pipeline',
  branch = 'main',
  duration = '2m 34s',
}: CIStatusWidgetProps) {
  const statusConfig = {
    success: {
      icon: CheckCircleIcon,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
      label: 'Success',
    },
    failed: {
      icon: XCircleIcon,
      color: 'text-red-600',
      bgColor: 'bg-red-50',
      label: 'Failed',
    },
    running: {
      icon: ClockIcon,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
      label: 'Running',
    },
  };

  const config = statusConfig[status];
  const Icon = config.icon;

  return (
    <div className="widget-card">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">GitHub CI Status</h3>
        <div className={`p-2 rounded-lg ${config.bgColor}`}>
          <Icon className={`w-6 h-6 ${config.color}`} aria-hidden="true" />
        </div>
      </div>
      
      <div className="space-y-3">
        <div>
          <p className="text-sm text-gray-500">Workflow</p>
          <p className="text-base font-medium text-gray-900">{workflow}</p>
        </div>
        
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500">Branch</p>
            <p className="text-base font-medium text-gray-900">{branch}</p>
          </div>
          
          <div className="text-right">
            <p className="text-sm text-gray-500">Duration</p>
            <p className="text-base font-medium text-gray-900">{duration}</p>
          </div>
        </div>
        
        <div className="pt-3 border-t border-gray-200">
          <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${config.bgColor} ${config.color}`}>
            {config.label}
          </span>
        </div>
      </div>
    </div>
  );
}
