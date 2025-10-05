import { STORAGE_KEYS } from '../config/constants';

/**
 * Type-safe LocalStorage Wrapper
 */

export const storage = {
  /**
   * Get item from localStorage
   */
  get<T>(key: keyof typeof STORAGE_KEYS): T | null {
    try {
      const item = localStorage.getItem(STORAGE_KEYS[key]);
      return item ? JSON.parse(item) : null;
    } catch (error) {
      console.error(`Error reading from localStorage (${key}):`, error);
      return null;
    }
  },

  /**
   * Set item in localStorage
   */
  set<T>(key: keyof typeof STORAGE_KEYS, value: T): void {
    try {
      localStorage.setItem(STORAGE_KEYS[key], JSON.stringify(value));
    } catch (error) {
      console.error(`Error writing to localStorage (${key}):`, error);
    }
  },

  /**
   * Remove item from localStorage
   */
  remove(key: keyof typeof STORAGE_KEYS): void {
    try {
      localStorage.removeItem(STORAGE_KEYS[key]);
    } catch (error) {
      console.error(`Error removing from localStorage (${key}):`, error);
    }
  },

  /**
   * Clear all app data from localStorage
   */
  clear(): void {
    try {
      Object.values(STORAGE_KEYS).forEach((key) => {
        localStorage.removeItem(key);
      });
    } catch (error) {
      console.error('Error clearing localStorage:', error);
    }
  },

  /**
   * Check if key exists
   */
  has(key: keyof typeof STORAGE_KEYS): boolean {
    return localStorage.getItem(STORAGE_KEYS[key]) !== null;
  },
};

/**
 * SessionStorage Wrapper (same interface as storage)
 */
export const sessionStorage = {
  get<T>(key: string): T | null {
    try {
      const item = window.sessionStorage.getItem(key);
      return item ? JSON.parse(item) : null;
    } catch (error) {
      console.error(`Error reading from sessionStorage (${key}):`, error);
      return null;
    }
  },

  set<T>(key: string, value: T): void {
    try {
      window.sessionStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error writing to sessionStorage (${key}):`, error);
    }
  },

  remove(key: string): void {
    try {
      window.sessionStorage.removeItem(key);
    } catch (error) {
      console.error(`Error removing from sessionStorage (${key}):`, error);
    }
  },

  clear(): void {
    try {
      window.sessionStorage.clear();
    } catch (error) {
      console.error('Error clearing sessionStorage:', error);
    }
  },
};