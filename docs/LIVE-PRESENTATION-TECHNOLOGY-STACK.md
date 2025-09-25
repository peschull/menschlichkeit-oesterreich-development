# 🚀 Live-Presentation Technology Stack

## Multi-Domain Real-Time Architecture für menschlichkeit-oesterreich.at

---

## 🏗️ SYSTEM-ARCHITEKTUR

### 🌐 Multi-Domain Setup:

- **Hauptdomain:** menschlichkeit-oesterreich.at (WordPress Frontend)
- **API-Domain:** api.menschlichkeit-oesterreich.at (Laravel Backend)
- **CRM-Domain:** crm.menschlichkeit-oesterreich.at (CiviCRM Management)

### 🔄 Real-Time Communication Stack:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   WordPress     │◄──►│   Laravel API    │◄──►│    CiviCRM      │
│   (Frontend)    │    │  (Real-Time Hub) │    │ (Data Management)│
│                 │    │                  │    │                 │
│ - WebSocket     │    │ - Laravel Echo   │    │ - Event Hooks   │
│ - Server Events │    │ - Redis/Pusher   │    │ - Webhook API   │
│ - PWA Features  │    │ - Broadcasting   │    │ - Data Sync     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
              ▲                   ▲                       ▲
              │                   │                       │
              └───────────────────┼───────────────────────┘
                                  │
                    ┌──────────────────┐
                    │  Real-Time Users │
                    │ WebSocket Clients│
                    │ PWA Applications │
                    └──────────────────┘
```

---

## 🎯 CORE FEATURES

### 1. **Real-Time Content Updates**

- **Live WordPress Posts**: Sofortige Anzeige neuer Artikel
- **CiviCRM Event Updates**: Real-time Eventregistrierungen
- **Dynamic Content Sync**: Cross-Domain Content-Synchronisation
- **User Activity Streams**: Live-Updates von Benutzeraktivitäten

### 2. **Interactive Presentation System**

- **Live Slideshows**: WebSocket-basierte Präsentationssteuerung
- **Audience Participation**: Real-time Polling und Q&A
- **Multi-Screen Sync**: Synchronisierte Anzeige auf mehreren Geräten
- **Remote Control**: API-gesteuerte Präsentationsnavigation

### 3. **Progressive Web App (PWA)**

- **Offline Support**: Service Worker für Offline-Funktionalität
- **Push Notifications**: Cross-Browser Push-Messages
- **App-like Experience**: Installation auf Endgeräten möglich
- **Background Sync**: Offline-Aktionen werden nachsynchronisiert

---

## 🔧 TECHNISCHE IMPLEMENTIERUNG

### **Backend (Laravel API)** - api.menschlichkeit-oesterreich.at

#### WebSocket Server Setup:

```php
// config/broadcasting.php
'connections' => [
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'host' => 'api.menschlichkeit-oesterreich.at',
            'port' => 6001,
            'scheme' => 'https',
        ],
    ],
],
```

#### Real-Time Events:

```php
// app/Events/ContentUpdated.php
class ContentUpdated implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $content;
    public $domain;
    public $type;

    public function broadcastOn()
    {
        return new Channel('content-updates');
    }

    public function broadcastAs()
    {
        return 'content.updated';
    }
}
```

#### API Endpoints:

```php
// routes/api.php
Route::group(['prefix' => 'v1', 'middleware' => 'auth:sanctum'], function () {
    // Live Presentation Control
    Route::post('/presentation/slide/{id}', 'PresentationController@changeSlide');
    Route::get('/presentation/current', 'PresentationController@getCurrentSlide');

    // Real-Time Content Sync
    Route::post('/sync/wordpress', 'SyncController@wordpressUpdate');
    Route::post('/sync/civicrm', 'SyncController@civicrmUpdate');

    // User Activity
    Route::post('/activity/track', 'ActivityController@trackActivity');
    Route::get('/activity/live', 'ActivityController@getLiveActivity');
});
```

### **Frontend (WordPress)** - menschlichkeit-oesterreich.at

#### WebSocket Client Integration:

```javascript
// wp-content/themes/menschlichkeit/js/realtime.js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
  broadcaster: 'pusher',
  key: process.env.MIX_PUSHER_APP_KEY,
  wsHost: 'api.menschlichkeit-oesterreich.at',
  wsPort: 6001,
  wssPort: 6001,
  forceTLS: true,
  encrypted: true,
});

// Listen for content updates
window.Echo.channel('content-updates').listen('content.updated', data => {
  updateContentRealtime(data);
});
```

#### PWA Configuration:

```javascript
// wp-content/themes/menschlichkeit/sw.js (Service Worker)
const CACHE_NAME = 'menschlichkeit-v1';
const urlsToCache = [
  '/',
  '/wp-content/themes/menschlichkeit/style.css',
  '/wp-content/themes/menschlichkeit/js/app.js',
  '/wp-content/themes/menschlichkeit/images/logo.png',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

// Background sync for form submissions
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});
```

#### Web App Manifest:

```json
{
  "name": "Menschlichkeit Österreich",
  "short_name": "Menschlichkeit",
  "description": "Förderung von Menschlichkeit und sozialer Verantwortung",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1e40af",
  "icons": [
    {
      "src": "/wp-content/themes/menschlichkeit/images/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/wp-content/themes/menschlichkeit/images/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### **CiviCRM Integration** - crm.menschlichkeit-oesterreich.at

#### Webhook Configuration:

```php
// wp-content/plugins/civicrm-webhook/civicrm-webhook.php
class CiviCRMWebhook {
    public function __construct() {
        add_action('civicrm_post', [$this, 'handleCiviCRMEvent'], 10, 4);
    }

    public function handleCiviCRMEvent($op, $objectName, $objectId, $objectRef) {
        $data = [
            'operation' => $op,
            'object' => $objectName,
            'id' => $objectId,
            'data' => $objectRef,
            'timestamp' => time()
        ];

        // Send to Laravel API for broadcasting
        wp_remote_post('https://api.menschlichkeit-oesterreich.at/api/v1/sync/civicrm', [
            'body' => json_encode($data),
            'headers' => [
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . get_option('api_token')
            ]
        ]);
    }
}
```

---

## 🎮 LIVE-PRESENTATION FEATURES

### **1. Remote Presentation Control**

```javascript
// Presentation Controller
class LivePresentation {
  constructor() {
    this.currentSlide = 0;
    this.totalSlides = 0;
    this.isPresenter = false;
    this.initWebSocket();
  }

  initWebSocket() {
    this.echo
      .channel('presentation-control')
      .listen('SlideChanged', data => {
        this.changeSlide(data.slideNumber);
      })
      .listen('PresentationStarted', data => {
        this.startPresentation(data.presentationId);
      });
  }

  nextSlide() {
    if (this.isPresenter) {
      axios.post('/api/v1/presentation/next-slide').then(response => {
        // WebSocket broadcast handled by server
      });
    }
  }
}
```

### **2. Audience Interaction System**

```javascript
// Real-time Polling
class AudienceInteraction {
  submitPoll(questionId, answer) {
    axios.post(`/api/v1/polls/${questionId}/vote`, { answer }).then(() => {
      // Real-time results via WebSocket
    });
  }

  askQuestion(question) {
    axios.post('/api/v1/questions', { question }).then(() => {
      // Question appears live for presenter
    });
  }
}
```

### **3. Multi-Screen Synchronization**

```javascript
// Device Sync
class ScreenSync {
  constructor() {
    this.deviceId = this.generateDeviceId();
    this.syncGroup = localStorage.getItem('syncGroup');
  }

  joinSyncGroup(groupId) {
    this.echo
      .join(`sync-group.${groupId}`)
      .here(users => {
        console.log('Connected devices:', users.length);
      })
      .joining(user => {
        console.log('Device joined:', user.deviceId);
      })
      .leaving(user => {
        console.log('Device left:', user.deviceId);
      });
  }
}
```

---

## 📊 PERFORMANCE & MONITORING

### **Real-Time Analytics**

- **Connection Monitoring**: Live WebSocket-Verbindungen
- **Performance Metrics**: Latenz und Durchsatz-Überwachung
- **Error Tracking**: Real-time Fehlerberichterstattung
- **User Engagement**: Live-Aktivitätstracking

### **Scalability Features**

- **Redis Clustering**: Skalierbare WebSocket-Sessions
- **CDN Integration**: Optimierte Content-Delivery
- **Database Optimization**: Optimierte Queries für Real-time
- **Caching Strategy**: Multi-Level Caching für Performance

---

## 🔒 SECURITY CONSIDERATIONS

### **WebSocket Security**

- **JWT Authentication**: Sichere WebSocket-Verbindungen
- **CORS Configuration**: Cross-Domain-Sicherheit
- **Rate Limiting**: DoS-Schutz für WebSocket-Events
- **Input Validation**: Sichere Event-Datenverarbeitung

### **PWA Security**

- **HTTPS Enforcement**: Sichere Service Worker
- **Content Security Policy**: XSS-Schutz
- **Secure Storage**: Verschlüsselte lokale Datenspeicherung

---

## 🚀 DEPLOYMENT STRATEGY

### **1. Server Requirements**

```bash
# Node.js für WebSocket Server
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Redis für Broadcasting
sudo apt-get install redis-server

# PM2 für Process Management
sudo npm install pm2@latest -g
```

### **2. WebSocket Server Setup**

```json
// ecosystem.config.js
module.exports = {
    apps: [{
        name: 'websocket-server',
        script: 'laravel-echo-server.js',
        instances: 2,
        exec_mode: 'cluster',
        env: {
            NODE_ENV: 'production',
            PORT: 6001
        }
    }]
};
```

### **3. Auto-Deployment Pipeline**

```yaml
# .github/workflows/deploy.yml
name: Deploy Live-Presentation Stack
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Server
        run: |
          scp -r ./build/* user@server:/var/www/html/
          ssh user@server 'pm2 restart websocket-server'
```

---

## 🎯 NEXT STEPS

### **Phase 1: Foundation** ✅ (Completed)

- Database Setup ✅
- Environment Configuration ✅
- Security Keys Generation ✅

### **Phase 2: Real-Time Implementation** 🔄 (Current)

- Laravel Echo Server Setup
- WebSocket Event Broadcasting
- WordPress Real-time Integration

### **Phase 3: Advanced Features** 📅 (Planned)

- PWA Implementation
- Multi-Screen Sync
- Advanced Analytics

### **Phase 4: Production Deployment** 🚀 (Final)

- Performance Optimization
- Security Hardening
- Monitoring Setup

---

**FAZIT:** Das Live-Presentation Technology Stack nutzt die Multi-Domain-Architektur optimal für real-time Features, die eine moderne, interaktive Web-Erfahrung schaffen! 🎯✨
