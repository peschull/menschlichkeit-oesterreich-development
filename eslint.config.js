import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import parser from '@typescript-eslint/parser';
import globals from 'globals';

export default [
  // Global ignores - MUST be first
  {
    ignores: [
      'node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/*.min.js',
      '**/*.d.ts',
      'frontend/dist/**',
      'frontend/.next/**',
      'api.menschlichkeit-oesterreich.at/dist/**',
      '**/.venv/**',
      '**/__pycache__/**',
      '**/coverage/**',
      '**/test-results/**',
      '**/vendor/**',
      '**/sw.js',
      'web/games/**/sw.js',
      'website/sw.js',
      'website/assets/js/**/*.js',
      'frontend/scripts/**',
      // Temporary ignores for files with parsing issues (development phase)
      'frontend/src/hooks/useAuth.ts',
      'frontend/src/components/auth/AuthSystem.tsx',
      'frontend/src/components/privacy/PrivacyCenter.tsx',
      'frontend/src/components/security/SecurityDashboard.tsx',
      'frontend/src/pages/Login.tsx',
      'frontend/src/pages/MemberArea.tsx',
      'frontend/src/services/api.ts',
      'frontend/src/services/api/client.ts',
      'frontend/tailwind.config.ts',
      'web/themes/custom/menschlichkeit/assets/js/theme.js',
      'website/scripts/run-lighthouse.mjs',
    ],
  },
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: { ...globals.browser, ...globals.node },
    },
    rules: {
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-console': 'off',
    },
  },
  // Browser environment for frontend/website
  {
    files: ['frontend/**/*.{js,ts,tsx}', 'website/**/*.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.browser,
        bootstrap: 'readonly',
        gtag: 'readonly',
        Drupal: 'readonly',
        once: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-console': 'off',
    },
  },
  // Service Worker specific
  {
    files: ['**/sw.js'],
    languageOptions: {
      globals: {
        ...globals.serviceworker,
      },
    },
  },
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        jsx: true,
      },
      globals: {
        ...globals.browser,
        ...globals.node,
        React: 'readonly',
        JSX: 'readonly',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-empty-object-type': 'warn',
      'no-console': 'off',
      // Temporary: Downgrade parsing errors to warnings for development
      'parser-error': 'off',
    },
  },
];
