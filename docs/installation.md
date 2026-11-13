# Installation and configuration

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
