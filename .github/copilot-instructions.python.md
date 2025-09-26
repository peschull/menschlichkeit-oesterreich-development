# Python Style - Menschlichkeit Österreich

## General Python Standards

- **PEP8:** Befolge PEP8 Style Guide, nutze `black` für Formatierung
- **Type Annotations:** Vollständige Typisierung für alle Public APIs
- **Dataclasses:** Verwende `@dataclass` für Datenobjekte statt dicts
- **Pathlib:** `pathlib.Path` statt `os.path` für Dateisystem-Operationen
- **f-strings:** Bevorzuge f-strings für String-Formatierung

## FastAPI Backend Patterns

```python
# ✅ Gut: Vollständig typisierte API Endpoints
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr, validator
from typing import List, Optional
from datetime import datetime

class MemberCreateRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    birth_date: Optional[datetime] = None

    @validator('first_name', 'last_name')
    def validate_names(cls, v: str) -> str:
        if len(v.strip()) < 2:
            raise ValueError('Name muss mindestens 2 Zeichen haben')
        return v.strip().title()

@app.post("/api/members", response_model=Member)
async def create_member(
    member_data: MemberCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Member:
    """Erstellt ein neues Vereinsmitglied."""
    # Implementation
```

## Database & ORM Patterns

```python
# SQLAlchemy 2.0 Style mit AsyncSession
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, String, DateTime, Boolean
from typing import Optional, List
import uuid

class Member(Base):
    __tablename__ = 'members'

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationship zu SEPA-Mandaten
    sepa_mandates: Mapped[List["SepaMandate"]] = relationship(
        back_populates="member", cascade="all, delete-orphan"
    )

class MemberRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, member_data: MemberCreateRequest) -> Member:
        """Erstellt ein neues Mitglied mit DSGVO-Compliance."""
        member = Member(**member_data.dict())
        self.session.add(member)
        await self.session.commit()
        await self.session.refresh(member)

        # DSGVO: Protokolliere Datenverarbeitung
        await self._log_data_processing('member_created', member.id)
        return member

    async def find_by_email(self, email: str) -> Optional[Member]:
        """Findet Mitglied per E-Mail (case-insensitive)."""
        stmt = select(Member).where(Member.email.ilike(email))
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()
```

## SEPA & Financial Processing

```python
# SEPA-Verarbeitung mit Validierung
from decimal import Decimal, ROUND_HALF_UP
import re
from enum import Enum

class MandateStatus(str, Enum):
    PENDING = "pending"
    SIGNED = "signed"
    ACTIVE = "active"
    CANCELLED = "cancelled"
    EXPIRED = "expired"

class IBANValidator:
    """Validiert IBAN nach MOD-97 Standard mit österreichischem Fokus."""

    AUSTRIAN_BANK_CODES = {
        "12000": {"bic": "BKAUATWW", "name": "Bank Austria"},
        "20111": {"bic": "GIBAATWW", "name": "Erste Bank"},
        "32000": {"bic": "RLNWATWW", "name": "Raiffeisen Bank"},
    }

    @classmethod
    def validate(cls, iban: str) -> tuple[bool, Optional[str]]:
        """Validiert IBAN und gibt (is_valid, country) zurück."""
        clean_iban = re.sub(r'\s', '', iban.upper())

        if not re.match(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$', clean_iban):
            return False, None

        # MOD-97 Checksum
        rearranged = clean_iban[4:] + clean_iban[:4]
        numeric = ''.join(str(ord(c) - 55) if c.isalpha() else c for c in rearranged)

        is_valid = int(numeric) % 97 == 1
        country = clean_iban[:2] if is_valid else None

        return is_valid, country

class SepaProcessor:
    """Verarbeitung von SEPA-Lastschriften mit Audit-Logging."""

    def __init__(self, db: AsyncSession, audit_logger: AuditLogger):
        self.db = db
        self.audit = audit_logger

    async def create_mandate(
        self,
        member_id: str,
        iban: str,
        amount: Decimal
    ) -> SepaMandate:
        """Erstellt SEPA-Lastschriftmandat mit vollständiger Validierung."""

        # Validierung
        is_valid_iban, country = IBANValidator.validate(iban)
        if not is_valid_iban:
            raise ValueError(f"Ungültige IBAN: {iban}")

        # Betrag validieren (max 2 Dezimalstellen)
        amount = amount.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
        if amount <= 0:
            raise ValueError("Betrag muss positiv sein")

        # Mandat erstellen
        mandate = SepaMandate(
            member_id=member_id,
            iban=iban,
            amount=amount,
            status=MandateStatus.PENDING,
            country=country
        )

        self.db.add(mandate)
        await self.db.commit()

        # Audit-Log für Compliance
        await self.audit.log_financial_operation(
            operation="sepa_mandate_created",
            user_id=member_id,
            details={"mandate_id": mandate.id, "amount": str(amount)}
        )

        return mandate
```

## DSGVO Compliance & Privacy

```python
# Datenschutz-konforme Implementierung
from cryptography.fernet import Fernet
from typing import Dict, Any
import json
from datetime import datetime, timedelta

class PrivacyManager:
    """Verwaltet personenbezogene Daten DSGVO-konform."""

    def __init__(self, encryption_key: bytes):
        self.cipher = Fernet(encryption_key)

    def encrypt_pii(self, data: str) -> str:
        """Verschlüsselt personenbezogene Daten."""
        return self.cipher.encrypt(data.encode()).decode()

    def decrypt_pii(self, encrypted_data: str) -> str:
        """Entschlüsselt personenbezogene Daten."""
        return self.cipher.decrypt(encrypted_data.encode()).decode()

    async def handle_data_request(
        self,
        request_type: str,
        member_id: str
    ) -> Dict[str, Any]:
        """Verarbeitet DSGVO-Betroffenenrechte."""

        if request_type == "access":
            return await self._export_member_data(member_id)
        elif request_type == "deletion":
            return await self._delete_member_data(member_id)
        elif request_type == "portability":
            return await self._export_portable_data(member_id)
        else:
            raise ValueError(f"Unbekannter Request-Type: {request_type}")

    async def _export_member_data(self, member_id: str) -> Dict[str, Any]:
        """Exportiert alle Daten eines Mitglieds (Art. 15 DSGVO)."""
        # Sammle alle Daten aus verschiedenen Tabellen
        member_data = await self._get_member_data(member_id)
        sepa_data = await self._get_sepa_data(member_id)
        privacy_data = await self._get_privacy_settings(member_id)

        return {
            "export_date": datetime.utcnow().isoformat(),
            "member_data": member_data,
            "sepa_mandates": sepa_data,
            "privacy_settings": privacy_data,
            "legal_basis": "Art. 15 DSGVO - Auskunftsrecht",
            "retention_info": self._get_retention_info()
        }

class AuditLogger:
    """Protokolliert alle sicherheitsrelevanten Operationen."""

    async def log_financial_operation(
        self,
        operation: str,
        user_id: str,
        details: Dict[str, Any]
    ) -> None:
        """Protokolliert Finanz-Operationen für Compliance."""
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "operation": operation,
            "user_id": user_id,
            "details": details,
            "ip_address": self._get_client_ip(),
            "user_agent": self._get_user_agent()
        }

        # Schreibe in separate Audit-Tabelle (unveränderlich)
        await self._write_audit_log(log_entry)
```

## Testing & Quality Assurance

```python
# Pytest mit Fixtures und Factories
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from unittest.mock import Mock, patch

@pytest.fixture
async def test_member() -> Member:
    """Factory für Test-Mitglieder."""
    return Member(
        first_name="Max",
        last_name="Mustermann",
        email="max@example.com",
        is_active=True
    )

@pytest.fixture
async def auth_headers(test_user: User) -> Dict[str, str]:
    """Authentifizierung für API-Tests."""
    token = create_access_token(test_user.id)
    return {"Authorization": f"Bearer {token}"}

class TestMemberAPI:
    """Test-Suite für Member API."""

    async def test_create_member_success(
        self,
        client: AsyncClient,
        auth_headers: Dict[str, str]
    ):
        """Test: Erfolgreiche Mitglieder-Erstellung."""
        member_data = {
            "first_name": "Anna",
            "last_name": "Schmidt",
            "email": "anna.schmidt@example.com"
        }

        response = await client.post(
            "/api/members",
            json=member_data,
            headers=auth_headers
        )

        assert response.status_code == 201
        data = response.json()
        assert data["first_name"] == "Anna"
        assert data["email"] == "anna.schmidt@example.com"

    async def test_create_member_duplicate_email(
        self,
        client: AsyncClient,
        auth_headers: Dict[str, str],
        test_member: Member
    ):
        """Test: Fehler bei doppelter E-Mail."""
        member_data = {
            "first_name": "Test",
            "last_name": "User",
            "email": test_member.email  # Bereits existierende E-Mail
        }

        response = await client.post(
            "/api/members",
            json=member_data,
            headers=auth_headers
        )

        assert response.status_code == 409
        assert "E-Mail bereits registriert" in response.json()["detail"]

# Property-based Testing für IBAN-Validierung
from hypothesis import given, strategies as st

class TestIBANValidator:

    @given(st.text(min_size=15, max_size=34))
    def test_iban_validation_robust(self, iban: str):
        """Property-based Test für IBAN-Validierung."""
        is_valid, country = IBANValidator.validate(iban)

        # Properties die immer gelten sollen
        if is_valid:
            assert country is not None
            assert len(country) == 2
            assert country.isupper()
        else:
            assert country is None
```
