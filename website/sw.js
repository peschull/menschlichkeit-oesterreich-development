/**
 * Service Worker für Menschlichkeit Österreich Website
 * Bietet Offline-Funktionalität und Performance-Verbesserungen
 */

const CACHE_NAME = 'menschlichkeit-v1.0.0';
const STATIC_CACHE = 'menschlichkeit-static-v1.0.0';
const DYNAMIC_CACHE = 'menschlichkeit-dynamic-v1.0.0';

// Assets die gecacht werden sollen
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/styles-optimized.css',
  '/assets/js/main-optimized.js',
  '/manifest.json',

  // Bootstrap CDN Assets
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css',
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js',
  'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.min.css',

  // Fonts
  'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap',

  // Offline fallback page
  '/offline.html',
];

// URLs die nicht gecacht werden sollen
const EXCLUDE_URLS = ['/admin', '/api/', 'analytics', 'gtag', 'google-analytics'];

/* ===== INSTALLATION ===== */
self.addEventListener('install', event => {
  console.log('[SW] Installing service worker...');

  event.waitUntil(
    caches
      .open(STATIC_CACHE)
      .then(cache => {
        console.log('[SW] Precaching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        console.log('[SW] Installation complete');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('[SW] Installation failed:', error);
      })
  );
});

/* ===== ACTIVATION ===== */
self.addEventListener('activate', event => {
  console.log('[SW] Activating service worker...');

  event.waitUntil(
    Promise.all([
      // Cleanup old caches
      caches.keys().then(cacheNames => {
        return Promise.all(
          cacheNames
            .filter(cacheName => {
              return cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE;
            })
            .map(cacheName => {
              console.log('[SW] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            })
        );
      }),

      // Take control of all pages
      self.clients.claim(),
    ]).then(() => {
      console.log('[SW] Activation complete');
    })
  );
});

/* ===== FETCH HANDLING ===== */
self.addEventListener('fetch', event => {
  const requestUrl = new URL(event.request.url);

  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip excluded URLs
  if (EXCLUDE_URLS.some(exclude => requestUrl.href.includes(exclude))) {
    return;
  }

  // Handle different types of requests
  if (isStaticAsset(event.request)) {
    event.respondWith(handleStaticAsset(event.request));
  } else if (isApiRequest(event.request)) {
    event.respondWith(handleApiRequest(event.request));
  } else if (isNavigationRequest(event.request)) {
    event.respondWith(handleNavigationRequest(event.request));
  } else {
    event.respondWith(handleDynamicRequest(event.request));
  }
});

/* ===== REQUEST HANDLERS ===== */

// Static Assets (Cache First Strategy)
function handleStaticAsset(request) {
  return caches
    .match(request)
    .then(cachedResponse => {
      if (cachedResponse) {
        return cachedResponse;
      }

      return fetch(request).then(networkResponse => {
        if (networkResponse.ok) {
          const responseClone = networkResponse.clone();
          caches.open(STATIC_CACHE).then(cache => cache.put(request, responseClone));
        }
        return networkResponse;
      });
    })
    .catch(() => {
      console.log('[SW] Static asset fetch failed:', request.url);
      return new Response('Asset not available offline', {
        status: 503,
        statusText: 'Service Unavailable',
      });
    });
}

// API Requests (Network First Strategy)
function handleApiRequest(request) {
  return fetch(request)
    .then(networkResponse => {
      if (networkResponse.ok) {
        const responseClone = networkResponse.clone();
        caches.open(DYNAMIC_CACHE).then(cache => cache.put(request, responseClone));
      }
      return networkResponse;
    })
    .catch(() => {
      return caches.match(request).then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }
        return new Response(
          JSON.stringify({
            error: 'API not available offline',
            message: 'Please check your internet connection',
          }),
          {
            status: 503,
            statusText: 'Service Unavailable',
            headers: { 'Content-Type': 'application/json' },
          }
        );
      });
    });
}

// Navigation Requests (Stale While Revalidate)
function handleNavigationRequest(request) {
  return caches.match(request).then(cachedResponse => {
    const networkFetch = fetch(request)
      .then(networkResponse => {
        if (networkResponse.ok) {
          const responseClone = networkResponse.clone();
          caches.open(DYNAMIC_CACHE).then(cache => cache.put(request, responseClone));
        }
        return networkResponse;
      })
      .catch(() => {
        // Fallback zu Offline-Seite
        return caches.match('/offline.html');
      });

    return cachedResponse || networkFetch;
  });
}

// Dynamic Content (Network First with Cache Fallback)
function handleDynamicRequest(request) {
  return fetch(request)
    .then(networkResponse => {
      if (networkResponse.ok) {
        const responseClone = networkResponse.clone();
        caches.open(DYNAMIC_CACHE).then(cache => {
          // Cleanup cache wenn zu groß
          limitCacheSize(cache, 50);
          return cache.put(request, responseClone);
        });
      }
      return networkResponse;
    })
    .catch(() => {
      return caches.match(request);
    });
}

/* ===== HELPER FUNCTIONS ===== */

function isStaticAsset(request) {
  const url = new URL(request.url);
  return (
    url.pathname.includes('/assets/') ||
    url.pathname.includes('/styles') ||
    url.pathname.includes('.css') ||
    url.pathname.includes('.js') ||
    url.pathname.includes('.woff') ||
    url.pathname.includes('.woff2') ||
    url.hostname.includes('cdn.jsdelivr.net') ||
    url.hostname.includes('fonts.googleapis.com') ||
    url.hostname.includes('fonts.gstatic.com')
  );
}

function isApiRequest(request) {
  const url = new URL(request.url);
  return (
    url.pathname.includes('/api/') ||
    url.pathname.includes('/contact') ||
    request.headers.get('content-type')?.includes('application/json')
  );
}

function isNavigationRequest(request) {
  return (
    request.mode === 'navigate' ||
    (request.method === 'GET' && request.headers.get('accept')?.includes('text/html'))
  );
}

// Cache size limiter
function limitCacheSize(cache, maxItems) {
  cache.keys().then(keys => {
    if (keys.length > maxItems) {
      cache.delete(keys[0]).then(() => {
        limitCacheSize(cache, maxItems);
      });
    }
  });
}

/* ===== BACKGROUND SYNC ===== */
self.addEventListener('sync', event => {
  console.log('[SW] Background sync triggered:', event.tag);

  if (event.tag === 'contact-form') {
    event.waitUntil(syncContactForm());
  }
});

async function syncContactForm() {
  try {
    // Hier würde die tatsächliche Synchronisierung stattfinden
    console.log('[SW] Syncing contact form data...');

    // Beispiel: Daten aus IndexedDB holen und an Server senden
    const pendingForms = await getPendingContactForms();

    for (const form of pendingForms) {
      await submitContactForm(form);
      await removePendingForm(form.id);
    }

    console.log('[SW] Contact form sync complete');
  } catch (error) {
    console.error('[SW] Contact form sync failed:', error);
  }
}

// Placeholder functions for contact form sync
async function getPendingContactForms() {
  // In einer echten Implementierung würde hier IndexedDB verwendet
  return [];
}

async function submitContactForm(formData) {
  // In einer echten Implementierung würde hier der API-Call stattfinden
  console.log('[SW] Submitting form:', formData);
}

async function removePendingForm(id) {
  // In einer echten Implementierung würde hier aus IndexedDB gelöscht
  console.log('[SW] Removing pending form:', id);
}

/* ===== PUSH NOTIFICATIONS ===== */
self.addEventListener('push', event => {
  console.log('[SW] Push notification received');

  const options = {
    body: 'Neue Nachrichten von Menschlichkeit Österreich',
    icon: '/assets/icons/android-chrome-192x192.png',
    badge: '/assets/icons/badge-72x72.png',
    tag: 'menschlichkeit-notification',
    data: {
      url: '/',
    },
    actions: [
      {
        action: 'open',
        title: 'Öffnen',
      },
      {
        action: 'close',
        title: 'Schließen',
      },
    ],
  };

  if (event.data) {
    const data = event.data.json();
    options.body = data.message || options.body;
    options.data.url = data.url || options.data.url;
  }

  event.waitUntil(self.registration.showNotification('Menschlichkeit Österreich', options));
});

self.addEventListener('notificationclick', event => {
  console.log('[SW] Notification clicked:', event.notification.tag);

  event.notification.close();

  if (event.action === 'open') {
    const url = event.notification.data?.url || '/';

    event.waitUntil(
      clients.matchAll({ type: 'window' }).then(clientList => {
        // Existierendes Fenster fokussieren oder neues öffnen
        for (const client of clientList) {
          if (client.url === url && 'focus' in client) {
            return client.focus();
          }
        }

        if (clients.openWindow) {
          return clients.openWindow(url);
        }
      })
    );
  }
});

/* ===== UPDATE HANDLING ===== */
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    console.log('[SW] Skipping waiting and activating new service worker');
    self.skipWaiting();
  }
});

/* ===== ERROR HANDLING ===== */
self.addEventListener('error', event => {
  console.error('[SW] Service Worker error:', event.error);
});

self.addEventListener('unhandledrejection', event => {
  console.error('[SW] Unhandled promise rejection:', event.reason);
});

console.log('[SW] Service Worker script loaded successfully');
