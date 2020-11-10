var CACHE = 'Calcul mental-pwa';
var FILES = [
  './',
  './index.html',
  './fonts/KaTeX_Main-BoldItalic.woff2',
  './fonts/KaTeX_Main-Bold.woff2',
  './fonts/KaTeX_Main-Italic.woff2',
  './fonts/KaTeX_Main-Regular.woff2'
];

// On install, cache some resource.
self.addEventListener('install', function(evt) {
  console.log('The service worker is being installed.');
  evt.waitUntil(precache());
});

// On fetch, use cache but update the entry with the latest contents
// from the server.
self.addEventListener('fetch', function(evt) {
  console.log('The service worker is serving the asset.');
  // Try network and if it fails, go for the cached copy.
  evt.respondWith(fromNetwork(evt, 400).catch(() => {
    return fromCache(evt.request);
  }));
});

// Open a cache and use `addAll()` with an array of assets to add all of them
// to the cache. Return a promise resolving when all the assets are added.
async function precache() {
  const cache = await caches.open(CACHE);
  return await cache.addAll(FILES);
}

// Time limited network request. If the network fails or the response is not
// served before timeout, the promise is rejected.
function fromNetwork(evt, timeout) {
  return new Promise((fulfill, reject) => {
    // Reject in case of timeout.
    var timeoutId = setTimeout(reject, timeout);
    // Fulfill in case of success.
    fetch(evt.request).then(async function (response) {
      clearTimeout(timeoutId);
      const cache = await caches.open(CACHE);
      evt.waitUntil(
        cache.put(evt.request, response.clone())
      );
      fulfill(response);
    // Reject also if network fetch rejects.
    }, reject);
  });
}

// Open the cache where the assets were stored and search for the requested
// resource. Notice that in case of no matching, the promise still resolves
// but it does with `undefined` as value.
async function fromCache(request) {
  const cache = await caches.open(CACHE);
  const matching = await cache.match(request);
  return matching || Promise.reject('no-match');
}
