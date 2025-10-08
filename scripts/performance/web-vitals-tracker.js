// Web Vitals Performance Tracking
// Menschlichkeit Österreich Platform

class PerformanceTracker {
  constructor() {
    this.metrics = {
      fcp: null,    // First Contentful Paint
      lcp: null,    // Largest Contentful Paint
      fid: null,    // First Input Delay
      cls: null,    // Cumulative Layout Shift
      ttfb: null    // Time to First Byte
    };
    
    this.webhookUrl = 'https://n8n.menschlichkeit-oesterreich.at/webhook/performance';
    this.init();
  }

  init() {
    // Performance Observer für Web Vitals
    if ('PerformanceObserver' in window) {
      this.observeFCP();
      this.observeLCP();
      this.observeCLS();
      this.observeFID();
    }
    
    // TTFB from Navigation Timing
    this.measureTTFB();
    
    // Send metrics after page load
    window.addEventListener('load', () => {
      setTimeout(() => this.sendMetrics(), 1000);
    });
  }

  observeFCP() {
    new PerformanceObserver((list) => {
      const entry = list.getEntries()[0];
      this.metrics.fcp = entry.startTime;
    }).observe({ entryTypes: ['paint'] });
  }

  observeLCP() {
    new PerformanceObserver((list) => {
      const entries = list.getEntries();
      const lastEntry = entries[entries.length - 1];
      this.metrics.lcp = lastEntry.startTime;
    }).observe({ entryTypes: ['largest-contentful-paint'] });
  }

  observeCLS() {
    let clsValue = 0;
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (!entry.hadRecentInput) {
          clsValue += entry.value;
        }
      }
      this.metrics.cls = clsValue;
    }).observe({ entryTypes: ['layout-shift'] });
  }

  observeFID() {
    new PerformanceObserver((list) => {
      const entry = list.getEntries()[0];
      this.metrics.fid = entry.processingStart - entry.startTime;
    }).observe({ entryTypes: ['first-input'] });
  }

  measureTTFB() {
    const navigation = performance.getEntriesByType('navigation')[0];
    if (navigation) {
      this.metrics.ttfb = navigation.responseStart - navigation.requestStart;
    }
  }

  async sendMetrics() {
    const payload = {
      url: window.location.href,
      timestamp: Date.now(),
      userAgent: navigator.userAgent,
      metrics: this.metrics,
      connection: navigator.connection ? {
        effectiveType: navigator.connection.effectiveType,
        downlink: navigator.connection.downlink
      } : null
    };

    try {
      await fetch(this.webhookUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      console.log('📊 Performance metrics sent:', this.metrics);
    } catch (error) {
      console.warn('Performance tracking failed:', error);
    }
  }

  getMetrics() {
    return this.metrics;
  }
}

// Auto-initialize on supported pages
if (typeof window !== 'undefined') {
  window.performanceTracker = new PerformanceTracker();
}

module.exports = PerformanceTracker;
