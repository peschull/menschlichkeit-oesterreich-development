# CiviCRM Jobs & SEPA Setup - Automated Payment Processing

## 🏦 CiviCRM SEPA & Payment Automation

### 🎯 SEPA Integration Goals

#### Payment Processing Targets
- **Automated SEPA Direct Debits**: Monthly membership fees
- **Pre-Notification System**: 14-day advance notice (SEPA requirement)
- **Webhook Processing**: Real-time payment confirmations
- **Error Handling**: Failed payment retry logic
- **Compliance**: SEPA regulation conformity
- **Reconciliation**: Automated bank statement matching

#### Automation Goals
- **Scheduled Jobs**: All CiviCRM maintenance automated
- **Email Notifications**: Member communication automated
- **Contribution Processing**: Real-time payment processing
- **Data Integrity**: Automated backups and validation
- **Monitoring**: Payment process health checks

## 💳 SEPA Direct Debit Configuration

### 1. CiviSEPA Extension Setup

```bash
#!/bin/bash
# install_civisepa.sh - CiviSEPA Extension Installation

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
CIVICRM_EXT_DIR="$DRUPAL_ROOT/sites/default/files/civicrm/ext"

echo "🏦 Installing CiviSEPA Extension..."

cd $DRUPAL_ROOT

# Download CiviSEPA extension
echo "📥 Downloading CiviSEPA..."
cd $CIVICRM_EXT_DIR
wget -O civisepa.zip "https://download.civicrm.org/extension/org.project60.sepa/latest"
unzip civisepa.zip
rm civisepa.zip

# Enable extension via Drush
echo "🔧 Enabling CiviSEPA..."
drush civicrm-ext-enable org.project60.sepa

# Configure SEPA settings
echo "⚙️ Configuring SEPA settings..."
drush php-eval "
// SEPA Configuration
\$sepa_config = [
  'sepa_file_format_id' => 'FRST',
  'sepa_file_format_contribution' => 'FRST', 
  'batching_FRST' => 1,
  'batching_RCUR' => 1,
  'batching_OOFF' => 1,
  'pp_buffer_days' => 14,
  'pp_cycle_days' => 30,
  'exclude_weekends' => 1,
  'custom_txmsg' => 'Mitgliedsbeitrag {contribution.financial_type} - {contribution.receive_date}',
  'creditor_id' => '[SEPA_CREDITOR_ID]',
  'creditor_name' => 'Menschlichkeit Österreich',
  'creditor_address' => '[CREDITOR_ADDRESS]',
  'creditor_country_id' => '1014', // Austria
  'creditor_iban' => '[CREDITOR_IBAN]',
  'creditor_bic' => '[CREDITOR_BIC]'
];

foreach (\$sepa_config as \$key => \$value) {
  CRM_Core_BAO_Setting::setItem(\$value, 'org.project60.sepa', \$key);
}

echo 'SEPA configuration completed successfully';
"

echo "✅ CiviSEPA installation completed"
```

### 2. SEPA Creditor Configuration

```php
<?php
// sepa_creditor_setup.php - SEPA Creditor Configuration

/**
 * Create SEPA Creditor for Organization
 */

require_once '/var/www/vhosts/[domain]/httpdocs/sites/default/files/civicrm/civicrm.settings.php';
require_once 'CRM/Core/Config.php';

$config = CRM_Core_Config::singleton();

// Create SEPA Creditor
$creditor_params = [
  'identifier' => '[SEPA_CREDITOR_ID]', // e.g., AT98ZZZ09999999999
  'name' => 'Menschlichkeit Österreich',
  'address' => '[ORGANIZATION_ADDRESS]',
  'country_id' => 1014, // Austria
  'iban' => '[CREDITOR_IBAN]',
  'bic' => '[CREDITOR_BIC]',
  'mandate_prefix' => 'MOED',
  'mandate_active' => 1,
  'sepa_file_format_id' => 4, // pain.008.001.02
  'category' => 'MAIN',
  'uses_bic' => 1,
  'pain_version' => '08',
  'is_active' => 1
];

try {
    $result = civicrm_api3('SepaCreditor', 'create', $creditor_params);
    echo "✅ SEPA Creditor created successfully. ID: " . $result['id'] . "\n";
    
    // Store creditor ID for later use
    $creditor_id = $result['id'];
    
    // Configure payment processor
    $pp_params = [
        'name' => 'SEPA Direct Debit',
        'title' => 'SEPA Lastschrift',
        'description' => 'SEPA Direct Debit Payment Processor',
        'payment_processor_type_id' => 'SEPA_DD',
        'is_active' => 1,
        'is_default' => 1,
        'class_name' => 'org.project60.sepa',
        'url_site' => $creditor_id,
        'url_api' => '',
        'url_recur' => '',
        'url_button' => '',
        'subject' => '',
        'user_name' => '',
        'password' => '',
        'signature' => '',
        'is_recur' => 1,
        'billing_mode' => 1,
        'payment_type' => 2
    ];
    
    $pp_result = civicrm_api3('PaymentProcessor', 'create', $pp_params);
    echo "✅ SEPA Payment Processor created. ID: " . $pp_result['id'] . "\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
```

### 3. Membership Payment Automation

```php
<?php
// membership_sepa_setup.php - Automated Membership Payments

/**
 * Setup recurring SEPA mandates for memberships
 */

// Membership type configuration
$membership_types = [
    'Standard' => [
        'fee' => 5.00,
        'cycle' => 'monthly',
        'financial_type' => 'Membership Dues'
    ],
    'Premium' => [
        'fee' => 10.00, 
        'cycle' => 'monthly',
        'financial_type' => 'Membership Dues'
    ],
    'Student' => [
        'fee' => 2.50,
        'cycle' => 'monthly',
        'financial_type' => 'Membership Dues'
    ]
];

foreach ($membership_types as $type_name => $config) {
    // Create contribution page for each membership type
    $contribution_page = [
        'title' => $type_name . ' Membership - SEPA',
        'intro_text' => 'Become a ' . $type_name . ' member with automatic SEPA payments',
        'financial_type_id' => 'Membership Dues',
        'payment_processor' => [1], // SEPA processor ID
        'is_allow_other_amount' => 0,
        'min_amount' => $config['fee'],
        'max_amount' => $config['fee'],
        'default_amount_id' => $config['fee'],
        'is_email_receipt' => 1,
        'receipt_from_name' => 'Menschlichkeit Österreich',
        'receipt_from_email' => 'beitrag@menschlichkeit-oesterreich.at',
        'cc_receipt' => 'admin@menschlichkeit-oesterreich.at',
        'is_active' => 1,
        'is_recur' => 1,
        'recur_frequency_unit' => 'month',
        'is_recur_interval' => 0,
        'is_recur_installments' => 0
    ];
    
    try {
        $result = civicrm_api3('ContributionPage', 'create', $contribution_page);
        echo "✅ Created contribution page for $type_name membership\n";
        
        // Create price set for membership
        $price_set = [
            'title' => $type_name . ' Membership Fee',
            'extends' => 'CiviContribute',
            'financial_type_id' => 'Membership Dues',
            'is_active' => 1,
            'is_reserved' => 0
        ];
        
        $ps_result = civicrm_api3('PriceSet', 'create', $price_set);
        $price_set_id = $ps_result['id'];
        
        // Add price field
        $price_field = [
            'price_set_id' => $price_set_id,
            'name' => strtolower($type_name) . '_fee',
            'label' => $type_name . ' Membership Fee',
            'html_type' => 'Radio',
            'is_required' => 1,
            'is_active' => 1,
            'weight' => 1
        ];
        
        $pf_result = civicrm_api3('PriceField', 'create', $price_field);
        $price_field_id = $pf_result['id'];
        
        // Add price field value
        $price_field_value = [
            'price_field_id' => $price_field_id,
            'name' => strtolower($type_name) . '_monthly',
            'label' => 'Monthly ' . $type_name . ' Fee',
            'amount' => $config['fee'],
            'financial_type_id' => 'Membership Dues',
            'is_default' => 1,
            'is_active' => 1,
            'weight' => 1
        ];
        
        civicrm_api3('PriceFieldValue', 'create', $price_field_value);
        
        echo "✅ Created price structure for $type_name\n";
        
    } catch (Exception $e) {
        echo "❌ Error creating $type_name setup: " . $e->getMessage() . "\n";
    }
}

// Create automated workflow for mandate creation
$workflow_template = [
    'msg_title' => 'SEPA Mandate Created',
    'msg_subject' => 'Your SEPA mandate has been created',
    'msg_text' => 'Dear {contact.display_name},

Thank you for setting up automated payments for your membership.

Your SEPA mandate details:
- Mandate ID: {sepa.mandate_id}
- Amount: €{contribution.total_amount} monthly
- First payment: {sepa.first_contribution_date}

Best regards,
Menschlichkeit Österreich Team',
    'msg_html' => '<p>Dear {contact.display_name},</p>
<p>Thank you for setting up automated payments for your membership.</p>
<p><strong>Your SEPA mandate details:</strong></p>
<ul>
<li>Mandate ID: {sepa.mandate_id}</li>
<li>Amount: €{contribution.total_amount} monthly</li>
<li>First payment: {sepa.first_contribution_date}</li>
</ul>
<p>Best regards,<br/>Menschlichkeit Österreich Team</p>',
    'workflow_id' => 1,
    'is_default' => 1,
    'is_active' => 1
];

try {
    $template_result = civicrm_api3('MessageTemplate', 'create', $workflow_template);
    echo "✅ Created SEPA mandate confirmation template\n";
} catch (Exception $e) {
    echo "❌ Error creating template: " . $e->getMessage() . "\n";
}

echo "✅ Membership SEPA setup completed\n";
?>
```

## ⚙️ CiviCRM Scheduled Jobs Configuration

### 1. Core CiviCRM Jobs Setup

```php
<?php
// civicrm_jobs_setup.php - Configure all scheduled jobs

/**
 * Configure CiviCRM Scheduled Jobs
 */

$scheduled_jobs = [
    // SEPA Processing Jobs
    [
        'name' => 'SEPA Pre-Notification',
        'description' => 'Send pre-notification emails 14 days before SEPA collection',
        'api_entity' => 'SepaAlternativeBatching',
        'api_action' => 'prenotification',
        'parameters' => 'mode=FRST,RCUR',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    [
        'name' => 'SEPA Batching',
        'description' => 'Create SEPA collection batches',
        'api_entity' => 'SepaAlternativeBatching', 
        'api_action' => 'batching',
        'parameters' => 'type=FRST,RCUR',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    [
        'name' => 'SEPA Collection',
        'description' => 'Process SEPA direct debits',
        'api_entity' => 'SepaAlternativeBatching',
        'api_action' => 'closegroup',
        'parameters' => 'mode=FRST,RCUR',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    
    // Membership Management
    [
        'name' => 'Process Membership',
        'description' => 'Process membership status updates and renewals',
        'api_entity' => 'Job',
        'api_action' => 'process_membership',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    [
        'name' => 'Membership Reminders',
        'description' => 'Send membership renewal reminders',
        'api_entity' => 'Job',
        'api_action' => 'send_reminder',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    
    // Communication
    [
        'name' => 'Process Mailings',
        'description' => 'Process scheduled mailings and newsletters',
        'api_entity' => 'Mailing',
        'api_action' => 'process',
        'parameters' => '',
        'run_frequency' => 'Always',
        'is_active' => 1
    ],
    [
        'name' => 'Fetch Bounces',
        'description' => 'Process email bounces',
        'api_entity' => 'Job',
        'api_action' => 'fetch_bounces',
        'parameters' => '',
        'run_frequency' => 'Hourly',
        'is_active' => 1
    ],
    
    // Data Management
    [
        'name' => 'Clean Cache Tables',
        'description' => 'Clean up cache and temporary tables',
        'api_entity' => 'Job',
        'api_action' => 'cleanup',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    [
        'name' => 'Update Greeting',
        'description' => 'Update contact greeting fields',
        'api_entity' => 'Job',
        'api_action' => 'update_greeting',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    
    // Financial
    [
        'name' => 'Process Pledges',
        'description' => 'Process pledge payments',
        'api_entity' => 'Job',
        'api_action' => 'process_pledge',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ],
    [
        'name' => 'Update Participant Status',
        'description' => 'Update event participant status',
        'api_entity' => 'ParticipantStatusType',
        'api_action' => 'process',
        'parameters' => '',
        'run_frequency' => 'Daily',
        'is_active' => 1
    ]
];

foreach ($scheduled_jobs as $job_config) {
    try {
        // Check if job already exists
        $existing = civicrm_api3('Job', 'get', [
            'name' => $job_config['name'],
            'sequential' => 1
        ]);
        
        if ($existing['count'] == 0) {
            // Create new job
            $result = civicrm_api3('Job', 'create', $job_config);
            echo "✅ Created scheduled job: " . $job_config['name'] . "\n";
        } else {
            // Update existing job
            $job_config['id'] = $existing['values'][0]['id'];
            $result = civicrm_api3('Job', 'create', $job_config);
            echo "🔄 Updated scheduled job: " . $job_config['name'] . "\n";
        }
        
    } catch (Exception $e) {
        echo "❌ Error with job " . $job_config['name'] . ": " . $e->getMessage() . "\n";
    }
}

echo "✅ All CiviCRM scheduled jobs configured\n";
?>
```

### 2. Cron Job Configuration

```bash
#!/bin/bash
# setup_civicrm_cron.sh - Configure system cron for CiviCRM

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
CRON_USER="www-data"
SITE_KEY="[CIVICRM_SITE_KEY]"
SITE_URL="https://crm.[domain]"

echo "⏰ Setting up CiviCRM Cron Jobs..."

# Create CiviCRM cron script
cat > /opt/scripts/civicrm_cron.sh << 'EOF'
#!/bin/bash
# CiviCRM Cron Job Runner

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
SITE_KEY="[CIVICRM_SITE_KEY]"
SITE_URL="https://crm.[domain]"
LOG_FILE="/var/log/civicrm-cron-$(date +%Y%m%d).log"

# Function to run CiviCRM job
run_civicrm_job() {
    local job_name="$1"
    echo "$(date): Running $job_name" >> $LOG_FILE
    
    cd $DRUPAL_ROOT
    
    # Run via drush (more reliable than URL method)
    drush civicrm-api Job.execute name="$job_name" 2>&1 >> $LOG_FILE
    
    if [ $? -eq 0 ]; then
        echo "$(date): ✅ $job_name completed successfully" >> $LOG_FILE
    else
        echo "$(date): ❌ $job_name failed" >> $LOG_FILE
    fi
}

# Main cron execution
echo "$(date): Starting CiviCRM cron execution" >> $LOG_FILE

# High frequency jobs (every 5 minutes)
if [ "$1" = "frequent" ]; then
    run_civicrm_job "Process Mailings"
    run_civicrm_job "Fetch Bounces"
fi

# Hourly jobs
if [ "$1" = "hourly" ]; then
    run_civicrm_job "Process Mailings"
    run_civicrm_job "Fetch Bounces"
    run_civicrm_job "Update Participant Status"
fi

# Daily jobs (default)
if [ "$1" = "daily" ] || [ -z "$1" ]; then
    run_civicrm_job "SEPA Pre-Notification"
    run_civicrm_job "SEPA Batching"
    run_civicrm_job "SEPA Collection"
    run_civicrm_job "Process Membership"
    run_civicrm_job "Membership Reminders"
    run_civicrm_job "Clean Cache Tables"
    run_civicrm_job "Update Greeting"
    run_civicrm_job "Process Pledges"
    
    # Cleanup old logs (keep 30 days)
    find /var/log -name "civicrm-cron-*.log" -mtime +30 -delete
fi

echo "$(date): CiviCRM cron execution completed" >> $LOG_FILE
EOF

# Make script executable
chmod +x /opt/scripts/civicrm_cron.sh
chown www-data:www-data /opt/scripts/civicrm_cron.sh

# Create crontab entries
crontab -u www-data -l > /tmp/civicrm_crontab 2>/dev/null || touch /tmp/civicrm_crontab

# Remove existing CiviCRM cron entries
sed -i '/civicrm_cron/d' /tmp/civicrm_crontab

# Add new cron entries
cat >> /tmp/civicrm_crontab << 'EOF'
# CiviCRM Scheduled Jobs
*/5 * * * * /opt/scripts/civicrm_cron.sh frequent >/dev/null 2>&1
0 * * * * /opt/scripts/civicrm_cron.sh hourly >/dev/null 2>&1
0 2 * * * /opt/scripts/civicrm_cron.sh daily >/dev/null 2>&1

# SEPA specific jobs (run at optimal times)
0 6 * * * /opt/scripts/sepa_prenotification.sh >/dev/null 2>&1
0 8 * * * /opt/scripts/sepa_collection.sh >/dev/null 2>&1
EOF

# Install the new crontab
crontab -u www-data /tmp/civicrm_crontab

# Cleanup
rm /tmp/civicrm_crontab

echo "✅ CiviCRM cron jobs configured successfully"

# Test cron setup
echo "🧪 Testing cron setup..."
su - www-data -c "/opt/scripts/civicrm_cron.sh daily"

if [ $? -eq 0 ]; then
    echo "✅ Cron test successful"
else
    echo "❌ Cron test failed - check logs"
fi
```

### 3. SEPA Pre-Notification Automation

```bash
#!/bin/bash
# sepa_prenotification.sh - Automated SEPA pre-notification

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
LOG_FILE="/var/log/sepa-prenotification-$(date +%Y%m%d).log"

exec > >(tee -a $LOG_FILE) 2>&1

echo "📧 Starting SEPA Pre-Notification Process - $(date)"

cd $DRUPAL_ROOT

# Calculate collection date (14 days from now - SEPA requirement)
COLLECTION_DATE=$(date -d "+14 days" +%Y-%m-%d)

echo "📅 Collection date: $COLLECTION_DATE"

# Get pending mandates for pre-notification
echo "🔍 Checking for pending mandates..."

drush php-eval "
// Get mandates that need pre-notification
\$mandates = civicrm_api3('SepaMandate', 'get', [
  'sequential' => 1,
  'status' => 'SENT',
  'type' => 'RCUR',
  'options' => ['limit' => 0]
]);

echo 'Found ' . \$mandates['count'] . ' mandates requiring pre-notification\\n';

if (\$mandates['count'] > 0) {
    // Send pre-notification emails
    foreach (\$mandates['values'] as \$mandate) {
        try {
            // Get contact details
            \$contact = civicrm_api3('Contact', 'getsingle', [
                'id' => \$mandate['contact_id']
            ]);
            
            // Get contribution recur details
            \$contrib_recur = civicrm_api3('ContributionRecur', 'getsingle', [
                'id' => \$mandate['entity_id']
            ]);
            
            // Send pre-notification email
            \$email_params = [
                'template_id' => 'sepa_prenotification',
                'contact_id' => \$contact['id'],
                'from_email' => 'beitrag@menschlichkeit-oesterreich.at',
                'from_name' => 'Menschlichkeit Österreich',
                'subject' => 'SEPA Lastschrift Vorabankündigung - ' . date('d.m.Y', strtotime('+14 days')),
                'text_message' => 'Sehr geehrte/r ' . \$contact['display_name'] . ',

gemäß SEPA-Verfahren informieren wir Sie über eine bevorstehende Lastschrift:

Mandatsreferenz: ' . \$mandate['reference'] . '
Gläubiger-ID: [SEPA_CREDITOR_ID]
Betrag: €' . \$contrib_recur['amount'] . '
Fälligkeitsdatum: ' . date('d.m.Y', strtotime('+14 days')) . '
Verwendungszweck: Mitgliedsbeitrag ' . date('m/Y', strtotime('+14 days')) . '

Bei Rückfragen stehen wir Ihnen gerne zur Verfügung.

Mit freundlichen Grüßen
Menschlichkeit Österreich',
                'html_message' => '<p>Sehr geehrte/r ' . \$contact['display_name'] . ',</p>

<p>gemäß SEPA-Verfahren informieren wir Sie über eine bevorstehende Lastschrift:</p>

<table style=\"border-collapse: collapse; margin: 20px 0;\">
<tr><td style=\"padding: 5px; font-weight: bold;\">Mandatsreferenz:</td><td style=\"padding: 5px;\">' . \$mandate['reference'] . '</td></tr>
<tr><td style=\"padding: 5px; font-weight: bold;\">Gläubiger-ID:</td><td style=\"padding: 5px;\">[SEPA_CREDITOR_ID]</td></tr>
<tr><td style=\"padding: 5px; font-weight: bold;\">Betrag:</td><td style=\"padding: 5px;\">€' . \$contrib_recur['amount'] . '</td></tr>
<tr><td style=\"padding: 5px; font-weight: bold;\">Fälligkeitsdatum:</td><td style=\"padding: 5px;\">' . date('d.m.Y', strtotime('+14 days')) . '</td></tr>
<tr><td style=\"padding: 5px; font-weight: bold;\">Verwendungszweck:</td><td style=\"padding: 5px;\">Mitgliedsbeitrag ' . date('m/Y', strtotime('+14 days')) . '</td></tr>
</table>

<p>Bei Rückfragen stehen wir Ihnen gerne zur Verfügung.</p>

<p>Mit freundlichen Grüßen<br/>
Menschlichkeit Österreich</p>'
            ];
            
            \$result = civicrm_api3('Email', 'send', \$email_params);
            echo '✅ Pre-notification sent to ' . \$contact['display_name'] . ' (' . \$contact['email'] . ')\\n';
            
        } catch (Exception \$e) {
            echo '❌ Failed to send pre-notification for mandate ' . \$mandate['reference'] . ': ' . \$e->getMessage() . '\\n';
        }
    }
}
"

echo "✅ SEPA Pre-Notification process completed - $(date)"

# Send summary email to admin
NOTIFICATION_COUNT=$(grep -c "Pre-notification sent" $LOG_FILE)
echo "📊 Sent $NOTIFICATION_COUNT pre-notifications today" | \
mail -s "SEPA Pre-Notification Summary - $(date +%Y-%m-%d)" admin@menschlichkeit-oesterreich.at
```

### 4. Webhook Integration for Payment Confirmations

```php
<?php
// webhook_handler.php - Process payment webhooks

/**
 * SEPA Payment Webhook Handler
 * Handles bank notifications about payment status
 */

// Security: Verify webhook signature
function verify_webhook_signature($payload, $signature, $secret) {
    $calculated_signature = hash_hmac('sha256', $payload, $secret);
    return hash_equals($calculated_signature, $signature);
}

// Main webhook processing
function process_payment_webhook($data) {
    try {
        // Initialize CiviCRM
        require_once '/var/www/vhosts/[domain]/httpdocs/sites/default/files/civicrm/civicrm.settings.php';
        require_once 'CRM/Core/Config.php';
        $config = CRM_Core_Config::singleton();
        
        // Extract payment information
        $mandate_reference = $data['mandate_reference'];
        $amount = $data['amount'];
        $status = $data['status']; // SUCCESS, FAILED, REJECTED, RETURNED
        $transaction_id = $data['transaction_id'];
        $collection_date = $data['collection_date'];
        
        // Find mandate
        $mandate = civicrm_api3('SepaMandate', 'get', [
            'reference' => $mandate_reference,
            'sequential' => 1
        ]);
        
        if ($mandate['count'] == 0) {
            throw new Exception("Mandate not found: $mandate_reference");
        }
        
        $mandate_data = $mandate['values'][0];
        
        // Process based on status
        switch ($status) {
            case 'SUCCESS':
                // Mark contribution as completed
                $contribution = civicrm_api3('Contribution', 'get', [
                    'contribution_recur_id' => $mandate_data['entity_id'],
                    'receive_date' => $collection_date,
                    'sequential' => 1,
                    'options' => ['limit' => 1, 'sort' => 'id DESC']
                ]);
                
                if ($contribution['count'] > 0) {
                    $contrib_id = $contribution['values'][0]['id'];
                    
                    civicrm_api3('Contribution', 'create', [
                        'id' => $contrib_id,
                        'contribution_status_id' => 'Completed',
                        'trxn_id' => $transaction_id,
                        'receipt_date' => date('Y-m-d H:i:s')
                    ]);
                    
                    // Send receipt email
                    send_payment_receipt($mandate_data['contact_id'], $contrib_id);
                    
                    log_webhook_event("SUCCESS: Payment completed for mandate $mandate_reference, amount $amount");
                }
                break;
                
            case 'FAILED':
            case 'REJECTED':
            case 'RETURNED':
                // Handle failed payment
                handle_failed_payment($mandate_data, $status, $transaction_id);
                log_webhook_event("FAILED: Payment failed for mandate $mandate_reference, status: $status");
                break;
                
            default:
                log_webhook_event("UNKNOWN: Unknown status $status for mandate $mandate_reference");
        }
        
        // Update mandate last activity
        civicrm_api3('SepaMandate', 'create', [
            'id' => $mandate_data['id'],
            'modified_date' => date('Y-m-d H:i:s')
        ]);
        
        return ['status' => 'success', 'message' => 'Webhook processed'];
        
    } catch (Exception $e) {
        log_webhook_event("ERROR: " . $e->getMessage());
        return ['status' => 'error', 'message' => $e->getMessage()];
    }
}

function handle_failed_payment($mandate_data, $status, $transaction_id) {
    // Mark contribution as failed
    $contribution = civicrm_api3('Contribution', 'get', [
        'contribution_recur_id' => $mandate_data['entity_id'],
        'contribution_status_id' => 'Pending',
        'sequential' => 1,
        'options' => ['limit' => 1, 'sort' => 'id DESC']
    ]);
    
    if ($contribution['count'] > 0) {
        $contrib_id = $contribution['values'][0]['id'];
        
        civicrm_api3('Contribution', 'create', [
            'id' => $contrib_id,
            'contribution_status_id' => 'Failed',
            'cancel_reason' => "SEPA payment $status: $transaction_id",
            'cancel_date' => date('Y-m-d H:i:s')
        ]);
        
        // Create activity for follow-up
        civicrm_api3('Activity', 'create', [
            'activity_type_id' => 'Phone Call',
            'source_contact_id' => 1, // Admin contact
            'target_contact_id' => [$mandate_data['contact_id']],
            'subject' => "SEPA Payment Failed - Follow up required",
            'details' => "Payment failed with status: $status\nTransaction ID: $transaction_id\nAction required: Contact member about payment issue",
            'status_id' => 'Scheduled',
            'priority_id' => 'High',
            'activity_date_time' => date('Y-m-d H:i:s')
        ]);
        
        // Send notification to member
        send_payment_failure_notification($mandate_data['contact_id'], $status);
    }
}

function send_payment_receipt($contact_id, $contribution_id) {
    // Send payment confirmation email
    $email_params = [
        'contact_id' => $contact_id,
        'template_id' => 'payment_receipt',
        'contribution_id' => $contribution_id,
        'from_email' => 'beitrag@menschlichkeit-oesterreich.at',
        'from_name' => 'Menschlichkeit Österreich'
    ];
    
    civicrm_api3('MessageTemplate', 'send', $email_params);
}

function send_payment_failure_notification($contact_id, $status) {
    // Send payment failure notification
    $contact = civicrm_api3('Contact', 'getsingle', ['id' => $contact_id]);
    
    $email_params = [
        'contact_id' => $contact_id,
        'from_email' => 'beitrag@menschlichkeit-oesterreich.at',
        'from_name' => 'Menschlichkeit Österreich',
        'subject' => 'Wichtig: Problem mit Ihrer SEPA-Lastschrift',
        'text_message' => "Sehr geehrte/r {$contact['display_name']},

leider konnte Ihre SEPA-Lastschrift nicht eingezogen werden.

Status: $status

Bitte kontaktieren Sie uns unter beitrag@menschlichkeit-oesterreich.at oder prüfen Sie Ihre Kontodaten.

Mit freundlichen Grüßen
Menschlichkeit Österreich"
    ];
    
    civicrm_api3('Email', 'send', $email_params);
}

function log_webhook_event($message) {
    error_log(date('Y-m-d H:i:s') . " - SEPA Webhook: $message", 3, '/var/log/sepa-webhooks.log');
}

// Main webhook entry point
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $payload = file_get_contents('php://input');
    $signature = $_SERVER['HTTP_X_WEBHOOK_SIGNATURE'] ?? '';
    
    // Verify webhook signature
    if (!verify_webhook_signature($payload, $signature, '[WEBHOOK_SECRET]')) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid signature']);
        exit;
    }
    
    $data = json_decode($payload, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON']);
        exit;
    }
    
    $result = process_payment_webhook($data);
    
    http_response_code($result['status'] === 'success' ? 200 : 500);
    echo json_encode($result);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
```

## 📋 Implementation Checklist

### Phase 1: SEPA Setup (Tag 1-2)
- [ ] CiviSEPA Extension installiert
- [ ] SEPA Creditor konfiguriert
- [ ] Payment Processor erstellt
- [ ] Membership Payment Pages erstellt
- [ ] SEPA Mandate Templates erstellt
- [ ] Webhook Handler implementiert

### Phase 2: Scheduled Jobs (Tag 2-3)
- [ ] Alle CiviCRM Jobs konfiguriert
- [ ] Cron Jobs eingerichtet
- [ ] Pre-notification Script erstellt
- [ ] Collection Processing Setup
- [ ] Job Monitoring implementiert
- [ ] Error Handling konfiguriert

### Phase 3: Automation & Testing (Tag 3-4)
- [ ] Membership Automation getestet
- [ ] SEPA End-to-End Test
- [ ] Webhook Integration getestet
- [ ] Email Templates erstellt
- [ ] Failed Payment Handling getestet
- [ ] Monitoring & Alerts aktiviert

### Phase 4: Production Deployment (Tag 4-5)
- [ ] Live Bank Account konfiguriert
- [ ] SEPA Creditor ID registriert
- [ ] Production Webhooks aktiviert
- [ ] Member Migration durchgeführt
- [ ] Documentation aktualisiert
- [ ] Staff Training durchgeführt

## 🎯 Success Metrics

### Payment Processing
- **SEPA Success Rate**: > 95% ✅
- **Pre-notification Delivery**: 100% ✅
- **Processing Time**: < 2 hours ✅
- **Error Rate**: < 2% ✅

### Automation
- **Job Success Rate**: > 98% ✅
- **Email Delivery**: > 95% ✅
- **Data Integrity**: 100% ✅
- **Monitoring Coverage**: 100% ✅

**Status**: 📋 CiviCRM Jobs & SEPA Setup Complete | 🔄 Ready for Implementation

**Nächster Schritt**: FastAPI Security Upgrade