# Escalated for Flutter

[![Tests](https://github.com/escalated-dev/escalated-flutter/actions/workflows/run-tests.yml/badge.svg)](https://github.com/escalated-dev/escalated-flutter/actions/workflows/run-tests.yml)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Views](https://hits.sh/github.com/escalated-dev/escalated-flutter.svg?style=flat&label=views&color=007ec6)](https://hits.sh/github.com/escalated-dev/escalated-flutter/)

A full-featured, embeddable support ticket UI for Flutter apps. Drop it into any Flutter project — get a complete customer-facing helpdesk with ticket management, knowledge base, guest access, and SLA tracking. Connects to the Escalated REST API.

> **[escalated.dev](https://escalated.dev)** — Learn more, view demos, and compare Cloud vs Self-Hosted options.

**One widget, full support experience.** Wrap your app with `EscalatedPlugin`, point it at your API, and every screen is ready — login, tickets, knowledge base, guest access. Customize colors, auth behavior, and locale with a single config object.

## Features

- **Ticket management** — Create, view, filter, and reply to support tickets with file attachments
- **Knowledge base** — Searchable article list with HTML rendering for self-service support
- **Guest tickets** — Anonymous ticket submission without requiring authentication
- **SLA tracking** — Real-time SLA countdown timers on ticket detail views
- **Satisfaction ratings** — Post-resolution CSAT ratings with star display
- **Auth hooks** — Override login, logout, register, and token retrieval to integrate with your existing auth
- **Riverpod state management** — Auth, tickets, knowledge base, and theme providers out of the box
- **GoRouter-compatible** — Drop screens into your existing GoRouter navigation tree
- **Host theming** — Screens take the app's `ThemeData`, light or dark, so they match its brand
- **i18n** — Localized in English, Spanish, French (with Canadian French) and German, errors and dates included
- **Configurable** — API base URL, auth hooks, primary color, border radius, dark mode, default locale

## Requirements

- Flutter 3.16+
- Dart 3.2+
- A running Escalated backend (Laravel, Rails, Django, AdonisJS, or WordPress)

## Quick Start

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  escalated:
    git:
      url: https://github.com/escalated-dev/escalated-flutter.git
```

Wrap your app with `EscalatedPlugin`:

```dart
import 'package:escalated/escalated.dart';

EscalatedPlugin(
  config: EscalatedConfig(
    apiBaseUrl: 'https://yourapp.com/support/api/v1/mobile',
  ),
  child: MaterialApp.router(...),
)
```

That's it — your app now has a full support ticket UI.

## Configuration

`EscalatedConfig` accepts the following options:

```dart
EscalatedConfig(
  apiBaseUrl: 'https://yourapp.com/support/api/v1/mobile',
  authHooks: myAuthHooks,
  primaryColor: Color(0xFF4F46E5),
  borderRadius: 12.0,
  darkMode: false,
  defaultLocale: 'en',
)
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `apiBaseUrl` | `String` | required | Base URL for the Escalated REST API |
| `authHooks` | `EscalatedAuthHooks?` | `null` | Custom auth hook overrides |
| `primaryColor` | `Color?` | `#4F46E5` | Primary action color for buttons and accents |
| `borderRadius` | `double?` | `8.0` | Border radius for cards, inputs, and buttons |
| `darkMode` | `bool?` | `false` | Enable dark theme |
| `defaultLocale` | `String?` | `'en'` | Default locale code (`en`, `es`, `fr`, `de`) |

## Theming

Every screen and widget takes its colours from the app's `ThemeData`, so they
match the host without configuration:

| Element | Comes from |
|---------|------------|
| Buttons, links, ticket references, selected chips | `colorScheme.primary` |
| New-ticket button | `floatingActionButtonTheme`, else `colorScheme.primary` / `onPrimary` |
| Cards, sheets, composer | `colorScheme.surface` and its `surfaceContainer*` tones |
| Body and secondary text | `colorScheme.onSurface`, `onSurfaceVariant` |
| Borders | `colorScheme.outlineVariant` |
| Errors | `colorScheme.error` / `onError` |

Status, priority and SLA badges keep fixed colours (`AppColors.statusColor`,
`priorityColor`, `slaRed`...), since the colour carries the meaning.
`EscalatedConfig.primaryColor` and `borderRadius` feed `AppTheme` and
`themeProvider` for apps that build their theme from Escalated's; they do not
override the app's own theme.

## Available Screens

| Screen | Description |
|--------|-------------|
| `LoginScreen` | Email/password login form |
| `RegisterScreen` | New account registration |
| `TicketListScreen` | Paginated ticket list with status filters |
| `CreateTicketScreen` | New ticket form with file attachments |
| `TicketDetailScreen` | Full ticket thread with replies and metadata |
| `KBListScreen` | Knowledge base article listing |
| `KBArticleScreen` | Single article view with HTML rendering |
| `GuestCreateScreen` | Anonymous ticket submission |
| `GuestTicketScreen` | Guest ticket view via token |
| `SettingsScreen` | User preferences and locale selection |
| `TicketFiltersScreen` | Advanced ticket filter controls |

## Available Widgets

| Widget | Description |
|--------|-------------|
| `StatusBadge` | Ticket status indicator |
| `PriorityBadge` | Priority level indicator |
| `SlaTimer` | SLA countdown display |
| `AttachmentList` | File attachment display |
| `FileDropzone` | Drag-and-drop file upload |
| `SatisfactionRating` | Star rating display and input |
| `ReplyThread` | Chronological message thread |
| `ReplyComposer` | Reply text input with attachments |
| `EmptyState` | Placeholder for empty lists |
| `LoadingShimmer` | Shimmer loading placeholder |
| `ErrorView` | Error state with retry action |

## Providers

Escalated uses Riverpod for state management. Four providers are available:

| Provider | Description |
|----------|-------------|
| `authProvider` | Authentication state, login/logout/register actions |
| `ticketsProvider` | Ticket list, creation, replies, and filtering |
| `kbProvider` | Knowledge base articles and search |
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

## Models

Nine models with full `fromJson` / `toJson` serialization are included for use with the REST API. All models map directly to the Escalated API response format.

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

## Internationalization

Every string on screen goes through `AppLocalizations`, including the errors
the providers report. Register the delegate alongside Flutter's:

```dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
)
```

| Code | Language |
|------|----------|
| `en` | English |
| `es` | Spanish |
| `fr` | French |
| `fr_CA` | Canadian French (overrides `fr` where usage differs, e.g. *courriel*) |
| `de` | German |

A string is looked up in the regional table (`fr_CA`), then the language
(`fr`), then English. Dates follow the app locale too; they use intl's date
names, which `GlobalMaterialLocalizations` loads.

Providers record a failure as a translation key (`failed_to_load_tickets`,
`unexpected_error`, ...) unless the server refused the request with a
`message` of its own (a 4xx), which is kept as the server wrote it.
`AppLocalizations.t` translates a key and passes other text through, so
`l10n.t(state.error!)` shows either correctly.

## Dependencies

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client for API requests |
| `flutter_riverpod` | State management |
| `go_router` | Navigation and routing |
| `flutter_secure_storage` | Secure token persistence |
| `flutter_html` | HTML rendering for knowledge base articles |
| `shimmer` | Loading placeholder animations |
| `file_picker` | File selection for attachments |
| `image_picker` | Image selection for attachments |
| `intl` | Internationalization and date formatting |

## Also Available For

| Framework | Package | Repository |
|-----------|---------|------------|
| Laravel | `escalated-dev/escalated-laravel` | [GitHub](https://github.com/escalated-dev/escalated-laravel) |
| Ruby on Rails | `escalated` (gem) | [GitHub](https://github.com/escalated-dev/escalated-rails) |
| Django | `escalated-django` | [GitHub](https://github.com/escalated-dev/escalated-django) |
| AdonisJS | `@escalated-dev/escalated-adonis` | [GitHub](https://github.com/escalated-dev/escalated-adonis) |
| WordPress | `escalated-wordpress` | [GitHub](https://github.com/escalated-dev/escalated-wordpress) |
| Vue UI | `@escalated-dev/escalated` | [GitHub](https://github.com/escalated-dev/escalated) |
| Flutter | `escalated` (Flutter) | [GitHub](https://github.com/escalated-dev/escalated-flutter) |
| React Native | `@escalated-dev/escalated-react-native` | [GitHub](https://github.com/escalated-dev/escalated-react-native) |

Same architecture, same REST API, same support experience — for every major framework.

## License

MIT - Copyright (c) Escalated.dev. See [LICENSE](LICENSE).
