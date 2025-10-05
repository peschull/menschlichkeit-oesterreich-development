/**
 * Central Type Definitions für Menschlichkeit Österreich
 */

// ============================================
// User & Authentication
// ============================================

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'moderator' | 'admin';
  avatar?: string;
  createdAt: Date;
  lastLogin?: Date;
}

export interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  token?: string;
}

// ============================================
// Modal System
// ============================================

export type ModalType =
  | 'auth'
  | 'profile'
  | 'security'
  | 'privacy'
  | 'donate'
  | 'join';

export type AuthMode = 'login' | 'register' | 'reset';

export interface ModalState {
  type: ModalType | null;
  authMode?: AuthMode;
  data?: any;
}

// ============================================
// App State
// ============================================

export interface AppState {
  isAuthenticated: boolean;
  user: User | null;
  modal: ModalState;
  notifications: Notification[];
  theme: 'light' | 'dark' | 'system';
}

// ============================================
// Notifications
// ============================================

export interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error' | 'achievement' | 'social';
  title: string;
  message: string;
  timestamp: Date;
  read: boolean;
  actionUrl?: string;
  icon?: any;
}

// ============================================
// Democracy Game
// ============================================

export interface Stakeholder {
  id: string;
  name: string;
  icon: string;
  description: string;
  interests: string[];
  power: number;
  influence: number;
}

export interface Choice {
  id: string;
  text: string;
  description?: string;
  impacts: {
    stakeholderId: string;
    value: number;
    reason: string;
  }[];
  consequences?: string;
  skillsRequired?: string[];
  difficulty?: 'easy' | 'medium' | 'hard';
}

export interface Scenario {
  id: string;
  title: string;
  description: string;
  context: string;
  stakeholders: Stakeholder[];
  choices: Choice[];
  correctChoiceId?: string;
  learningGoals: string[];
  difficulty: 'easy' | 'medium' | 'hard';
}

export interface GameProgress {
  scenarioId: string;
  completed: boolean;
  score: number;
  choicesMade: string[];
  timeSpent: number;
  skillsEarned: string[];
}

export interface Skill {
  id: string;
  name: string;
  description: string;
  category: 'dialog' | 'empathy' | 'critical-thinking' | 'democracy-knowledge';
  level: number;
  maxLevel: number;
  progress: number;
  unlocked: boolean;
  icon: string;
}

export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: 'beginner' | 'skills' | 'social' | 'challenge' | 'special';
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  unlocked: boolean;
  progress?: number;
  maxProgress?: number;
  unlockedAt?: Date;
}

// ============================================
// Forum
// ============================================

export interface ForumBoard {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: string;
  threadCount: number;
  postCount: number;
}

export interface ForumThread {
  id: string;
  boardId: string;
  title: string;
  content: string;
  author: User;
  createdAt: Date;
  lastActivity: Date;
  views: number;
  replies: number;
  isPinned: boolean;
  isLocked: boolean;
  tags: string[];
}

export interface ForumPost {
  id: string;
  threadId: string;
  content: string;
  author: User;
  createdAt: Date;
  editedAt?: Date;
  reactions: {
    type: string;
    count: number;
    users: string[];
  }[];
}

// ============================================
// Events
// ============================================

export interface Event {
  id: string;
  title: string;
  description: string;
  date: Date;
  endDate?: Date;
  location: string;
  type: 'workshop' | 'demo' | 'meeting' | 'webinar' | 'other';
  organizer: string;
  maxParticipants?: number;
  currentParticipants: number;
  registrationDeadline?: Date;
  image?: string;
  tags: string[];
  rsvpList?: string[];
}

// ============================================
// News
// ============================================

export interface NewsArticle {
  id: string;
  title: string;
  excerpt: string;
  content: string;
  author: User;
  publishedAt: Date;
  updatedAt?: Date;
  category: string;
  tags: string[];
  image?: string;
  featured: boolean;
  views: number;
}

// ============================================
// Donations
// ============================================

export interface Donation {
  id: string;
  amount: number;
  currency: 'EUR';
  donorName?: string;
  donorEmail: string;
  message?: string;
  createdAt: Date;
  status: 'pending' | 'completed' | 'failed';
  paymentMethod: 'sepa' | 'credit-card' | 'paypal';
  recurring?: boolean;
  frequency?: 'monthly' | 'quarterly' | 'yearly';
}

// ============================================
// Membership
// ============================================

export interface Membership {
  id: string;
  userId: string;
  type: 'basic' | 'premium' | 'supporter' | 'lifetime';
  startDate: Date;
  endDate?: Date;
  status: 'active' | 'expired' | 'cancelled';
  autoRenew: boolean;
  benefits: string[];
}

// ============================================
// Analytics
// ============================================

export interface AnalyticsEvent {
  name: string;
  category: string;
  label?: string;
  value?: number;
  timestamp: Date;
  userId?: string;
}

export interface PageView {
  path: string;
  title: string;
  timestamp: Date;
  referrer?: string;
  userId?: string;
}

// ============================================
// API Response Types
// ============================================

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  meta?: {
    page?: number;
    pageSize?: number;
    total?: number;
  };
}

export interface PaginationParams {
  page: number;
  pageSize: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

// ============================================
// Component Props Types
// ============================================

export interface BaseComponentProps {
  className?: string;
  children?: React.ReactNode;
}

export interface WithLoadingProps extends BaseComponentProps {
  isLoading?: boolean;
  loadingText?: string;
}

export interface WithErrorProps extends BaseComponentProps {
  error?: Error | string | null;
  onRetry?: () => void;
}

// ============================================
// Utility Types
// ============================================

export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// ============================================
// Constants
// ============================================

export const USER_ROLES = ['user', 'moderator', 'admin'] as const;
export const NOTIFICATION_TYPES = ['info', 'success', 'warning', 'error', 'achievement', 'social'] as const;
export const EVENT_TYPES = ['workshop', 'demo', 'meeting', 'webinar', 'other'] as const;
