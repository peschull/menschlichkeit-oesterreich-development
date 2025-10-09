import js from '@eslint/js';
import globals from 'globals';
import tseslint from '@typescript-eslint/eslint-plugin';
import parser from '@typescript-eslint/parser';
import reactHooks from 'eslint-plugin-react-hooks';

export default [
  // Globale Ignores (Flat Config): schließt Build-/Artefaktordner aus
  {
    ignores: [
      'node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/*.min.js',
      'frontend/dist/**',
      'frontend/.next/**',
      'website/**',
      'web/games/js/**',
      'web/games/prototype/**',
      'playwright-results/**',
      'quality-reports/**',
      '**/vendor/**',
      'crm.menschlichkeit-oesterreich.at/web/**',
      'crm.menschlichkeit-oesterreich.at/vendor/**',
      'api.menschlichkeit-oesterreich.at/dist/**',
      'api.menschlichkeit-oesterreich.at/.venv/**',
      '**/.venv/**',
      '**/__pycache__/**',
      '**/coverage/**',
      '**/test-results/**',
      'figma-design-system/**',
    ],
  },
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs}'],
    ignores: [
      'node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/*.min.js',
      '**/*.d.ts',
      'frontend/dist/**',
      'frontend/.next/**',
      'api.menschlichkeit-oesterreich.at/dist/**',
      'api.menschlichkeit-oesterreich.at/.venv/**',
      '**/.venv/**',
      '**/__pycache__/**',
      '**/coverage/**',
      '**/test-results/**',
      '**/vendor/**',
      'crm.menschlichkeit-oesterreich.at/vendor/**',
      // Drittanbieter/Artefakte ausschließen, die ESLint unnötig triggern
      'crm.menschlichkeit-oesterreich.at/web/**',
      'playwright-results/**',
      'website/**',
      'figma-design-system/**',
    ],
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
  {
    files: ['**/*.{ts,tsx}'],
    ignores: [
      'node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/*.d.ts',
      'frontend/dist/**',
      'frontend/.next/**',
      'api.menschlichkeit-oesterreich.at/dist/**',
      // Synchron mit JS-Ignores
      'api.menschlichkeit-oesterreich.at/.venv/**',
      '**/.venv/**',
      '**/__pycache__/**',
      '**/coverage/**',
      '**/test-results/**',
      '**/vendor/**',
      'crm.menschlichkeit-oesterreich.at/vendor/**',
      'crm.menschlichkeit-oesterreich.at/web/**',
      'playwright-results/**',
      'quality-reports/**',
      'website/**',
      'figma-design-system/**',
    ],
    languageOptions: {
      parser: parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      '@typescript-eslint': tseslint,
      'react-hooks': reactHooks,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      // TypeScript already checks undefined identifiers; avoid false positives on DOM types like RequestInit
      'no-undef': 'off',
      // React hooks rules for TSX
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      'no-console': 'off',
    },
  },
];
