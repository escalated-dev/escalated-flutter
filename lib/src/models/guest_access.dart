import 'json_read.dart';

/// What an emailed guest verification code will be spent on.
///
/// A code is bound to its purpose: a `ticket` code cannot authorize a
/// lookup, and the reverse.
enum GuestVerificationPurpose {
  /// Creating a guest ticket.
  ticket,

  /// Finding existing tickets by reference and getting fresh access to them.
  lookup,
}

/// The server's answer to a request for a verification code.
///
/// The code itself only ever reaches the recipient's mailbox. Send
/// [verificationId] back with the code the user types.
class GuestVerificationChallenge {
  final String verificationId;

  /// How long the code is valid for. Ten minutes on current servers.
  final Duration expiresIn;

  /// A generic, human-readable message from the server, if any.
  final String? message;

  /// The email the code was sent to.
  final String email;

  final GuestVerificationPurpose purpose;

  /// When the code was requested, by the device clock.
  final DateTime requestedAt;

  GuestVerificationChallenge({
    required this.verificationId,
    required this.expiresIn,
    required this.email,
    required this.purpose,
    this.message,
    DateTime? requestedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  factory GuestVerificationChallenge.fromJson(
    Map<String, dynamic> json, {
    required String email,
    required GuestVerificationPurpose purpose,
    DateTime? requestedAt,
  }) {
    final seconds = readInt(json['expires_in'], 600);
    return GuestVerificationChallenge(
      verificationId: readString(json['verification_id']),
      expiresIn: Duration(seconds: seconds > 0 ? seconds : 600),
      message: readOptionalString(json['message']),
      email: email,
      purpose: purpose,
      requestedAt: requestedAt,
    );
  }

  /// Whether the code has run out of time, by the device clock.
  bool get isExpired => DateTime.now().isAfter(requestedAt.add(expiresIn));
}

/// Verified, expiring access to one guest ticket.
///
/// The [token] is an opaque, encrypted credential issued after the guest
/// proved they can read the ticket's mailbox. Do not parse it, log it, or put
/// it in a link the user can share. It stops working at [expiresAt], when the
/// server rotates it (a later verification issues a new one), or when the
/// ticket's guest email changes. Get a new one through a lookup.
class GuestAccessGrant {
  /// The ticket reference the grant opens.
  final String reference;

  final String token;

  /// When the grant stops working. Null if the server did not say.
  final DateTime? expiresAt;

  /// The ticket subject, when the server returned it with the grant.
  final String? subject;

  /// The verified email the grant was issued for. Replies must come from it.
  final String? email;

  const GuestAccessGrant({
    required this.reference,
    required this.token,
    this.expiresAt,
    this.subject,
    this.email,
  });

  /// Reads a lookup result row, `{reference, subject, guest_access_token,
  /// expires_at}`, or a stored grant.
  factory GuestAccessGrant.fromJson(Map<String, dynamic> json) {
    return GuestAccessGrant(
      reference: readString(json['reference']),
      token: readString(json['guest_access_token'] ?? json['token']),
      expiresAt: readDate(
        json['expires_at'] ?? json['guest_access_expires_at'],
      ),
      subject: readOptionalString(json['subject']),
      email: readOptionalString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'guest_access_token': token,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (subject != null) 'subject': subject,
      if (email != null) 'email': email,
    };
  }

  /// Whether the grant has run out, by the device clock. A grant that has
  /// not run out can still be refused by the server if it was rotated or
  /// revoked.
  bool isExpiredAt(DateTime now) =>
      expiresAt != null && !now.isBefore(expiresAt!);

  bool get isExpired => isExpiredAt(DateTime.now());

  bool get isUsable => reference.isNotEmpty && token.isNotEmpty && !isExpired;

  GuestAccessGrant copyWith({String? email, String? subject}) {
    return GuestAccessGrant(
      reference: reference,
      token: token,
      expiresAt: expiresAt,
      subject: subject ?? this.subject,
      email: email ?? this.email,
    );
  }
}
