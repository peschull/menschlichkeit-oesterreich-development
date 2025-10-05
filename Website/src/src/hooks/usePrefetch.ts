import { useEffect } from 'react';

/**
 * Custom Hook für Idle-Time Component Prefetching
 * @param modules - Array von Modul-Import-Funktionen zum Prefetchen
 */
export function usePrefetch(modules: (() => Promise<any>)[]) {
  useEffect(() => {
    // Check if requestIdleCallback is supported
    if (!('requestIdleCallback' in window)) {
      // Fallback: Use setTimeout
      const timeout = setTimeout(() => {
        modules.forEach((module) => {
          module().catch(() => {
            // Silent fail - prefetching is optional
          });
        });
      }, 1000);

      return () => clearTimeout(timeout);
    }

    // Use requestIdleCallback for better performance
    const idleCallback = (window as any).requestIdleCallback(() => {
      modules.forEach((module) => {
        module().catch(() => {
          // Silent fail - prefetching is optional
        });
      });
    });

    return () => {
      if ('cancelIdleCallback' in window) {
        (window as any).cancelIdleCallback(idleCallback);
      }
    };
  }, [modules]);
}

/**
 * Helper: Prefetch specific components
 */
export const prefetchCriticalComponents = () => {
  return [
    () => import('../components/DemocracyGameHub'),
    () => import('../components/Forum'),
  ];
};

export const prefetchSecondaryComponents = () => {
  return [
    () => import('../components/Events'),
    () => import('../components/News'),
    () => import('../components/Contact'),
  ];
};