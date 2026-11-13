# Authentication and guest access

## Auth Hooks

Auth hooks let you override default authentication behavior to integrate with your app's existing auth system:

```dart
EscalatedConfig(
  apiBaseUrl: 'https://yourapp.com/support/api/v1/mobile',
  authHooks: EscalatedAuthHooks(
    onLogin: (email, password) async {
      // Your custom login logic
      return yourAuthToken;
    },
    onLogout: () async {
      // Your custom logout logic
    },
    onRegister: (name, email, password) async {
      // Your custom registration logic
      return yourAuthToken;
    },
    getToken: () async {
      // Return the current auth token
      return await secureStorage.read(key: 'token');
    },
  ),
)
```

When no auth hooks are provided, Escalated uses its built-in Dio HTTP client with `flutter_secure_storage` for token persistence.

## Guest access

Guest tickets need the guest to prove they can read their mailbox. The server
emails an eight-digit code, the app sends it back with the ticket (or with a
lookup), and the server answers with an expiring access grant for that ticket.
`GuestAccessService` runs this flow and keeps each grant in the device's secure
storage, keyed by ticket reference. Grants never appear in routes or copied
links; guest routes take the ticket reference (`/guest/ESC-00042`).

When a grant runs out or the server refuses it, `GuestTicketScreen` asks the
guest to verify again and `GuestLookupScreen` issues a fresh one. A 429 is
reported with the server's `Retry-After`.

This needs a backend with verified guest access (escalated-laravel 1.9+,
escalated-phoenix 0.2+). **Upgrading from 1.x:** permanent guest tokens and
links built from them no longer work. Add a route for `/guest/lookup` before
`/guest/:reference`, and see [docs/guest-access.md](guest-access.md) for
the API changes.
