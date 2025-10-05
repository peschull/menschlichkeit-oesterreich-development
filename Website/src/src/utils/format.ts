import { format, formatDistance, formatRelative } from 'date-fns';
import { de } from 'date-fns/locale';
import { DATE_FORMATS } from '../config/constants';

/**
 * Formatting Utilities
 */

// ============================================
// Date & Time
// ============================================

export const formatDate = {
  /**
   * Format date to short format (dd.MM.yyyy)
   */
  short: (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return format(d, DATE_FORMATS.SHORT, { locale: de });
  },

  /**
   * Format date to long format (dd. MMMM yyyy)
   */
  long: (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return format(d, DATE_FORMATS.LONG, { locale: de });
  },

  /**
   * Format date with time (dd.MM.yyyy HH:mm)
   */
  withTime: (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return format(d, DATE_FORMATS.WITH_TIME, { locale: de });
  },

  /**
   * Format time only (HH:mm)
   */
  timeOnly: (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return format(d, DATE_FORMATS.TIME_ONLY, { locale: de });
  },

  /**
   * Format relative time ("vor 2 Stunden", "in 3 Tagen")
   */
  relative: (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return formatRelative(d, new Date(), { locale: de });
  },

  /**
   * Format distance ("vor 2 Stunden", "in 3 Tagen")
   */
  distance: (date: Date | string, addSuffix = true): string => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return formatDistance(d, new Date(), { addSuffix, locale: de });
  },
};

// ============================================
// Numbers & Currency
// ============================================

export const formatNumber = {
  /**
   * Format number with thousand separators
   */
  default: (value: number): string => {
    return new Intl.NumberFormat('de-AT').format(value);
  },

  /**
   * Format as currency (EUR)
   */
  currency: (value: number, currency = 'EUR'): string => {
    return new Intl.NumberFormat('de-AT', {
      style: 'currency',
      currency,
    }).format(value);
  },

  /**
   * Format as percentage
   */
  percentage: (value: number, decimals = 0): string => {
    return new Intl.NumberFormat('de-AT', {
      style: 'percent',
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals,
    }).format(value);
  },

  /**
   * Format as compact number (1.2K, 3.5M)
   */
  compact: (value: number): string => {
    return new Intl.NumberFormat('de-AT', {
      notation: 'compact',
      compactDisplay: 'short',
    }).format(value);
  },

  /**
   * Format file size (Bytes, KB, MB, GB)
   */
  fileSize: (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  },
};

// ============================================
// String Utilities
// ============================================

export const formatString = {
  /**
   * Truncate string to max length with ellipsis
   */
  truncate: (str: string, maxLength: number): string => {
    if (str.length <= maxLength) return str;
    return str.slice(0, maxLength - 3) + '...';
  },

  /**
   * Capitalize first letter
   */
  capitalize: (str: string): string => {
    return str.charAt(0).toUpperCase() + str.slice(1);
  },

  /**
   * Convert to title case
   */
  titleCase: (str: string): string => {
    return str.replace(/\w\S*/g, (txt) => {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  },

  /**
   * Convert to slug (URL-friendly)
   */
  slug: (str: string): string => {
    return str
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
  },

  /**
   * Extract initials from name
   */
  initials: (name: string): string => {
    return name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  },
};

// ============================================
// Time Duration
// ============================================

export const formatDuration = {
  /**
   * Format milliseconds to readable duration
   */
  fromMs: (ms: number): string => {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    }
    if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    }
    return `${seconds}s`;
  },

  /**
   * Format seconds to readable duration
   */
  fromSeconds: (seconds: number): string => {
    return formatDuration.fromMs(seconds * 1000);
  },
};

// ============================================
// List Formatting
// ============================================

export const formatList = {
  /**
   * Format array as comma-separated list with "und" before last item
   */
  conjunction: (items: string[]): string => {
    if (items.length === 0) return '';
    if (items.length === 1) return items[0];
    if (items.length === 2) return items.join(' und ');
    
    return items.slice(0, -1).join(', ') + ' und ' + items[items.length - 1];
  },

  /**
   * Format array as comma-separated list with "oder" before last item
   */
  disjunction: (items: string[]): string => {
    if (items.length === 0) return '';
    if (items.length === 1) return items[0];
    if (items.length === 2) return items.join(' oder ');
    
    return items.slice(0, -1).join(', ') + ' oder ' + items[items.length - 1];
  },
};

// ============================================
// Validation Helpers
// ============================================

export const format = {
  /**
   * Validate and format email
   */
  email: (email: string): string => {
    return email.toLowerCase().trim();
  },

  /**
   * Format phone number (Austrian format)
   */
  phone: (phone: string): string => {
    const cleaned = phone.replace(/\D/g, '');
    const match = cleaned.match(/^(\d{1,4})(\d{3})(\d{4})$/);
    
    if (match) {
      return `+${match[1]} ${match[2]} ${match[3]}`;
    }
    
    return phone;
  },

  /**
   * Format IBAN (with spaces every 4 characters)
   */
  iban: (iban: string): string => {
    const cleaned = iban.replace(/\s/g, '').toUpperCase();
    return cleaned.match(/.{1,4}/g)?.join(' ') || iban;
  },
};