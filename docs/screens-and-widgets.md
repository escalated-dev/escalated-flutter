# Screens, widgets and models

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
| `GuestCreateScreen` | Guest ticket submission with email verification |
| `GuestTicketScreen` | Guest ticket view by reference, using the stored access grant |
| `GuestLookupScreen` | Find a guest ticket by reference and verified email; renews access |
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

## Models

Nine models with full `fromJson` / `toJson` serialization are included for use with the REST API. All models map directly to the Escalated API response format.
