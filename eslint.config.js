// ESLint 9.x Configuration for Menschlichkeit Österreich Workspace
// Multi-language development environment with MCP servers

import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import typescriptParser from '@typescript-eslint/parser';
import importPlugin from 'eslint-plugin-import';

export default [
  // Base JavaScript configuration
  js.configs.recommended,

  {
    name: 'workspace-typescript',
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module',
        project: ['./tsconfig.json', './mcp-servers/*/tsconfig.json'],
      },
    },
    plugins: {
      '@typescript-eslint': typescript,
      import: importPlugin,
    },
    rules: {
      // TypeScript specific rules
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-non-null-assertion': 'warn',

      // Import rules
      'import/order': [
        'error',
        {
          groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
          'newlines-between': 'always',
        },
      ],
      'import/no-unresolved': 'off', // TypeScript handles this
      'import/extensions': [
        'error',
        'ignorePackages',
        {
          ts: 'never',
          tsx: 'never',
          js: 'never',
          jsx: 'never',
        },
      ],
    },
  },

  {
    name: 'workspace-javascript',
    files: ['**/*.js', '**/*.jsx'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
    },
    plugins: {
      import: importPlugin,
    },
    rules: {
      // JavaScript rules
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-console': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
      'import/order': [
        'error',
        {
          groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
          'newlines-between': 'always',
        },
      ],
    },
  },

  {
    name: 'mcp-servers-overrides',
    files: ['mcp-servers/**/*.ts', 'mcp-servers/**/*.js', 'servers/**/*.ts', 'servers/**/*.js'],
    rules: {
      // MCP server specific overrides
      '@typescript-eslint/no-explicit-any': 'off', // MCP protocol uses any
      'no-console': 'off', // Servers need console output
    },
  },

  {
    name: 'test-files-overrides',
    files: [
      '**/*.test.ts',
      '**/*.test.js',
      '**/*.spec.ts',
      '**/*.spec.js',
      '**/tests/**/*.ts',
      '**/tests/**/*.js',
    ],
    rules: {
      // Test file specific overrides
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
      'no-unused-expressions': 'off',
    },
  },

  {
    name: 'ignore-patterns',
    ignores: [
      'node_modules/**',
      'dist/**',
      'build/**',
      'coverage/**',
      '*.min.js',
      'vendor/**',
      '.git/**',
      '.vscode/**',
      '*.log',
      'tmp/**',
      'temp/**',
    ],
  },
];
