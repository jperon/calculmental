const CACHE = 'Calcul mental-pwa';
const FILES = [
  './',
  './index.html',
  './fonts/KaTeX_Main-BoldItalic.woff2',
  './fonts/KaTeX_Main-Bold.woff2',
  './fonts/KaTeX_Main-Italic.woff2',
  './fonts/KaTeX_Main-Regular.woff2',
  './icon.png',
  './favicon.ico'
];

// On install, cache some resource.
self.addEventListener('install', function(evt) {
  console.log('The service worker is being installed.');
  // Open a cache and use `addAll()` with an array of assets to add all of them
  // to the cache. Ask the service worker to keep installing until the
  // returning promise resolves.
  evt.waitUntil(caches.open(CACHE).then(function (cache) {
    cache.addAll(FILES);
  }));
});

// On fetch, use cache but update the entry with the latest contents
// from the server.
self.addEventListener('fetch', function(evt) {
  console.log('The service worker is serving the asset.');
  // You can use `respondWith()` to answer ASAP...
  evt.respondWith(fromCache(evt.request));
  // ...and `waitUntil()` to prevent the worker to be killed until
  // the cache is updated.
  evt.waitUntil(update(evt.request));
});

// Open the cache where the assets were stored and search for the requested
// resource. Notice that in case of no matching, the promise still resolves
// but it does with `undefined` as value.
async function fromCache(request) {
  const cache = await caches.open(CACHE);
  return await cache.match(request);
}

// Update consists in opening the cache, performing a network request and
// storing the new response data.
async function update(request) {
  const cache = await caches.open(CACHE);
  const response = await fetch(request);
  await cache.put(request, response.clone());
  return response;
}
