// CRM API Integration für Website
// Hauptklasse für alle CiviCRM API-Aufrufe

class CRMApi {
    constructor() {
        this.baseUrl = 'https://api.menschlichkeit-oesterreich.at';
        this.token = null;
        this.refreshToken = null;
        this.init();
    }

    init() {
        // JWT Token laden (Session bevorzugt, Fallback Local)
        this.token = localStorage.getItem('jwt_token');
        const sessionToken = sessionStorage.getItem('jwt_token');
        if (sessionToken) {
            this.token = sessionToken;
        }
        // Refresh Token laden
        this.refreshToken = localStorage.getItem('refresh_token');
        const sessionRefresh = sessionStorage.getItem('refresh_token');
        if (sessionRefresh) {
            this.refreshToken = sessionRefresh;
        }
        // Token-Gültigkeit prüfen
        if (this.token && this.isTokenExpired(this.token)) {
            this.logout();
        }
    }

    isTokenExpired(token) {
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            return payload.exp < Date.now() / 1000;
        } catch (error) {
            return true;
        }
    }

    async refreshAuthToken() {
        if (!this.refreshToken) return false;
        try {
            const res = await fetch(`${this.baseUrl}/auth/refresh`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ refresh_token: this.refreshToken })
            });
            const data = await res.json().catch(() => ({}));
            if (!res.ok || !data?.success || !data?.data?.token) {
                this.logout();
                return false;
            }
            this._storeTokens(data.data);
            return true;
        } catch (e) {
            console.error('refresh token failed', e);
            this.logout();
            return false;
        }
    }

    async apiRequest(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
                ...(this.token && { 'Authorization': `Bearer ${this.token}` })
            }
        };

        const requestOptions = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...options.headers
            }
        };

        try {
            let response = await fetch(url, requestOptions);
            if (response.status === 401 && this.token && this.refreshToken) {
                const refreshed = await this.refreshAuthToken();
                if (refreshed) {
                    // retry once with updated token
                    requestOptions.headers['Authorization'] = `Bearer ${this.token}`;
                    response = await fetch(url, requestOptions);
                }
            }
            return response;
        } catch (error) {
            console.error('API request error:', error);
            throw error;
        }
    }

    // Authentication
    async login(email, password) {
        try {
            const response = await this.apiRequest('/auth/login', {
                method: 'POST',
                body: JSON.stringify({ email, password })
            });

            const data = await response.json().catch(() => ({}));
            // Erwartete Struktur: { success, data: { token, refresh_token?, expires_in }, message }
            if (response.ok && data && data.success && data.data && data.data.token) {
                this._storeTokens(data.data);
                return { success: true, data };
            } else {
                const msg = (data && (data.detail || data.message)) || 'Login fehlgeschlagen';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Login error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async register(userData) {
        // Nutzt Backend /auth/register
        try {
            const response = await this.apiRequest('/auth/register', {
                method: 'POST',
                body: JSON.stringify(userData)
            });
            const data = await response.json().catch(() => ({}));
            if (response.ok && data && data.success) {
                return { success: true, data };
            } else {
                const msg = (data && (data.detail || data.message)) || 'Registrierung fehlgeschlagen';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Registration error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    logout() {
        this.token = null;
        try { sessionStorage.removeItem('jwt_token'); } catch {}
        try { sessionStorage.removeItem('refresh_token'); } catch {}
        localStorage.removeItem('jwt_token');
        localStorage.removeItem('refresh_token');
        localStorage.removeItem('user_data');
        
        // Redirect to login if on protected page
        if (window.location.pathname.includes('member-area')) {
            window.location.href = 'login.html';
        }
    }

    // Contact Management
    async createContact(contactData) {
        try {
            const response = await this.apiRequest('/contacts/create', {
                method: 'POST',
                body: JSON.stringify(contactData)
            });
            const data = await response.json().catch(() => ({}));
            if (response.ok && data && data.success) {
                return { success: true, data };
            } else {
                const msg = (data && (data.detail || data.message)) || 'Kontakt konnte nicht erstellt werden';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Create contact error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    _storeTokens(tokenData) {
        this.token = tokenData.token;
        this.refreshToken = tokenData.refresh_token || this.refreshToken || null;
        // Session speichern
        try { sessionStorage.setItem('jwt_token', this.token); } catch {}
        if (this.refreshToken) {
            try { sessionStorage.setItem('refresh_token', this.refreshToken); } catch {}
        }
        // Optional persistent
        const remember = localStorage.getItem('remember_me') === 'true';
        if (remember) {
            localStorage.setItem('jwt_token', this.token);
            if (this.refreshToken) localStorage.setItem('refresh_token', this.refreshToken);
        } else {
            localStorage.removeItem('jwt_token');
            localStorage.removeItem('refresh_token');
        }
    }

    async getContact(contactId) {
        try {
            const response = await this.apiRequest(`/contacts/${contactId}`);

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'Kontakt nicht gefunden' };
            }
        } catch (error) {
            console.error('Get contact error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async updateContact(contactId, contactData) {
        try {
            const response = await this.apiRequest(`/contacts/${contactId}`, {
                method: 'PUT',
                body: JSON.stringify(contactData)
            });

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'Kontakt konnte nicht aktualisiert werden' };
            }
        } catch (error) {
            console.error('Update contact error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    // Membership Management
    async createMembership(membershipData) {
        try {
            const response = await this.apiRequest('/memberships/create', {
                method: 'POST',
                body: JSON.stringify(membershipData)
            });
            const data = await response.json().catch(() => ({}));
            if (response.ok && data && data.success) {
                return { success: true, data };
            } else {
                const msg = (data && (data.detail || data.message)) || 'Mitgliedschaft konnte nicht erstellt werden';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Create membership error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async getMembership(contactId) {
        try {
            const response = await this.apiRequest(`/memberships/contact/${contactId}`);

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'Mitgliedschaft nicht gefunden' };
            }
        } catch (error) {
            console.error('Get membership error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async updateMembership(membershipId, membershipData) {
        try {
            const response = await this.apiRequest(`/memberships/${membershipId}`, {
                method: 'PUT',
                body: JSON.stringify(membershipData)
            });

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'Mitgliedschaft konnte nicht aktualisiert werden' };
            }
        } catch (error) {
            console.error('Update membership error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    // User Profile
    async getUserProfile() {
        try {
            const response = await this.apiRequest('/user/profile');
            const json = await response.json().catch(() => ({}));
            if (response.ok && json && json.success) {
                const profile = json.data || {};
                try { localStorage.setItem('user_data', JSON.stringify(profile)); } catch {}
                return { success: true, data: profile };
            } else {
                const msg = (json && (json.detail || json.message)) || 'Profil konnte nicht geladen werden';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Get user profile error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async updateUserProfile(profileData) {
        try {
            const response = await this.apiRequest('/user/profile', {
                method: 'PUT',
                body: JSON.stringify(profileData)
            });
            const json = await response.json().catch(() => ({}));
            if (response.ok && json && json.success) {
                const profile = json.data || {};
                try { localStorage.setItem('user_data', JSON.stringify(profile)); } catch {}
                return { success: true, data: profile };
            } else {
                const msg = (json && (json.detail || json.message)) || 'Profil konnte nicht aktualisiert werden';
                return { success: false, error: msg };
            }
        } catch (error) {
            console.error('Update user profile error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    // SEPA Direct Debit
    async createSepaMandate(mandateData) {
        try {
            const response = await this.apiRequest('/sepa/mandate', {
                method: 'POST',
                body: JSON.stringify(mandateData)
            });

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'SEPA-Mandat konnte nicht erstellt werden' };
            }
        } catch (error) {
            console.error('Create SEPA mandate error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    async getSepaMandate(contactId) {
        try {
            const response = await this.apiRequest(`/sepa/mandate/${contactId}`);

            if (response.ok) {
                const data = await response.json();
                return { success: true, data };
            } else {
                const error = await response.json();
                return { success: false, error: error.detail || 'SEPA-Mandat nicht gefunden' };
            }
        } catch (error) {
            console.error('Get SEPA mandate error:', error);
            return { success: false, error: 'Verbindungsfehler' };
        }
    }

    // Health Check
    async healthCheck() {
        try {
            const response = await this.apiRequest('/health');
            if (!response.ok) return false;
            const data = await response.json().catch(() => ({}));
            return !!(data && data.status === 'healthy');
        } catch (error) {
            console.error('Health check error:', error);
            return false;
        }
    }

    // Helper Methods
    isLoggedIn() {
        return this.token && !this.isTokenExpired(this.token);
    }

    getUserData() {
        const userData = localStorage.getItem('user_data');
        return userData ? JSON.parse(userData) : null;
    }

    // Event Emitter für UI Updates
    emitEvent(eventName, data) {
        const event = new CustomEvent(eventName, { detail: data });
        document.dispatchEvent(event);
    }
}

// Global CRM API Instance
const crmApi = new CRMApi();

// Make it available globally
window.crmApi = crmApi;

// Export for modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CRMApi;
}
