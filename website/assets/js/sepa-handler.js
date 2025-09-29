// SEPA Direct Debit Form Handler

class SepaHandler {
  constructor() {
    this.form = null;
    this.init();
  }

  init() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.bindEvents());
    } else {
      this.bindEvents();
    }
  }

  bindEvents() {
    // Create SEPA form modal
    this.createSepaModal();

    // Bind to membership upgrade/payment buttons
    this.bindPaymentButtons();

    // IBAN validation
    this.bindIbanValidation();
  }

  createSepaModal() {
    const modalHtml = `
            <div class="modal fade" id="sepaModal" tabindex="-1" aria-labelledby="sepaModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="sepaModalLabel">
                                <i class="bi bi-bank me-2"></i>SEPA-Lastschriftmandat
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle me-2"></i>
                                <strong>Sicher und DSGVO-konform</strong><br>
                                Ihre Bankdaten werden verschlüsselt übertragen und DSGVO-konform gespeichert. 
                                Das SEPA-Mandat können Sie jederzeit widerrufen.
                            </div>
                            
                            <form id="sepaForm" novalidate>
                                <div class="row mb-4">
                                    <div class="col-12">
                                        <h6 class="fw-bold mb-3">Zahlungsdetails</h6>
                                        <div class="bg-light p-3 rounded">
                                            <div class="row">
                                                <div class="col-6">
                                                    <strong>Betrag:</strong><br>
                                                    <span class="fs-4 text-primary fw-bold" id="sepaAmount">€36,00</span><br>
                                                    <small class="text-muted">jährlich (€3,00/Monat)</small>
                                                </div>
                                                <div class="col-6">
                                                    <strong>Zahlungsrhythmus:</strong><br>
                                                    <span id="sepaInterval">Jährlich</span><br>
                                                    <small class="text-muted">Erstabbuchung in 7 Tagen</small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="sepaAccountHolder" class="form-label fw-semibold">
                                                <i class="bi bi-person me-2"></i>Kontoinhaber*
                                            </label>
                                            <input type="text" 
                                                   class="form-control" 
                                                   id="sepaAccountHolder" 
                                                   required
                                                   placeholder="Max Mustermann">
                                            <div class="invalid-feedback">
                                                Bitte geben Sie den Kontoinhaber ein.
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="sepaEmail" class="form-label fw-semibold">
                                                <i class="bi bi-envelope me-2"></i>E-Mail-Adresse*
                                            </label>
                                            <input type="email" 
                                                   class="form-control" 
                                                   id="sepaEmail" 
                                                   required
                                                   placeholder="max@beispiel.at">
                                            <div class="invalid-feedback">
                                                Bitte geben Sie eine gültige E-Mail ein.
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="sepaIban" class="form-label fw-semibold">
                                        <i class="bi bi-bank me-2"></i>IBAN*
                                    </label>
                                    <input type="text" 
                                           class="form-control font-monospace" 
                                           id="sepaIban" 
                                           required
                                           placeholder="AT12 3456 7890 1234 5678"
                                           maxlength="34"
                                           pattern="[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}">
                                    <div class="invalid-feedback">
                                        Bitte geben Sie eine gültige IBAN ein.
                                    </div>
                                    <div class="form-text">
                                        <span id="ibanValidationMessage"></span>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="sepaBic" class="form-label fw-semibold">
                                        <i class="bi bi-building me-2"></i>BIC (optional)
                                    </label>
                                    <input type="text" 
                                           class="form-control font-monospace" 
                                           id="sepaBic" 
                                           placeholder="GIBAATWWXXX"
                                           maxlength="11">
                                    <div class="form-text">
                                        Wird automatisch ermittelt, falls nicht angegeben
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="sepaAddress" class="form-label fw-semibold">
                                        <i class="bi bi-geo-alt me-2"></i>Adresse
                                    </label>
                                    <textarea class="form-control" 
                                              id="sepaAddress" 
                                              rows="3" 
                                              placeholder="Straße, Hausnummer&#10;PLZ Ort&#10;Land"></textarea>
                                </div>

                                <div class="border rounded p-3 mb-4 bg-light">
                                    <h6 class="fw-bold mb-3">SEPA-Lastschriftmandat</h6>
                                    <p class="small mb-3">
                                        Gläubiger-Identifikationsnummer: <strong>AT98ZZZ00000123456</strong><br>
                                        Mandatsreferenz: <strong>wird automatisch generiert</strong>
                                    </p>
                                    <p class="small mb-0">
                                        Mit der Erteilung des SEPA-Lastschriftmandats ermächtigen Sie den 
                                        <strong>Verein Menschlichkeit Österreich</strong>, Zahlungen von Ihrem Konto 
                                        mittels Lastschrift einzuziehen. Zugleich weisen Sie Ihr Kreditinstitut an, 
                                        die vom <strong>Verein Menschlichkeit Österreich</strong> auf Ihr Konto 
                                        gezogenen Lastschriften einzulösen.
                                    </p>
                                </div>

                                <div class="mb-4">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="sepaConsent" required>
                                        <label class="form-check-label" for="sepaConsent">
                                            Ich erteile hiermit das SEPA-Lastschriftmandat und bestätige, 
                                            dass ich Kontoinhaber oder bevollmächtigt bin.*
                                        </label>
                                        <div class="invalid-feedback">
                                            Sie müssen das SEPA-Mandat bestätigen.
                                        </div>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="sepaDataConsent" required>
                                        <label class="form-check-label" for="sepaDataConsent">
                                            Ich stimme der Verarbeitung meiner Bankdaten gemäß 
                                            <a href="datenschutz.html" target="_blank">Datenschutzerklärung</a> zu.*
                                        </label>
                                        <div class="invalid-feedback">
                                            Sie müssen der Datenverarbeitung zustimmen.
                                        </div>
                                    </div>
                                </div>

                                <div class="alert alert-warning small">
                                    <i class="bi bi-exclamation-triangle me-2"></i>
                                    <strong>Hinweis:</strong> Sie können dieses Mandat jederzeit durch eine 
                                    Mitteilung an uns widerrufen. Ein Widerruf betrifft nur zukünftige 
                                    Zahlungen, nicht bereits ausgeführte Lastschriften.
                                </div>

                                <div class="d-flex justify-content-end gap-2">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        Abbrechen
                                    </button>
                                    <button type="submit" class="btn btn-primary">
                                        <span class="button-text">
                                            <i class="bi bi-check-circle me-2"></i>Mandat erteilen
                                        </span>
                                        <span class="button-loading d-none">
                                            <span class="spinner-border spinner-border-sm me-2"></span>
                                            Verarbeitung läuft...
                                        </span>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        `;

    // Add modal to document
    document.body.insertAdjacentHTML('beforeend', modalHtml);

    // Get form reference
    this.form = document.getElementById('sepaForm');

    // Bind form submit
    if (this.form) {
      this.form.addEventListener('submit', e => this.handleSepaSubmit(e));
    }
  }

  bindPaymentButtons() {
    // Membership upgrade buttons
    const upgradeButtons = document.querySelectorAll('[data-membership-type]');
    upgradeButtons.forEach(button => {
      button.addEventListener('click', e => {
        e.preventDefault();
        const membershipType = button.getAttribute('data-membership-type');
        this.openSepaModal(membershipType);
      });
    });

    // Payment method change button
    const changePaymentBtn = document.querySelector('[data-action="change-payment"]');
    if (changePaymentBtn) {
      changePaymentBtn.addEventListener('click', e => {
        e.preventDefault();
        this.openSepaModal('current');
      });
    }
  }

  bindIbanValidation() {
    const ibanInput = document.getElementById('sepaIban');
    if (!ibanInput) return;

    ibanInput.addEventListener('input', e => {
      let value = e.target.value.replace(/\s/g, '').toUpperCase();

      // Format IBAN with spaces
      value = value.replace(/(.{4})/g, '$1 ').trim();
      e.target.value = value;

      // Validate IBAN
      this.validateIban(value.replace(/\s/g, ''));
    });

    ibanInput.addEventListener('blur', e => {
      const iban = e.target.value.replace(/\s/g, '');
      if (iban && this.isValidIban(iban)) {
        this.lookupBic(iban);
      }
    });
  }

  openSepaModal(membershipType = 'standard') {
    const modal = new bootstrap.Modal(document.getElementById('sepaModal'));

    // Set amount based on membership type
    const amounts = {
      standard: { amount: '€36,00', monthly: '€3,00', interval: 'Jährlich' },
      supporter: { amount: '€72,00', monthly: '€6,00', interval: 'Jährlich' },
      current: { amount: '€36,00', monthly: '€3,00', interval: 'Jährlich' },
    };

    const membershipData = amounts[membershipType] || amounts.standard;

    document.getElementById('sepaAmount').textContent = membershipData.amount;
    document.getElementById('sepaInterval').textContent = membershipData.interval;

    // Pre-fill user data if available
    this.prefillUserData();

    modal.show();
  }

  prefillUserData() {
    const userData = window.crmApi?.getUserData();
    if (!userData) return;

    if (userData.first_name && userData.last_name) {
      document.getElementById('sepaAccountHolder').value =
        `${userData.first_name} ${userData.last_name}`;
    }

    if (userData.email) {
      document.getElementById('sepaEmail').value = userData.email;
    }

    if (userData.address) {
      document.getElementById('sepaAddress').value = userData.address;
    }
  }

  async handleSepaSubmit(event) {
    event.preventDefault();

    if (!this.validateSepaForm()) {
      return;
    }

    // Show loading state
    this.setLoadingState(true);

    try {
      // Collect form data
      const formData = this.getSepaFormData();

      // API call to create SEPA mandate
      const result = await window.crmApi.createSepaMandate(formData);

      if (result.success) {
        this.showSuccess('SEPA-Lastschriftmandat erfolgreich erstellt!');

        // Close modal after 2 seconds
        setTimeout(() => {
          const modal = bootstrap.Modal.getInstance(document.getElementById('sepaModal'));
          modal.hide();

          // Refresh page to show updated payment info
          setTimeout(() => {
            window.location.reload();
          }, 500);
        }, 2000);
      } else {
        this.showError(result.error || 'Fehler beim Erstellen des SEPA-Mandats');
      }
    } catch (error) {
      this.showError('Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.');
    } finally {
      this.setLoadingState(false);
    }
  }

  validateSepaForm() {
    const requiredFields = [
      'sepaAccountHolder',
      'sepaEmail',
      'sepaIban',
      'sepaConsent',
      'sepaDataConsent',
    ];

    let isValid = true;

    // Clear previous errors
    this.clearFormErrors();

    // Validate required fields
    requiredFields.forEach(fieldId => {
      const field = document.getElementById(fieldId);
      if (!field) return;

      if (field.type === 'checkbox') {
        if (!field.checked) {
          this.showFieldError(fieldId, 'Dieses Feld ist erforderlich.');
          isValid = false;
        }
      } else if (!field.value.trim()) {
        this.showFieldError(fieldId, 'Dieses Feld ist erforderlich.');
        isValid = false;
      }
    });

    // Validate email
    const email = document.getElementById('sepaEmail').value.trim();
    if (email && !this.validateEmail(email)) {
      this.showFieldError('sepaEmail', 'Bitte geben Sie eine gültige E-Mail-Adresse ein.');
      isValid = false;
    }

    // Validate IBAN
    const iban = document.getElementById('sepaIban').value.replace(/\s/g, '');
    if (iban && !this.isValidIban(iban)) {
      this.showFieldError('sepaIban', 'Bitte geben Sie eine gültige IBAN ein.');
      isValid = false;
    }

    return isValid;
  }

  getSepaFormData() {
    return {
      account_holder: document.getElementById('sepaAccountHolder').value.trim(),
      email: document.getElementById('sepaEmail').value.trim(),
      iban: document.getElementById('sepaIban').value.replace(/\s/g, ''),
      bic: document.getElementById('sepaBic').value.trim(),
      address: document.getElementById('sepaAddress').value.trim(),
      amount: document.getElementById('sepaAmount').textContent,
      interval: document.getElementById('sepaInterval').textContent.toLowerCase(),
      mandate_date: new Date().toISOString().split('T')[0],
    };
  }

  validateIban(iban) {
    const messageElement = document.getElementById('ibanValidationMessage');
    if (!messageElement) return;

    if (!iban) {
      messageElement.textContent = '';
      return;
    }

    if (this.isValidIban(iban)) {
      messageElement.innerHTML = '<i class="bi bi-check-circle text-success me-1"></i>Gültige IBAN';
      messageElement.className = 'text-success';
    } else {
      messageElement.innerHTML = '<i class="bi bi-x-circle text-danger me-1"></i>Ungültige IBAN';
      messageElement.className = 'text-danger';
    }
  }

  isValidIban(iban) {
    // Basic IBAN validation
    if (!/^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}([A-Z0-9]?){0,16}$/.test(iban)) {
      return false;
    }

    // IBAN length check for common countries
    const lengths = {
      AD: 24,
      AE: 23,
      AL: 28,
      AT: 20,
      AZ: 28,
      BA: 20,
      BE: 16,
      BG: 22,
      BH: 22,
      BR: 29,
      BY: 28,
      CH: 21,
      CR: 22,
      CY: 28,
      CZ: 24,
      DE: 22,
      DK: 18,
      DO: 28,
      EE: 20,
      EG: 29,
      ES: 24,
      FI: 18,
      FO: 18,
      FR: 27,
      GB: 22,
      GE: 22,
      GI: 23,
      GL: 18,
      GR: 27,
      GT: 28,
      HR: 21,
      HU: 28,
      IE: 22,
      IL: 23,
      IS: 26,
      IT: 27,
      JO: 30,
      KW: 30,
      KZ: 20,
      LB: 28,
      LC: 32,
      LI: 21,
      LT: 20,
      LU: 20,
      LV: 21,
      MC: 27,
      MD: 24,
      ME: 22,
      MK: 19,
      MR: 27,
      MT: 31,
      MU: 30,
      NL: 18,
      NO: 15,
      PK: 24,
      PL: 28,
      PS: 29,
      PT: 25,
      QA: 29,
      RO: 24,
      RS: 22,
      SA: 24,
      SE: 24,
      SI: 19,
      SK: 24,
      SM: 27,
      TN: 24,
      TR: 26,
      UA: 29,
      VG: 24,
      XK: 20,
    };

    const countryCode = iban.substr(0, 2);
    const expectedLength = lengths[countryCode];

    if (expectedLength && iban.length !== expectedLength) {
      return false;
    }

    // MOD-97 validation
    const rearranged = iban.substr(4) + iban.substr(0, 4);
    const numericString = rearranged.replace(/[A-Z]/g, match => {
      return (match.charCodeAt(0) - 55).toString();
    });

    // Calculate mod 97 for large numbers
    let remainder = 0;
    for (let i = 0; i < numericString.length; i++) {
      remainder = (remainder * 10 + parseInt(numericString[i])) % 97;
    }

    return remainder === 1;
  }

  async lookupBic(iban) {
    // Mock BIC lookup - in real implementation, call a BIC lookup service
    const bicInput = document.getElementById('sepaBic');
    if (!bicInput || bicInput.value.trim()) return;

    // Austrian banks common BICs
    const austrianBics = {
      19043: 'BKAUATWW', // Bank Austria
      20111: 'GIBAATWW', // Erste Bank
      32000: 'RLNWATWW', // Raiffeisen
      14000: 'OBKLAT2L', // Oberbank
      12000: 'BAWAATWW', // Bawag PSK
    };

    const bankCode = iban.substr(4, 5);
    if (austrianBics[bankCode]) {
      bicInput.value = austrianBics[bankCode];
      this.showInfo('BIC automatisch ermittelt');
    }
  }

  validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  showFieldError(fieldId, message) {
    const field = document.getElementById(fieldId);
    if (!field) return;

    field.classList.add('is-invalid');

    const feedback = field.parentElement.querySelector('.invalid-feedback');
    if (feedback) {
      feedback.textContent = message;
    }
  }

  clearFormErrors() {
    const invalidFields = document.querySelectorAll('.is-invalid');
    invalidFields.forEach(field => field.classList.remove('is-invalid'));
  }

  setLoadingState(loading) {
    const submitButton = this.form?.querySelector('button[type="submit"]');
    if (!submitButton) return;

    const buttonText = submitButton.querySelector('.button-text');
    const buttonLoading = submitButton.querySelector('.button-loading');

    if (loading) {
      submitButton.disabled = true;
      buttonText?.classList.add('d-none');
      buttonLoading?.classList.remove('d-none');
    } else {
      submitButton.disabled = false;
      buttonText?.classList.remove('d-none');
      buttonLoading?.classList.add('d-none');
    }
  }

  showSuccess(message) {
    this.showAlert(message, 'success');
  }

  showError(message) {
    this.showAlert(message, 'danger');
  }

  showInfo(message) {
    this.showAlert(message, 'info');
  }

  showAlert(message, type = 'info') {
    // Remove existing alerts in modal
    const existingAlerts = document.querySelectorAll('.sepa-alert');
    existingAlerts.forEach(alert => alert.remove());

    // Create new alert
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show sepa-alert`;
    alertDiv.setAttribute('role', 'alert');

    alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        `;

    // Insert at the top of modal body
    const modalBody = document.querySelector('#sepaModal .modal-body');
    if (modalBody) {
      modalBody.insertBefore(alertDiv, modalBody.firstChild);
    }

    // Auto-dismiss info messages after 3 seconds
    if (type === 'info') {
      setTimeout(() => {
        if (alertDiv.parentNode) {
          alertDiv.remove();
        }
      }, 3000);
    }

    // Scroll to alert
    alertDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}

// Initialize SEPA Handler
document.addEventListener('DOMContentLoaded', () => {
  new SepaHandler();
});
