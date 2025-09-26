# TS/TSX Style - Menschlichkeit Österreich

## TypeScript Best Practices

- **Strikte Typen:** `noImplicitAny: true`, keine `any` ohne Begründung
- **Public API:** Präzise Types/Interfaces, generics statt union inflation
- **Type Guards:** Verwende Type Guards für Runtime-Validierung
- **Utility Types:** Nutze `Pick`, `Omit`, `Partial` für Type Transformations
- **Const Assertions:** `as const` für Literal Types und ReadOnly Arrays

## React TypeScript Patterns

- **Components:** `React.FC<Props>` oder direkte Function Typing
- **Props:** Interface statt Type für Props (bessere Extension)
- **Hooks:** Typisiere Custom Hooks vollständig
- **Events:** Verwende `React.FormEvent`, `React.MouseEvent` etc.
- **Refs:** `useRef<HTMLElement | null>(null)` Pattern

```typescript
// ✅ Gut: Vollständig typisierte Component
interface MemberCardProps {
  member: Member;
  onEdit: (memberId: string) => void;
  showSensitiveData?: boolean;
}

export const MemberCard: React.FC<MemberCardProps> = ({
  member,
  onEdit,
  showSensitiveData = false,
}) => {
  // Implementation
};
```

## Domain-Specific Types

```typescript
// Mitgliederdaten-Typen
interface Member {
  readonly id: MemberId;
  personalData: PersonalData;
  membership: MembershipInfo;
  privacy: PrivacySettings;
  readonly createdAt: Date;
  updatedAt: Date;
}

type MemberId = string & { readonly brand: 'MemberId' };
type IBAN = string & { readonly brand: 'IBAN' };
type Email = string & { readonly brand: 'Email' };

// SEPA-Management Types
interface SepaMandate {
  readonly id: MandateId;
  reference: MandateReference;
  creditorId: CreditorId;
  debtorInfo: DebtorInfo;
  bankDetails: BankDetails;
  status: MandateStatus;
  readonly createdAt: Date;
}

type MandateStatus = 'pending' | 'signed' | 'active' | 'cancelled' | 'expired';

// DSGVO Types
interface ConsentRecord {
  readonly id: ConsentId;
  userId: MemberId;
  category: ConsentCategory;
  isGiven: boolean;
  givenAt?: Date;
  revokedAt?: Date;
  readonly version: ConsentVersion;
}

type ConsentCategory =
  | 'essential'
  | 'analytics'
  | 'marketing'
  | 'personalization';
```

## Error Handling & Validation

```typescript
// Result Pattern für Fehlerbehandlung
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// Validation mit Branded Types
const validateIBAN = (iban: string): Result<IBAN, ValidationError> => {
  // IBAN Validierung
  if (isValidIBAN(iban)) {
    return { success: true, data: iban as IBAN };
  }
  return { success: false, error: new ValidationError('Invalid IBAN format') };
};

// Custom Error Types
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string,
    public readonly code: string
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}

class DsgvoComplianceError extends Error {
  constructor(
    message: string,
    public readonly violationType: 'consent' | 'retention' | 'purpose'
  ) {
    super(message);
    this.name = 'DsgvoComplianceError';
  }
}
```

## State Management Patterns

```typescript
// Zustand mit Discriminated Unions
type AuthState =
  | { status: 'unauthenticated' }
  | { status: 'loading' }
  | { status: 'authenticated'; user: User; token: AuthToken }
  | { status: 'error'; error: AuthError };

// Context mit Reducer Pattern
interface AppState {
  auth: AuthState;
  members: Member[];
  sepaProcessing: SepaProcessingState;
  privacy: PrivacyState;
}

type AppAction =
  | { type: 'AUTH_SUCCESS'; payload: { user: User; token: AuthToken } }
  | { type: 'MEMBER_UPDATED'; payload: { member: Member } }
  | { type: 'SEPA_MANDATE_CREATED'; payload: { mandate: SepaMandate } }
  | { type: 'CONSENT_UPDATED'; payload: { consent: ConsentRecord } };
```

## API Integration Types

```typescript
// API Response Types
interface ApiResponse<T> {
  data: T;
  meta: {
    timestamp: string;
    requestId: string;
    version: string;
  };
}

interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: string;
}

// HTTP Client mit Typen
const api = {
  members: {
    list: (): Promise<ApiResponse<Member[]>> => fetch('/api/members'),
    get: (id: MemberId): Promise<ApiResponse<Member>> =>
      fetch(`/api/members/${id}`),
    update: (member: Partial<Member>): Promise<ApiResponse<Member>> =>
      fetch(`/api/members/${member.id}`, {
        method: 'PUT',
        body: JSON.stringify(member),
      }),
  },
  sepa: {
    createMandate: (
      data: CreateMandateRequest
    ): Promise<ApiResponse<SepaMandate>> =>
      fetch('/api/sepa/mandates', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
  },
};
```

## Performance & Bundle Optimization

```typescript
// Lazy Loading mit Type Safety
const LazyMemberDashboard = React.lazy(() =>
  import('./MemberDashboard').then(module => ({
    default: module.MemberDashboard,
  }))
);

// Code Splitting für große Types
type MembershipAnalytics = import('./types/analytics').MembershipAnalytics;

// Tree-shakeable Utility Functions
export const memberUtils = {
  formatDisplayName: (member: Pick<Member, 'personalData'>): string =>
    `${member.personalData.firstName} ${member.personalData.lastName}`,

  calculateMembershipDuration: (member: Pick<Member, 'membership'>): number =>
    new Date().getFullYear() - member.membership.joinDate.getFullYear(),
} as const;
```
