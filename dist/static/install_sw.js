if ('serviceWorker' in navigator) {window.addEventListener('load', () => {navigator.serviceWorker.register('sw.js').catch(err => {console.log(`Echec de l'enregistrement du Service Worker: ${err}`);});});}