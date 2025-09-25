# CiviCRM Integration Setup für Menschlichkeit Österreich

## CiviCRM Download und Installation

### 1. CiviCRM Herunterladen

```bash
# CiviCRM für Standalone Installation
cd d:/Arbeitsverzeichniss/menschlichkeit-oesterreich-monorepo/crm.menschlichkeit-oesterreich.at/

# CiviCRM 5.69.x herunterladen (aktuellste LTS Version)
wget https://download.civicrm.org/civicrm-5.69.4-standalone.tar.gz
tar -xzf civicrm-5.69.4-standalone.tar.gz

# Oder WordPress Plugin Version
wget https://download.civicrm.org/civicrm-5.69.4-wordpress.zip
```

### 2. CiviCRM Standalone Konfiguration

```php
// sites/default/civicrm.settings.php
<?php
define('CIVICRM_UF', 'Standalone');

// Datenbank-Konfiguration
define('CIVICRM_DSN', 'mysql://mo_crm_user:secure_crm_2025@localhost:3306/mo_civicrm');
define('CIVICRM_UF_DSN', 'mysql://mo_crm_user:secure_crm_2025@localhost:3306/mo_civicrm');

// Pfad-Konfiguration
define('CIVICRM_TEMPLATE_COMPILEDIR', __DIR__ . '/templates_c/');
define('CIVICRM_UF_BASEURL', 'https://crm.menschlichkeit-oesterreich.at/');
define('CIVICRM_RESOURCEURL', 'https://crm.menschlichkeit-oesterreich.at/sites/all/modules/civicrm/');

// Sicherheit
define('CIVICRM_SITE_KEY', 'your-unique-site-key-32-chars-long');
define('CIVICRM_SIGN_KEYS', 'your-signing-key-here');

// Logging und Debug
define('CIVICRM_DEBUG_LOG_QUERY', 1);
define('CIVICRM_LOGGING_DSN', CIVICRM_DSN);
```

### 3. CiviCRM Hauptfunktionen Konfiguration

#### Kontakt- und Spenderverwaltung

```php
// CiviCRM Kontakttypen erweitern
class MOContactTypes {
    public static function createCustomContactTypes() {
        $contactTypes = [
            'Spender' => [
                'label' => 'Spender',
                'parent_id' => 'Individual',
                'is_active' => 1,
                'description' => 'Personen die Spenden'
            ],
            'Freiwilliger' => [
                'label' => 'Freiwilliger',
                'parent_id' => 'Individual',
                'is_active' => 1,
                'description' => 'Freiwillige Helfer'
            ],
            'Organisation_Partner' => [
                'label' => 'Partnerorganisation',
                'parent_id' => 'Organization',
                'is_active' => 1,
                'description' => 'Kooperierende Organisationen'
            ]
        ];

        foreach ($contactTypes as $name => $type) {
            civicrm_api3('ContactType', 'create', $type);
        }
    }
}
```

#### Event-Management

```php
// Event-Templates für Menschlichkeit Österreich
class MOEventManagement {
    public static function createEventTemplates() {
        $eventTemplates = [
            'spendenveranstaltung' => [
                'title' => 'Spendenveranstaltung Template',
                'event_type_id' => 'Fundraising',
                'is_template' => 1,
                'is_public' => 1,
                'participant_listing_id' => 'Name Only'
            ],
            'hilfsaktion' => [
                'title' => 'Hilfsaktion Template',
                'event_type_id' => 'Conference',
                'is_template' => 1,
                'is_public' => 1
            ],
            'freiwilligen_schulung' => [
                'title' => 'Freiwilligen-Schulung Template',
                'event_type_id' => 'Meeting',
                'is_template' => 1,
                'is_public' => 0
            ]
        ];

        foreach ($eventTemplates as $template) {
            civicrm_api3('Event', 'create', $template);
        }
    }
}
```

#### Mitgliedschafts-Management

```php
// Mitgliedschaftstypen für Menschlichkeit Österreich
class MOMembershipTypes {
    public static function createMembershipTypes() {
        $membershipTypes = [
            'foerdermitgliedschaft' => [
                'name' => 'Fördermitgliedschaft',
                'description' => 'Regelmäßige finanzielle Unterstützung',
                'minimum_fee' => 50.00,
                'duration_unit' => 'year',
                'duration_interval' => 1,
                'is_active' => 1,
                'auto_renew' => 1
            ],
            'aktive_mitgliedschaft' => [
                'name' => 'Aktive Mitgliedschaft',
                'description' => 'Aktive Teilnahme an Projekten',
                'minimum_fee' => 30.00,
                'duration_unit' => 'year',
                'duration_interval' => 1,
                'is_active' => 1
            ],
            'ehrenmitgliedschaft' => [
                'name' => 'Ehrenmitgliedschaft',
                'description' => 'Besondere Anerkennung für Verdienste',
                'minimum_fee' => 0.00,
                'duration_unit' => 'lifetime',
                'is_active' => 1
            ]
        ];

        foreach ($membershipTypes as $type) {
            civicrm_api3('MembershipType', 'create', $type);
        }
    }
}
```

### 4. API-Integration mit Laravel

#### CiviCRM REST API Klasse

```php
// Laravel: app/Services/CiviCRMService.php
<?php
namespace App\Services;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

class CiviCRMService
{
    private $client;
    private $apiUrl;
    private $siteKey;
    private $apiKey;

    public function __construct()
    {
        $this->apiUrl = config('services.civicrm.api_url');
        $this->siteKey = config('services.civicrm.site_key');
        $this->apiKey = config('services.civicrm.api_key');

        $this->client = new Client([
            'base_uri' => $this->apiUrl,
            'timeout' => 30,
        ]);
    }

    /**
     * Spender erstellen oder aktualisieren
     */
    public function createOrUpdateContact($contactData)
    {
        $params = [
            'entity' => 'Contact',
            'action' => 'create',
            'json' => $contactData,
            'key' => $this->siteKey,
            'api_key' => $this->apiKey
        ];

        try {
            $response = $this->client->post('', [
                'form_params' => $params
            ]);

            return json_decode($response->getBody()->getContents(), true);
        } catch (\Exception $e) {
            Log::error('CiviCRM API Error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Spende verarbeiten
     */
    public function processDonation($donationData)
    {
        $contributionParams = [
            'entity' => 'Contribution',
            'action' => 'create',
            'json' => [
                'contact_id' => $donationData['contact_id'],
                'financial_type_id' => 1, // Donation
                'total_amount' => $donationData['amount'],
                'currency' => 'EUR',
                'source' => $donationData['source'] ?? 'Website',
                'contribution_status_id' => 1, // Completed
                'receive_date' => date('Y-m-d H:i:s')
            ],
            'key' => $this->siteKey,
            'api_key' => $this->apiKey
        ];

        return $this->client->post('', [
            'form_params' => $contributionParams
        ]);
    }

    /**
     * Event-Registrierung
     */
    public function registerForEvent($registrationData)
    {
        $participantParams = [
            'entity' => 'Participant',
            'action' => 'create',
            'json' => [
                'contact_id' => $registrationData['contact_id'],
                'event_id' => $registrationData['event_id'],
                'status_id' => 1, // Registered
                'register_date' => date('Y-m-d H:i:s'),
                'source' => 'Online Registration'
            ],
            'key' => $this->siteKey,
            'api_key' => $this->apiKey
        ];

        return $this->client->post('', [
            'form_params' => $participantParams
        ]);
    }
}
```

### 5. WordPress Integration

#### CiviCRM Shortcodes für WordPress

```php
// WordPress Theme Functions.php
function mo_civicrm_donation_form($atts) {
    $atts = shortcode_atts([
        'campaign_id' => '',
        'amount' => '50',
        'currency' => 'EUR'
    ], $atts);

    ob_start();
    ?>
    <div class="mo-donation-form" data-campaign="<?php echo $atts['campaign_id']; ?>">
        <form id="civicrm-donation">
            <div class="donation-amounts">
                <input type="radio" name="amount" value="25" id="amount-25">
                <label for="amount-25">25€</label>

                <input type="radio" name="amount" value="50" id="amount-50" checked>
                <label for="amount-50">50€</label>

                <input type="radio" name="amount" value="100" id="amount-100">
                <label for="amount-100">100€</label>

                <input type="number" name="custom_amount" placeholder="Anderer Betrag">
            </div>

            <div class="donor-info">
                <input type="text" name="first_name" placeholder="Vorname" required>
                <input type="text" name="last_name" placeholder="Nachname" required>
                <input type="email" name="email" placeholder="E-Mail" required>
                <input type="tel" name="phone" placeholder="Telefon">
            </div>

            <button type="submit">Jetzt Spenden</button>
        </form>
    </div>

    <script>
    jQuery(document).ready(function($) {
        $('#civicrm-donation').on('submit', function(e) {
            e.preventDefault();

            // API call to Laravel backend
            $.ajax({
                url: 'https://api.menschlichkeit-oesterreich.at/donations/process',
                method: 'POST',
                data: $(this).serialize(),
                success: function(response) {
                    // Redirect to payment processor
                    window.location.href = response.payment_url;
                },
                error: function() {
                    alert('Fehler beim Verarbeiten der Spende. Bitte versuchen Sie es erneut.');
                }
            });
        });
    });
    </script>
    <?php
    return ob_get_clean();
}
add_shortcode('mo_donation_form', 'mo_civicrm_donation_form');
```

### 6. Automatisierte Workflows

#### Laravel Scheduler für CiviCRM Integration

```php
// Laravel: app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    // Tägliche Spender-E-Mails
    $schedule->call(function () {
        $civicrm = app(CiviCRMService::class);

        // Thank you emails for recent donations
        $recentDonations = $civicrm->getRecentDonations();
        foreach ($recentDonations as $donation) {
            // Send thank you email
            Mail::to($donation['email'])->send(new DonationThankYou($donation));
        }
    })->daily();

    // Wöchentliche Newsletter-Sync
    $schedule->call(function () {
        // Sync contacts between WordPress and CiviCRM
        $this->syncWordPressUsers();
    })->weekly();

    // Monatliche Berichte
    $schedule->call(function () {
        // Generate monthly reports
        $this->generateMonthlyReports();
    })->monthly();
}
```

## Installation Steps

1. **CiviCRM Installation**: Lade CiviCRM herunter und konfiguriere die Datenbank
2. **API-Keys generieren**: Erstelle Site-Key und API-Key in CiviCRM
3. **Laravel Service konfigurieren**: Füge CiviCRM Service zu Laravel hinzu
4. **WordPress Integration**: Installiere Shortcodes und Formulare
5. **Testing**: Teste alle API-Verbindungen und Workflows

Die CiviCRM-Integration ermöglicht professionelle Verwaltung von Spendern, Events und Mitgliedschaften mit nahtloser Automation über die API-Domain.
