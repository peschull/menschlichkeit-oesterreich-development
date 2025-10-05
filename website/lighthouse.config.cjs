module.exports = {
  extends: 'lighthouse:default',
  settings: {
    formFactor: 'mobile',
    screenEmulation: { mobile: true, width: 360, height: 640, deviceScaleFactor: 2, disabled: false },
    throttling: {
      rttMs: 150,
      throughputKbps: 1638.4,
      cpuSlowdownMultiplier: 4,
      requestLatencyMs: 150,
      downloadThroughputKbps: 1638.4,
      uploadThroughputKbps: 750,
    },
    budgets: [
      {
        path: '/',
        resourceSizes: [
          { resourceType: 'script', budget: 180 },
          { resourceType: 'stylesheet', budget: 60 },
          { resourceType: 'image', budget: 300 },
          { resourceType: 'document', budget: 50 },
          { resourceType: 'font', budget: 200 },
          { resourceType: 'total', budget: 600 },
        ],
        resourceCounts: [
          { resourceType: 'script', budget: 10 },
          { resourceType: 'stylesheet', budget: 5 },
          { resourceType: 'image', budget: 20 },
        ],
      },
    ],
  },
};
