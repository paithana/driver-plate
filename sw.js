/* DriverCard service worker: the app page is network-first with an offline fallback; vendor runtimes/models are
   cache-first (saved on first use, or all at once by the page's offline-pack button). Third-party requests (AdSense) pass through. */
const SHELL = 'shell-v1';
const VENDOR = 'vendor-v1';   // bump when vendor/fetch.sh versions change (paths stay the same)
const SHELL_URLS = ['/', '/manifest.webmanifest', '/icons/icon-192.png', '/icons/icon-512.png', '/icons/icon-maskable-512.png', '/icons/apple-touch-icon.png'];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(SHELL).then((c) => c.addAll(SHELL_URLS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== SHELL && k !== VENDOR).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function networkFirst(request, cacheKey) {
  return fetch(request).then((res) => {
    if (res.ok) caches.open(SHELL).then((c) => c.put(cacheKey, res.clone()));
    return res;
  }).catch(() => caches.match(cacheKey, { ignoreSearch: true }));
}

function cacheFirst(request, cacheName) {
  return caches.match(request, { ignoreSearch: true }).then((hit) => hit || fetch(request).then((res) => {
    if (res.ok && res.status === 200) caches.open(cacheName).then((c) => c.put(request, res.clone()));
    return res;
  }));
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;
  if (req.mode === 'navigate' && (url.pathname === '/' || url.pathname === '/index.html')) {
    event.respondWith(networkFirst(req, '/'));
  } else if (url.pathname.startsWith('/vendor/')) {
    event.respondWith(cacheFirst(req, VENDOR));
  } else if (url.pathname.startsWith('/icons/') || url.pathname === '/manifest.webmanifest') {
    event.respondWith(cacheFirst(req, SHELL));
  }
});
