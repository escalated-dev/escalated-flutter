# Internationalization

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
