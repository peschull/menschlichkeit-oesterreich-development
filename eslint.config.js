import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    files: ["**/*.{js,mjs,cjs}"],
    ignores: [
      "node_modules/**",
      "**/dist/**", 
      "**/build/**",
      "**/*.min.js",
      "**/*.d.ts",
      // Ignore TypeScript files until @typescript-eslint is configured
      "**/*.ts",
      "**/*.tsx"
    ],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: { ...globals.browser, ...globals.node },
    },
    rules: {
      "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "no-console": "off",
    },
  },
];
