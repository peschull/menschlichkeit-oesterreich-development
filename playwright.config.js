/* eslint-env node */
// Playwright E2E Test Configuration
import { defineConfig } from '@playwright/test';
import process from 'node:process';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  // Nutze typeof-Prüfung, um ESLint no-undef zu vermeiden, falls process nicht definiert ist
  ...(function () {
    const isCI = !!(typeof process !== 'undefined' && process.env && process.env.CI);
    return {
      forbidOnly: isCI,
      retries: isCI ? 2 : 0,
      workers: isCI ? 1 : undefined,
      _isCI: isCI,
    };
  })(),
  // Vermeide Konflikt: HTML-Report darf nicht innerhalb des outputDir liegen
  outputDir: 'playwright-artifacts',
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'playwright-artifacts/results.json' }],
    ['junit', { outputFile: 'playwright-artifacts/junit.xml' }],
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  // Node-only Projekt: keine Browser erforderlich, da Tests keine page/browser fixtures nutzen
  projects: [{ name: 'node' }],

  webServer: {
    command: 'cd web && python -m http.server 3000',
    port: 3000,
    reuseExistingServer: !(typeof process !== 'undefined' && process.env && process.env.CI),
  },
});
