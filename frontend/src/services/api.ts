import { http } from './http';

export interface HealthResponse {
  status: string;
  service: string;
  version: string;
}

const baseApi = {
  health: () => http.get<HealthResponse>('/health'),
  login: (email: string, password: string) =>
    http.post<LoginResponse>('/auth/login', { email, password }),
};

// Generic API response shape from backend
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
}

export interface LoginResponse extends ApiResponse<{ token: string; expires_in: number }> {}

export interface CreateContactRequest {
  email: string;
  first_name?: string | null;
  last_name?: string | null;
}

export interface CreateMembershipRequest {
  contact_id: number;
  membership_type_id?: number;
  start_date?: string | null;
  end_date?: string | null;
}

export const apiPaths = {
  contacts: {
    create: '/contacts/create',
    search: '/contacts/search',
  },
  memberships: {
    create: '/memberships/create',
  },
} as const;

export const api = {
  ...baseApi,
  contacts: {
    create: (payload: CreateContactRequest, token: string) =>
      http.post<ApiResponse>(apiPaths.contacts.create, payload, { token }),
    search: (email: string | undefined, token: string) =>
      http.get<ApiResponse>(`${apiPaths.contacts.search}${email ? `?email=${encodeURIComponent(email)}` : ''}`, { token }),
  },
  memberships: {
    create: (payload: CreateMembershipRequest, token: string) =>
      http.post<ApiResponse>(apiPaths.memberships.create, payload, { token }),
  },
};
