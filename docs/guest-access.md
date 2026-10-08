# Verified guest access

Escalated servers no longer accept permanent guest tokens. A guest proves they
can read their mailbox with an emailed code and receives an expiring access
grant for one ticket. This page covers what the Flutter package does with that
and what changes when you upgrade.

Server side, see escalated-laravel's `docs/guest-access.md` (1.9.0+). The same
contract is implemented by escalated-phoenix 0.2.0+.

## The flow

All endpoints are under the mobile API prefix (`/support/api/v1/mobile` by
default).

| Step | Request | Response |
| --- | --- | --- |
| Request a code | `POST guest/verification` `{email, purpose}`, purpose `ticket` or `lookup` | 202 `{verification_id, expires_in, message}` |
| Create a ticket | `POST guest/tickets` with the ticket fields plus `verification_id`, `verification_code` | 201 `data` ticket with `guest_access_token`, `guest_access_expires_at` |
| Look up tickets | `POST guest/lookup` `{email, reference, verification_id, verification_code}` | `data: [{reference, subject, guest_access_token, expires_at}]`, possibly empty |
| Read a ticket | `GET guest/tickets/{grant}` | `data` ticket |
| Reply | `POST guest/tickets/{grant}/replies` `{body, email}` | 201 |

Codes last ten minutes, allow five guesses, and are spent once. A lookup spends
its code even when nothing matches. `reference` in a lookup may be the
Escalated reference or a host-assigned external reference such as a tracking
number.

The grant is opaque and encrypted: do not parse it or assume a length. It
stops working when it expires (24 hours by default), when a later
verification issues a new one for the same ticket, or when the ticket's guest
email changes. The mobile API takes it in the existing route segment.

Attachment URLs in guest payloads are signed and expire with the grant. Open
them as given. The mobile API has no guest rating endpoint, so guest screens do
not offer CSAT.

## In the package

- `GuestAccessService` (`guestAccessServiceProvider`) runs the flow:
  `requestCode`, `createTicket`, `lookup`, `show`, `reply`, `forget`.
- `GuestAccessStore` keeps one `GuestAccessGrant` per ticket reference. The
  default, `SecureGuestAccessStore`, uses `flutter_secure_storage`. Pass your
  own as `EscalatedConfig.guestAccessStore`, or `InMemoryGuestAccessStore` to
  keep nothing on disk.
- Errors the guest can act on are `GuestAccessException`s:
  - `GuestAccessRequiredException`: no stored grant, an expired one, or a 404
    from the server. The stored grant is removed. Send the guest to
    `GuestLookupScreen`.
  - `GuestRateLimitedException`: a 429; `retryAfter` holds `Retry-After`.
  - `GuestVerificationFailedException`: the code was wrong, expired or used.
  - `GuestTicketsDisabledException`: guest tickets are off (403).
- The debug request log redacts `guest/tickets/{grant}` segments and bearer
  tokens. Hosts should do the same in their own logging and analytics.

## Upgrading from 1.x

- `ApiService.createGuestTicket` requires `verificationId` and
  `verificationCode`. Request them with `requestGuestVerification`, or use
  `GuestAccessService.createTicket`.
- `ApiService.getGuestTicket(token)` and `replyToGuestTicket(accessToken: ...)`
  take the access grant. `replyToGuestTicket`'s `reference:` parameter is now
  the ticket reference used for error reporting, not the token.
- `guestTicketProvider` holds a `GuestTicketState` (with `grant`,
  `accessRequired` and `retryAfter`) instead of `TicketDetailState`.
- Guest routes take the ticket reference. `Ticket.guestRouteReference` is
  deprecated and returns `reference`. Add `/guest/lookup` before
  `/guest/:reference`:

  ```dart
  GoRoute(
    path: '/guest/lookup',
    builder: (context, state) => GuestLookupScreen(
      initialReference: state.uri.queryParameters['reference'],
    ),
  ),
  GoRoute(
    path: '/guest/:reference',
    builder: (context, state) =>
        GuestTicketScreen(reference: state.pathParameters['reference']!),
  ),
  ```

- Saved links and deep links that carried a permanent token
  (`escalated://guest/<token>`) open `GuestTicketScreen` with no stored grant,
  which asks the guest to verify their email. The server answers 404 to the
  old token itself. Existing tickets are intact; the guest gets back in through
  a lookup with their ticket reference.
- `bookmark_notice` and `copy_link` are gone from the translation tables. The
  guest screen shows when access ends and copies the reference instead.
