import 'package:dio/dio.dart';

/// A guest request the server refused for a reason the guest can act on.
///
/// Screens show [messageKey] through `AppLocalizations.t`.
sealed class GuestAccessException implements Exception {
  const GuestAccessException();

  /// An `AppLocalizations` key, or text the server already wrote.
  String get messageKey;
}

/// Why a guest needs to verify their email again.
enum GuestAccessRequiredReason {
  /// The device holds no access grant for this ticket. Includes links from
  /// before verified access: those carried a permanent token, which servers
  /// no longer accept.
  missing,

  /// The stored grant has run out.
  expired,

  /// The server refused the grant (404): it expired, was replaced by a newer
  /// verification, was revoked, or is a legacy permanent token.
  rejected,
}

/// The guest has no working access grant for the ticket. Ask them to verify
/// their email through a lookup to get a new one.
class GuestAccessRequiredException extends GuestAccessException {
  final String reference;
  final GuestAccessRequiredReason reason;

  const GuestAccessRequiredException(this.reference, this.reason);

  @override
  String get messageKey => 'guest_access_required';

  @override
  String toString() =>
      'GuestAccessRequiredException($reference, ${reason.name})';
}

/// Too many guest requests or code deliveries (429). Wait [retryAfter]
/// before trying again; null when the server did not say.
class GuestRateLimitedException extends GuestAccessException {
  final Duration? retryAfter;
  final String? serverMessage;

  const GuestRateLimitedException({this.retryAfter, this.serverMessage});

  /// `guest_rate_limited` takes a `{seconds}` placeholder; without a
  /// [retryAfter] the key is `guest_rate_limited_later`.
  @override
  String get messageKey =>
      retryAfter == null ? 'guest_rate_limited_later' : 'guest_rate_limited';

  @override
  String toString() => 'GuestRateLimitedException(retryAfter: $retryAfter)';
}

/// The verification code was wrong, expired, already used, or had too many
/// guesses (422 on `verification_code`). The guest should request a new code.
class GuestVerificationFailedException extends GuestAccessException {
  final String? serverMessage;

  const GuestVerificationFailedException([this.serverMessage]);

  @override
  String get messageKey => serverMessage ?? 'verification_invalid';

  @override
  String toString() => 'GuestVerificationFailedException($serverMessage)';
}

/// Guest tickets are switched off on this server (403).
class GuestTicketsDisabledException extends GuestAccessException {
  final String? serverMessage;

  const GuestTicketsDisabledException([this.serverMessage]);

  @override
  String get messageKey => serverMessage ?? 'guest_tickets_disabled';

  @override
  String toString() => 'GuestTicketsDisabledException($serverMessage)';
}

/// Reads a `Retry-After` header given in seconds. HTTP-date values are
/// rare on these endpoints and are read as unknown.
Duration? parseRetryAfter(String? value) {
  if (value == null) return null;
  final seconds = int.tryParse(value.trim());
  if (seconds == null || seconds < 0) return null;
  return Duration(seconds: seconds);
}

String? _message(Object? data) {
  if (data is! Map) return null;
  final message = data['message'];
  return message is String && message.trim().isNotEmpty ? message : null;
}

String? _verificationCodeError(Object? data) {
  if (data is! Map) return null;
  final errors = data['errors'];
  if (errors is! Map || !errors.containsKey('verification_code')) return null;
  final messages = errors['verification_code'];
  if (messages is List && messages.isNotEmpty && messages.first is String) {
    return messages.first as String;
  }
  if (messages is String) return messages;
  return '';
}

/// Maps a failed guest request to a [GuestAccessException], or null when it
/// is some other failure the caller should handle as before.
///
/// [reference] is the ticket the request was for; a 404 on a ticket request
/// means its grant was refused.
GuestAccessException? guestAccessErrorFrom(
  DioException error, {
  String? reference,
}) {
  final response = error.response;
  if (response == null) return null;
  final data = response.data;

  switch (response.statusCode) {
    case 429:
      return GuestRateLimitedException(
        retryAfter: parseRetryAfter(response.headers.value('retry-after')),
        serverMessage: _message(data),
      );
    case 404:
      if (reference != null) {
        return GuestAccessRequiredException(
          reference,
          GuestAccessRequiredReason.rejected,
        );
      }
      return null;
    case 403:
      // A reply from an email that does not match the ticket is also a 403,
      // but only ticket requests pass a reference.
      if (reference == null) {
        return GuestTicketsDisabledException(_message(data));
      }
      return null;
    case 422:
      final codeError = _verificationCodeError(data);
      if (codeError != null) {
        return GuestVerificationFailedException(
          codeError.isEmpty ? null : codeError,
        );
      }
      return null;
  }
  return null;
}
