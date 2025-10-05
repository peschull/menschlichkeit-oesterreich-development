/**
 * Application Constants
 * Zentralisierte Konfiguration für die gesamte Anwendung
 */

// ============================================
// Application Info
// ============================================

export const APP_NAME = 'Verein Menschlichkeit Österreich';
export const APP_SHORT_NAME = 'Menschlichkeit AT';
export const APP_VERSION = '4.1.0';
export const APP_DESCRIPTION = 'Gemeinnütziger Verein für soziale Gerechtigkeit, Menschenrechte und demokratische Bildung in Österreich';

// ============================================
// URLs & Paths
// ============================================

export const SITE_URL = 'https://menschlichkeit-oesterreich.at';
export const API_URL = process.env.VITE_API_URL || '/api';
export const SUPABASE_URL = process.env.VITE_SUPABASE_URL || '';
export const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY || '';

// ============================================
// Contact Information
// ============================================

export const CONTACT_EMAIL = 'kontakt@menschlichkeit-oesterreich.at';
export const SUPPORT_EMAIL = 'support@menschlichkeit-oesterreich.at';
export const CONTACT_PHONE = '+43-1-234-5678';

export const SOCIAL_LINKS = {
  facebook: 'https://facebook.com/menschlichkeit.oesterreich',
  twitter: 'https://twitter.com/menschlichkeit_at',
  instagram: 'https://instagram.com/menschlichkeit.oesterreich',
  linkedin: 'https://linkedin.com/company/menschlichkeit-oesterreich',
  youtube: 'https://youtube.com/menschlichkeit-oesterreich',
} as const;

// ============================================
// Theme & Design
// ============================================

export const BRAND_COLORS = {
  orange: '#ff6b35',
  red: '#e63946',
  blue: '#0d6efd',
  austriaRed: '#c8102e',
  austriaWhite: '#ffffff',
} as const;

export const THEME_OPTIONS = ['light', 'dark', 'system'] as const;
export type Theme = typeof THEME_OPTIONS[number];

// ============================================
// Pagination
// ============================================

export const DEFAULT_PAGE_SIZE = 20;
export const PAGE_SIZE_OPTIONS = [10, 20, 50, 100] as const;

// ============================================
// Performance
// ============================================

export const PREFETCH_DELAY_MS = 1000;
export const DEBOUNCE_DELAY_MS = 300;
export const SCROLL_THROTTLE_MS = 100;

// ============================================
// Local Storage Keys
// ============================================

export const STORAGE_KEYS = {
  AUTH_TOKEN: 'menschlichkeit_auth_token',
  USER_DATA: 'menschlichkeit_user_data',
  THEME: 'menschlichkeit_theme',
  COOKIE_CONSENT: 'menschlichkeit_cookie_consent',
  GAME_PROGRESS: 'menschlichkeit_game_progress',
  ACHIEVEMENTS: 'menschlichkeit_achievements',
  SKILLS: 'menschlichkeit_skills',
} as const;

// ============================================
// Form Validation
// ============================================

export const VALIDATION_RULES = {
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PASSWORD_MIN_LENGTH: 8,
  USERNAME_MIN_LENGTH: 3,
  USERNAME_MAX_LENGTH: 30,
  MESSAGE_MAX_LENGTH: 5000,
} as const;

// ============================================
// Democracy Game
// ============================================

export const GAME_CONFIG = {
  SCENARIOS_COUNT: 8,
  METAVERSE_LEVELS: 100,
  METAVERSE_CHAPTERS: 10,
  SKILLS_COUNT: 12,
  ACHIEVEMENTS_COUNT: 20,
  MAX_SKILL_LEVEL: 5,
  MULTIPLAYER_MAX_PLAYERS: 30,
} as const;

export const SKILL_CATEGORIES = [
  'dialog',
  'empathy',
  'critical-thinking',
  'democracy-knowledge',
] as const;

export const ACHIEVEMENT_RARITIES = [
  'common',
  'rare',
  'epic',
  'legendary',
] as const;

// ============================================
// Forum
// ============================================

export const FORUM_CONFIG = {
  MAX_THREAD_TITLE_LENGTH: 200,
  MAX_POST_LENGTH: 10000,
  THREADS_PER_PAGE: 20,
  POSTS_PER_PAGE: 10,
  MAX_TAGS_PER_THREAD: 5,
} as const;

// ============================================
// Events
// ============================================

export const EVENT_TYPES = [
  'workshop',
  'demo',
  'meeting',
  'webinar',
  'other',
] as const;

export const EVENT_CONFIG = {
  MAX_PARTICIPANTS_DEFAULT: 100,
  REGISTRATION_BUFFER_DAYS: 7,
} as const;

// ============================================
// Donations
// ============================================

export const DONATION_CONFIG = {
  CURRENCY: 'EUR',
  MIN_AMOUNT: 5,
  MAX_AMOUNT: 10000,
  SUGGESTED_AMOUNTS: [10, 25, 50, 100, 250],
  PAYMENT_METHODS: ['sepa', 'credit-card', 'paypal'] as const,
  FREQUENCIES: ['monthly', 'quarterly', 'yearly'] as const,
} as const;

// ============================================
// Membership
// ============================================

export const MEMBERSHIP_TYPES = {
  basic: {
    name: 'Basis',
    price: 0,
    benefits: ['Community-Zugang', 'Newsletter'],
  },
  premium: {
    name: 'Premium',
    price: 50,
    benefits: ['Alle Basis-Benefits', 'Event-Rabatte', 'Exklusiver Content'],
  },
  supporter: {
    name: 'Unterstützer',
    price: 150,
    benefits: ['Alle Premium-Benefits', 'Persönlicher Support', 'Jahresbericht'],
  },
  lifetime: {
    name: 'Lifetime',
    price: 500,
    benefits: ['Alle Benefits', 'Lebenslanger Zugang', 'VIP-Status'],
  },
} as const;

// ============================================
// File Upload
// ============================================

export const UPLOAD_CONFIG = {
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
  ALLOWED_DOCUMENT_TYPES: ['application/pdf', 'application/msword'],
} as const;

// ============================================
// Rate Limiting
// ============================================

export const RATE_LIMITS = {
  LOGIN_ATTEMPTS: 5,
  LOGIN_COOLDOWN_MS: 15 * 60 * 1000, // 15 minutes
  API_REQUESTS_PER_MINUTE: 60,
  FORUM_POSTS_PER_HOUR: 20,
} as const;

// ============================================
// Feature Flags
// ============================================

export const FEATURES = {
  ENABLE_ANALYTICS: true,
  ENABLE_MULTIPLAYER: true,
  ENABLE_PWA: true,
  ENABLE_NOTIFICATIONS: true,
  ENABLE_DARK_MODE: true,
  ENABLE_FORUM: true,
  ENABLE_EVENTS: true,
  ENABLE_DONATIONS: true,
  ENABLE_ADMIN_DASHBOARD: true,
} as const;

// ============================================
// SEO
// ============================================

export const SEO_DEFAULT = {
  title: 'Verein Menschlichkeit Österreich - Soziale Gerechtigkeit & Demokratie',
  description: APP_DESCRIPTION,
  keywords: 'Menschenrechte, Demokratie, Österreich, NGO, soziale Gerechtigkeit, politische Bildung, Brücken Bauen, Democracy Games, Verein',
  ogImage: `${SITE_URL}/logo-og.jpg`,
  twitterCard: 'summary_large_image',
} as const;

// ============================================
// Analytics
// ============================================

export const ANALYTICS_CONFIG = {
  GOOGLE_ANALYTICS_ID: process.env.VITE_GA_ID || '',
  PLAUSIBLE_DOMAIN: process.env.VITE_PLAUSIBLE_DOMAIN || '',
  TRACK_PAGE_VIEWS: true,
  TRACK_EVENTS: true,
  TRACK_PERFORMANCE: true,
} as const;

// ============================================
// Error Messages
// ============================================

export const ERROR_MESSAGES = {
  NETWORK_ERROR: 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung.',
  UNAUTHORIZED: 'Sie müssen angemeldet sein, um diese Aktion auszuführen.',
  FORBIDDEN: 'Sie haben keine Berechtigung für diese Aktion.',
  NOT_FOUND: 'Die angeforderte Ressource wurde nicht gefunden.',
  SERVER_ERROR: 'Ein Serverfehler ist aufgetreten. Bitte versuchen Sie es später erneut.',
  VALIDATION_ERROR: 'Bitte überprüfen Sie Ihre Eingaben.',
  GENERIC_ERROR: 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.',
} as const;

// ============================================
// Success Messages
// ============================================

export const SUCCESS_MESSAGES = {
  LOGIN_SUCCESS: 'Erfolgreich angemeldet!',
  LOGOUT_SUCCESS: 'Erfolgreich abgemeldet!',
  REGISTER_SUCCESS: 'Registrierung erfolgreich! Bitte bestätigen Sie Ihre E-Mail.',
  PROFILE_UPDATE_SUCCESS: 'Profil erfolgreich aktualisiert!',
  DONATION_SUCCESS: 'Vielen Dank für Ihre Spende!',
  MEMBERSHIP_SUCCESS: 'Willkommen als Mitglied!',
  FORM_SUBMIT_SUCCESS: 'Formular erfolgreich gesendet!',
} as const;

// ============================================
// Breakpoints (matching Tailwind)
// ============================================

export const BREAKPOINTS = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const;

// ============================================
// Time Formats
// ============================================

export const DATE_FORMATS = {
  SHORT: 'dd.MM.yyyy',
  LONG: 'dd. MMMM yyyy',
  WITH_TIME: 'dd.MM.yyyy HH:mm',
  TIME_ONLY: 'HH:mm',
  ISO: "yyyy-MM-dd'T'HH:mm:ss.SSSxxx",
} as const;

// ============================================
// Accessibility
// ============================================

export const A11Y_CONFIG = {
  MIN_TOUCH_TARGET_SIZE: 44, // pixels
  FOCUS_VISIBLE_OUTLINE: '2px solid var(--ring)',
  SKIP_LINK_TEXT: 'Zum Hauptinhalt springen',
} as const;