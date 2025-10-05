
const tokens = require('../figma-design-system/00_design-tokens.json');

const tt = tokens.designTokens;

const fontFamily = {
  ...tt.typography.fontFamily,
  sans: tt.typography.fontFamily.primary,
  serif: tt.typography.fontFamily.secondary,
  mono: tt.typography.fontFamily.mono,
};

module.exports = {
  darkMode: ['class', '[data-theme="dark"]'],
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  safelist: [
    { pattern: /(bg|text|border)-(success|warning|error)-(50|100|200|300|400|500|600|700|800|900)/ },
    { pattern: /(bg|text|border)-(primary|secondary)-(50|100|200|300|400|500|600|700|800|900)/ },
  ],
  theme: {
    extend: {
      colors: tt.colors,
      fontFamily,
      fontSize: tt.typography.fontSize,
      fontWeight: tt.typography.fontWeight,
      lineHeight: tt.typography.lineHeight,
      letterSpacing: tt.typography.letterSpacing,
      spacing: tt.spacing,
      borderRadius: tt.borderRadius,
      boxShadow: tt.shadows,
      screens: tt.breakpoints,
      // Optional: zusätzliche Utilities/Animationen
      backgroundImage: {
        'brand-gradient': 'var(--brand-gradient)',
        'hero-pattern': 'radial-gradient(circle at 1px 1px, rgba(255,255,255,0.15) 1px, transparent 0)',
        glass: 'linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0))',
      },
      backdropBlur: {
        xs: '2px',
        sm: '4px',
        md: '8px',
        lg: '12px',
        xl: '16px',
        '2xl': '24px',
        '3xl': '40px',
      },
      keyframes: {
        fadeIn: {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        slideUp: {
          from: { opacity: '0', transform: 'translateY(30px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        scaleIn: {
          from: { opacity: '0', transform: 'scale(0.95)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        'pulse-slow': {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '0.5' },
        },
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.6s ease-out',
        'scale-in': 'scaleIn 0.4s ease-out',
        'pulse-slow': 'pulse-slow 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        wiggle: 'wiggle 1s ease-in-out infinite',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
