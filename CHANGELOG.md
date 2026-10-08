# Changelog

## Unreleased

### Breaking

- Guest tickets use verified, expiring access. Requires escalated-laravel
  1.9.0+ or escalated-phoenix 0.2.0+; older permanent guest tokens and links
  built from them stop working (the server answers 404). See
  [docs/guest-access.md](docs/guest-access.md#upgrading-from-1x).
- `ApiService.createGuestTicket` requires `verificationId` and
  `verificationCode`.
- `ApiService.replyToGuestTicket` takes `accessToken:`; `getGuestTicket` takes
  the access grant.
- `guestTicketProvider` now holds `GuestTicketState`.
- Guest routes take the ticket reference. `Ticket.guestRouteReference` is
  deprecated and returns `reference`.
- Removed the `bookmark_notice` and `copy_link` strings.

### Added

- Email-code verification on `GuestCreateScreen`.
- `GuestLookupScreen` to find a ticket by reference and verified email and
  renew access.
- `GuestAccessService`, `GuestAccessStore` (`SecureGuestAccessStore`,
  `InMemoryGuestAccessStore`) and `EscalatedConfig.guestAccessStore`.
- `GuestAccessException` types for expired or refused access, 429 with
  `Retry-After`, invalid codes, and disabled guest tickets.
- `Ticket.guestAccessExpiresAt`.

### Fixed

- Ticket payload parsing tolerates the allow-listed guest payload: staff with
  `id` 0 and empty `email`, `metadata` sent as `[]`, missing ids, and statuses
  sent as plain strings.
- The debug request log no longer prints headers, and redacts guest grants
  and bearer tokens from URLs.
