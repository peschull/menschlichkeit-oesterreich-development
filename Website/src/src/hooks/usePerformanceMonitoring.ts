import { useEffect } from 'react';

/**
 * Custom Hook für Web Vitals Performance Monitoring
 * Trackt LCP, FID, CLS automatisch
 */
export function usePerformanceMonitoring() {
  useEffect(() => {
    if (!('PerformanceObserver' in window)) return;

    try {
      // Largest Contentful Paint (LCP)
      const lcpObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        const lastEntry = entries[entries.length - 1];
        const lcpValue = lastEntry.renderTime || lastEntry.loadTime;

        console.log('LCP:', lcpValue);

        // Optional: Send to analytics
        if (window.gtag) {
          window.gtag('event', 'web_vitals', {
            event_category: 'Performance',
            event_label: 'LCP',
            value: Math.round(lcpValue),
          });
        }
      });
      lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });

      // First Input Delay (FID)
      const fidObserver = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          const fidValue = entry.processingStart - entry.startTime;
          console.log('FID:', fidValue);

          if (window.gtag) {
            window.gtag('event', 'web_vitals', {
              event_category: 'Performance',
              event_label: 'FID',
              value: Math.round(fidValue),
            });
          }
        }
      });
      fidObserver.observe({ entryTypes: ['first-input'] });

      // Cumulative Layout Shift (CLS)
      let clsValue = 0;
      const clsObserver = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (!(entry as any).hadRecentInput) {
            clsValue += (entry as any).value;
            console.log('CLS:', clsValue);

            if (window.gtag) {
              window.gtag('event', 'web_vitals', {
                event_category: 'Performance',
                event_label: 'CLS',
                value: Math.round(clsValue * 1000),
              });
            }
          }
        }
      });
      clsObserver.observe({ entryTypes: ['layout-shift'] });

      // Cleanup
      return () => {
        lcpObserver.disconnect();
        fidObserver.disconnect();
        clsObserver.disconnect();
      };
    } catch (error) {
      console.warn('Performance monitoring not supported:', error);
    }
  }, []);
}

// Type augmentation for gtag
declare global {
  interface Window {
    gtag?: (...args: any[]) => void;
  }
}
