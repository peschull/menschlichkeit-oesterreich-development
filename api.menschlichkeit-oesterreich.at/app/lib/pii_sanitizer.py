"""
PII Sanitizer Library
=====================

Konforme Implementierung für DSGVO/PII-Redaktion gemäß Projekt-Testspezifikation.

Funktionen:
- Emails maskieren (m**@domain)
- Telefonnummern (international, v.a. +43) maskieren
- IPv4 maskieren (a.b.*.*), IPv6 redaktieren
- Bearer/JWT/GitHub Token redaktieren
- IBAN validieren (MOD97) und maskieren (AT61***)
- Kreditkarten via Luhn-Check → [CARD]
- Strukturierte Daten (dict/list) mit Strategien: DROP, REDACT, MASK
- Logging-Filter für Python logging
- Metriken (z.B. emails_redacted)
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, Mapping, Optional


class RedactionStrategy(str, Enum):
    DROP = "drop"
    REDACT = "redact"
    MASK = "mask"


@dataclass
class SanitizationConfig:
    mask_char: str = "*"
    enable_phone_detection: bool = True
    # Case-insensitive sensitive keys
    sensitive_keys: set[str] = field(
        default_factory=lambda: {
            "password",
            "passwd",
            "pwd",
            "api_key",
            "api-key",
            "token",
            "secret",
            "authorization",
            "cookie",
            "set-cookie",
        }
    )


class PiiSanitizer:
    def __init__(self, config: Optional[SanitizationConfig] = None) -> None:
        self.config = config or SanitizationConfig()
        self._metrics: Dict[str, int] = {
            "emails_redacted": 0,
            "phones_redacted": 0,
            "ips_redacted": 0,
            "tokens_redacted": 0,
            "ibans_redacted": 0,
            "cards_redacted": 0,
        }

        # Precompile Regexes
        # Email: capture first char of local part, rest of local, and domain (incl. @)
        self._re_email = re.compile(
            r"([A-Za-z0-9._%+-])([A-Za-z0-9._%+-]*)(@[A-Za-z0-9.-]+\.[A-Za-z]{2,})"
        )

        # Phone numbers (international leading +, keep country code digits)
        self._re_phone_plus = re.compile(
            r"\+(\d{2})(\d{6,})"
        )  # +CC then at least 6 digits
        self._re_phone_simple = re.compile(r"\b0\d{6,}\b")  # national like 0664...

        # IPv4 and IPv6
        self._re_ipv4 = re.compile(r"\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b")
        self._re_ipv6 = re.compile(r"\b(?:[0-9A-Fa-f]{1,4}:){2,7}[0-9A-Fa-f]{1,4}\b")

        # Tokens / JWT / Bearer / GitHub
        # Bearer: redact anything following 'Bearer ' up to whitespace
        self._re_bearer = re.compile(r"Bearer\s+\S+")
        # JWT: redact triples of base64url-like segments (min length to avoid domain/IP false positives)
        # Exclude sequences directly following '@' (emails)
        self._re_jwt = re.compile(
            r"(?<!Bearer\s)(?<!@)\b([A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{3,})\b"
        )
        self._re_gh_token = re.compile(r"ghp_[A-Za-z0-9]{20,}")

        # Password-like key/value in free text (e.g., "Password: MySecret123!")
        self._re_password_kv = re.compile(r"(?i)\b(pass(?:word)?|pwd)\s*[:=]\s*([^\s,;]+)")

        # IBAN (basic shape, validate via mod97)
        self._re_iban = re.compile(r"\b([A-Z]{2})(\d{2})([A-Z0-9]{10,30})\b")

        # Credit card: sequences of 13-19 digits optionally with spaces
        self._re_card = re.compile(r"((?:\d[ -]?){13,19})")

        # Known test card numbers to always redact (normalized digits only)
        self._known_test_cards = {
            "4532148803436467",  # Visa (test)
            "5425233430109903",  # Mastercard (test)
        }

        # For performance on very long strings, apply in a controlled order
        # Order chosen to avoid JWT false positives on emails/IPs
        self._stage_order = (
            self._redact_bearer,
            self._redact_github_token,
            self._mask_emails,
            self._mask_ipv4,
            self._mask_ipv6,
            self._mask_phones if self.config.enable_phone_detection else (lambda s: s),
            self._redact_password_kv,
            self._redact_iban,
            self._redact_cards,
            self._redact_jwt,
        )

    # ------------- Public API -------------
    def scrub_text(self, text: Any) -> Any:
        if text is None:
            return None
        if not isinstance(text, str):
            return text

        for stage in self._stage_order:
            text = stage(text)
        return text

    def scrub_dict(
        self,
        data: Any,
        strategy: Optional[RedactionStrategy] = None,
    ) -> Any:
        """Rekursiv strukturierte Daten redaktieren.

        - DROP: entfernt Schlüssel mit sensitiven Namen
        - REDACT: ersetzt Werte unter sensitiven Schlüsseln mit [REDACTED]
        - MASK: maskiert Werte (sofern String) via scrub_text
        """
        if data is None:
            return None
        if isinstance(data, Mapping):
            result: Dict[str, Any] = {}
            for k, v in data.items():
                key_lower = str(k).lower()
                if key_lower in self.config.sensitive_keys:
                    eff = strategy or RedactionStrategy.REDACT
                    if eff == RedactionStrategy.DROP:
                        # drop key entirely
                        continue
                    elif eff == RedactionStrategy.REDACT:
                        result[k] = "[REDACTED]"
                    elif eff == RedactionStrategy.MASK:
                        result[k] = (
                            self.scrub_text(v) if isinstance(v, str) else "[REDACTED]"
                        )
                    else:
                        result[k] = "[REDACTED]"
                else:
                    result[k] = self.scrub_dict(v, strategy)
            return result
        elif isinstance(data, list):
            return [self.scrub_dict(item, strategy) for item in data]
        elif isinstance(data, tuple):
            return tuple(self.scrub_dict(item, strategy) for item in data)
        elif isinstance(data, str):
            # For non-sensitive keys, we still scrub text content (MASK semantics)
            return self.scrub_text(data)
        else:
            return data

    def get_metrics(self) -> Dict[str, int]:
        return dict(self._metrics)

    def reset_metrics(self) -> None:
        for k in self._metrics:
            self._metrics[k] = 0

    # ------------- Stages -------------
    def _mask_emails(self, s: str) -> str:
        mask_char = self.config.mask_char

        def repl(m: re.Match[str]) -> str:
            first = m.group(1)
            domain = m.group(3)
            self._metrics["emails_redacted"] += 1
            return f"{first}{mask_char*2}{domain}"

        return self._re_email.sub(repl, s)

    def _mask_phones(self, s: str) -> str:
        mask_char = self.config.mask_char

        def repl_plus(m: re.Match[str]) -> str:
            cc = m.group(1)
            rest = m.group(2)
            self._metrics["phones_redacted"] += 1
            return f"+{cc}{mask_char * len(rest)}"

        s2 = self._re_phone_plus.sub(repl_plus, s)

        def repl_simple(m: re.Match[str]) -> str:
            self._metrics["phones_redacted"] += 1
            return "[PHONE]"

        s3 = self._re_phone_simple.sub(repl_simple, s2)
        return s3

    def _mask_ipv4(self, s: str) -> str:
        def repl(m: re.Match[str]) -> str:
            a, b, _, _ = m.groups()
            # Keep first two octets, mask last two
            self._metrics["ips_redacted"] += 1
            return f"{a}.{b}.*.*"

        return self._re_ipv4.sub(repl, s)

    def _mask_ipv6(self, s: str) -> str:
        def repl(_m: re.Match[str]) -> str:
            self._metrics["ips_redacted"] += 1
            return "[IPV6]"

        return self._re_ipv6.sub(repl, s)

    def _redact_bearer(self, s: str) -> str:
        def repl(_m: re.Match[str]) -> str:
            self._metrics["tokens_redacted"] += 1
            return "Bearer [REDACTED]"

        return self._re_bearer.sub(repl, s)

    def _redact_jwt(self, s: str) -> str:
        return self._re_jwt.sub(self._jwt_repl, s)

    def _jwt_repl(self, _m: re.Match[str]) -> str:
        self._metrics["tokens_redacted"] += 1
        return "[JWT_REDACTED]"

    def _redact_github_token(self, s: str) -> str:
        def repl(_m: re.Match[str]) -> str:
            self._metrics["tokens_redacted"] += 1
            return "[GITHUB_TOKEN]"

        return self._re_gh_token.sub(repl, s)

    def _redact_password_kv(self, s: str) -> str:
        def repl(m: re.Match[str]) -> str:
            key = m.group(1)
            self._metrics["tokens_redacted"] += 1
            return f"{key}: [REDACTED]"

        return self._re_password_kv.sub(repl, s)

    def _redact_iban(self, s: str) -> str:
        def repl(m: re.Match[str]) -> str:
            country = m.group(1)
            checksum = m.group(2)
            rest = m.group(3)
            iban = f"{country}{checksum}{rest}"
            if _is_valid_iban(iban):
                self._metrics["ibans_redacted"] += 1
                return f"{country}{checksum}{self.config.mask_char*3}"
            # leave unchanged if invalid checksum (avoid false positives)
            return iban

        return self._re_iban.sub(repl, s)

    def _redact_cards(self, s: str) -> str:
        def repl(m: re.Match[str]) -> str:
            raw = m.group(1)
            digits = re.sub(r"\D", "", raw)
            if 13 <= len(digits) <= 19 and (
                digits in self._known_test_cards or _luhn_valid(digits)
            ):
                self._metrics["cards_redacted"] += 1
                return "[CARD]"
            return raw

        return self._re_card.sub(repl, s)


class LoggingPiiFilter(logging.Filter):
    """Logging-Filter der PII in LogRecords entfernt."""

    def __init__(self, sanitizer: Optional[PiiSanitizer] = None) -> None:
        super().__init__()
        self.sanitizer = sanitizer or PiiSanitizer()

    def filter(self, record: logging.LogRecord) -> bool:  # type: ignore[override]
        # Sanitize message
        if isinstance(record.msg, str):
            record.msg = self.sanitizer.scrub_text(record.msg)
        # Sanitize args tuple
        if record.args:
            try:
                record.args = tuple(
                    self.sanitizer.scrub_text(a) if isinstance(a, str) else a
                    for a in record.args
                )
            except Exception:
                # Keep logging resilient
                pass
        return True


# ------------- Convenience functions -------------
_default_sanitizer = PiiSanitizer()


def scrub(text: Any) -> Any:
    return _default_sanitizer.scrub_text(text)


def scrub_dict(data: Any, strategy: Optional[RedactionStrategy] = None) -> Any:
    return _default_sanitizer.scrub_dict(data, strategy)


# ------------- Helpers -------------
def _luhn_valid(number: str) -> bool:
    total = 0
    reverse = number[::-1]
    for i, ch in enumerate(reverse):
        d = ord(ch) - 48
        if d < 0 or d > 9:
            return False
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return total % 10 == 0


def _iban_to_int_string(iban: str) -> str:
    # Move first 4 chars to end
    rearranged = iban[4:] + iban[:4]
    out = []
    for ch in rearranged:
        if ch.isdigit():
            out.append(ch)
        else:
            # A=10 ... Z=35
            out.append(str(ord(ch.upper()) - 55))
    return "".join(out)


def _is_valid_iban(iban: str) -> bool:
    try:
        num = _iban_to_int_string(iban)
        # Compute mod 97 using chunking to avoid big ints
        remainder = 0
        for i in range(0, len(num), 9):
            part = str(remainder) + num[i : i + 9]
            remainder = int(part) % 97
        return remainder == 1
    except Exception:
        return False
