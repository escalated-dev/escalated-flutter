# Theming

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
