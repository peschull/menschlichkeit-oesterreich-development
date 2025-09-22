module.exports = {
  root: true,
  env: {
    browser: true,
    es2022: true,
    node: true,
    jest: true
  },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'prettier'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: ['./tsconfig.json', './mcp-servers/*/tsconfig.json', './servers/src/*/tsconfig.json']
  },
  plugins: [
    '@typescript-eslint',
    'import',
    'node'
  ],
  rules: {
    // TypeScript specific
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-non-null-assertion': 'warn',
    
    // Import rules
    'import/order': ['error', {
      'groups': ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
      'newlines-between': 'always',
      'alphabetize': { order: 'asc', caseInsensitive: true }
    }],
    
    // General rules
    'no-console': 'off', // Allow console.log for MCP servers
    'no-debugger': 'error',
    'no-duplicate-imports': 'error',
    'no-unused-expressions': 'error',
    'prefer-const': 'error',
    'no-var': 'error',
    
    // Node.js specific
    'node/prefer-global/process': 'error',
    'node/prefer-global/buffer': 'error',
    'node/prefer-global/console': 'error'
  },
  overrides: [
    {
      // MCP Server specific rules
      files: ['**/mcp-servers/**/*.ts', '**/servers/**/*.ts'],
      rules: {
        'no-console': 'off', // MCP servers need console logging
        '@typescript-eslint/no-unused-vars': ['error', { 
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_' 
        }]
      }
    },
    {
      // Test files
      files: ['**/*.test.ts', '**/*.spec.ts', '**/tests/**/*.ts'],
      env: {
        jest: true
      },
      rules: {
        '@typescript-eslint/no-explicit-any': 'off'
      }
    },
    {
      // JavaScript files
      files: ['**/*.js'],
      rules: {
        '@typescript-eslint/no-var-requires': 'off'
      }
    }
  ],
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    '*.min.js',
    'menschlichkeit-oesterreich-monorepo/',
    'wp-content/',
    'vendor/'
  ]
};