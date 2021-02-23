:new, global: g = require"js"
:caches, :fetch, :Array = g

CACHE = 'Calcul mental-pwa'
FILES = new Array,
  './',
  './index.html',
  './static/fengariSW.js',
  './static/fengariWeb.js',
  './static/katex.min.js',
  './static/katex.min.css',
  './static/install_sw.js',
  './static/fonts/KaTeX_Main-BoldItalic.woff2',
  './static/fonts/KaTeX_Main-Bold.woff2',
  './static/fonts/KaTeX_Main-Italic.woff2',
  './static/fonts/KaTeX_Main-Regular.woff2',
  './static/icon.png',
  './static/favicon.ico'

once = (_f, fn) -> _f["then"] _f, fn

g\addEventListener 'install', (_, evt) -> evt\waitUntil once caches\open CACHE, (_a, cache) -> cache\addAll FILES

g\addEventListener 'fetch', (_, evt) ->
  request = evt.request
  evt\waitUntil once caches\open CACHE, (_a, cache) ->
    evt\respondWith cache\match request
    once fetch request, (_b, response) -> cache\put request, response
