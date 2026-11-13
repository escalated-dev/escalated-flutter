# State management

## Providers

Escalated uses Riverpod for state management. The main providers are:

| Provider | Description |
|----------|-------------|
| `authProvider` | Authentication state, login/logout/register actions |
| `ticketsProvider` | Ticket list, creation, replies, and filtering |
| `kbProvider` | Knowledge base articles and search |
| `guestTicketProvider` | A guest ticket opened with its stored access grant |
| `themeProvider` | Theme configuration (colors, dark mode, locale) |

### Riverpod 3 and the legacy import

These providers are built on `StateNotifier`. Riverpod 3 moved `StateNotifier`
and `StateNotifierProvider` out of the default export into
`package:flutter_riverpod/legacy.dart`, where they remain supported, so the
provider files import from there.

They are legacy for a reason and the intended destination is
`Notifier`/`NotifierProvider`. That rewrite is deliberately not bundled with the
Riverpod 3 upgrade: it changes when initial state is produced (a `Notifier`
returns it from `build()` rather than a constructor, so constructor side effects
like `checkAuth()` have to be re-homed), and this package currently ships two
tests -- not enough of a net to catch a behaviour change in seven notifiers.
Widget coverage first, then the rewrite.
