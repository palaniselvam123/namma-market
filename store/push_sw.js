/* Push service worker for Namma MahaRaja order updates.
   Registered separately from Flutter's own service worker so a Flutter
   rebuild never clobbers it. */

self.addEventListener('push', (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_) {
    data = { title: 'Namma MahaRaja', body: event.data ? event.data.text() : '' };
  }

  const title = data.title || 'Order update';
  const options = {
    body: data.body || '',
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    tag: data.orderCode || 'order-update',
    renotify: true,
    data: { orderCode: data.orderCode || null, status: data.status || null },
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const scope = self.registration.scope;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((list) => {
      for (const client of list) {
        if (client.url.startsWith(scope) && 'focus' in client) {
          return client.focus();
        }
      }
      return clients.openWindow(scope);
    })
  );
});
