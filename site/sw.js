// Retires the old Nexpill web app.
//
// nexpill.superdavelab.com used to be a PWA whose service worker cached the
// whole app in visitors' browsers and kept serving it offline. Browsers
// check this same URL for updates, so this replacement installs over it,
// deletes every cache the old one made, unregisters itself, and reloads open
// tabs onto the plain landing page. Keep this file on the server for as long
// as anyone might still have the old app cached — there's no harm in forever.

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      await caches.delete(key);
    }
    await self.registration.unregister();
    const tabs = await self.clients.matchAll({ type: 'window' });
    for (const tab of tabs) {
      tab.navigate(tab.url);
    }
  })());
});
