import '../models/guest_access.dart';
import '../models/ticket.dart';
import 'api_service.dart';
import 'guest_access_errors.dart';
import 'guest_access_store.dart';

/// The verified guest flow: request a code, spend it on a ticket or a
/// lookup, and keep the resulting access grant per ticket.
///
/// ```dart
/// final challenge = await guest.requestCode(
///   email: email,
///   purpose: GuestVerificationPurpose.ticket,
/// );
/// // The user reads the code from their mailbox.
/// final ticket = await guest.createTicket(
///   challenge: challenge,
///   code: code,
///   name: name,
///   subject: subject,
///   description: description,
/// );
/// final fresh = await guest.show(ticket.reference);
/// ```
///
/// When a grant runs out or the server refuses it, [show] and [reply] throw
/// [GuestAccessRequiredException]. Request a `lookup` code and call [lookup]
/// to get a new grant.
class GuestAccessService {
  GuestAccessService(this._api, this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ApiService _api;
  final GuestAccessStore _store;
  final DateTime Function() _clock;

  /// Emails a verification code for [purpose] to [email].
  Future<GuestVerificationChallenge> requestCode({
    required String email,
    required GuestVerificationPurpose purpose,
  }) {
    return _api.requestGuestVerification(email: email.trim(), purpose: purpose);
  }

  /// Creates a guest ticket and stores its access grant.
  Future<Ticket> createTicket({
    required GuestVerificationChallenge challenge,
    required String code,
    required String name,
    required String subject,
    required String description,
    String? priority,
    int? departmentId,
    List<String>? attachmentPaths,
  }) async {
    _checkPurpose(challenge, GuestVerificationPurpose.ticket);
    final ticket = await _api.createGuestTicket(
      name: name,
      email: challenge.email,
      subject: subject,
      description: description,
      verificationId: challenge.verificationId,
      verificationCode: code.trim(),
      priority: priority,
      departmentId: departmentId,
      attachmentPaths: attachmentPaths,
    );

    final token = ticket.guestAccessToken;
    if (token != null && token.isNotEmpty && ticket.reference.isNotEmpty) {
      await _store.write(
        GuestAccessGrant(
          reference: ticket.reference,
          token: token,
          expiresAt: ticket.guestAccessExpiresAt,
          subject: ticket.subject,
          email: challenge.email,
        ),
      );
    }
    return ticket;
  }

  /// Finds the guest's tickets matching [reference] and stores a fresh grant
  /// for each. Earlier grants for those tickets stop working.
  Future<List<GuestAccessGrant>> lookup({
    required GuestVerificationChallenge challenge,
    required String code,
    required String reference,
  }) async {
    _checkPurpose(challenge, GuestVerificationPurpose.lookup);
    final grants = await _api.lookupGuestTickets(
      email: challenge.email,
      reference: reference.trim(),
      verificationId: challenge.verificationId,
      verificationCode: code.trim(),
    );
    for (final grant in grants) {
      if (grant.reference.isNotEmpty) await _store.write(grant);
    }
    return grants;
  }

  /// The stored grant for [reference], if it has not run out. An expired
  /// grant is removed.
  Future<GuestAccessGrant?> grantFor(String reference) async {
    final grant = await _store.read(reference);
    if (grant == null) return null;
    if (grant.isExpiredAt(_clock())) {
      await _store.delete(reference);
      return null;
    }
    return grant;
  }

  /// Loads the guest ticket [reference] with its stored grant.
  Future<Ticket> show(String reference) async {
    final grant = await _requireGrant(reference);
    return _forgetOnRefusal(
      reference,
      () => _api.getGuestTicket(grant.token, reference: reference),
    );
  }

  /// Replies to the guest ticket [reference]. [email] defaults to the
  /// verified email the grant was issued for.
  Future<void> reply({
    required String reference,
    required String body,
    String? email,
    List<String>? attachmentPaths,
  }) async {
    final grant = await _requireGrant(reference);
    final from = (email == null || email.trim().isEmpty)
        ? grant.email
        : email.trim();
    if (from == null || from.isEmpty) {
      throw ArgumentError.value(email, 'email', 'An email is required');
    }
    await _forgetOnRefusal(
      reference,
      () => _api.replyToGuestTicket(
        accessToken: grant.token,
        reference: reference,
        body: body,
        email: from,
        attachmentPaths: attachmentPaths,
      ),
    );
  }

  /// Removes the stored grant for [reference].
  Future<void> forget(String reference) => _store.delete(reference);

  Future<GuestAccessGrant> _requireGrant(String reference) async {
    final stored = await _store.read(reference);
    if (stored == null || stored.token.isEmpty) {
      throw GuestAccessRequiredException(
        reference,
        GuestAccessRequiredReason.missing,
      );
    }
    if (stored.isExpiredAt(_clock())) {
      await _store.delete(reference);
      throw GuestAccessRequiredException(
        reference,
        GuestAccessRequiredReason.expired,
      );
    }
    return stored;
  }

  Future<T> _forgetOnRefusal<T>(
    String reference,
    Future<T> Function() request,
  ) async {
    try {
      return await request();
    } on GuestAccessRequiredException {
      await _store.delete(reference);
      throw GuestAccessRequiredException(
        reference,
        GuestAccessRequiredReason.rejected,
      );
    }
  }

  void _checkPurpose(
    GuestVerificationChallenge challenge,
    GuestVerificationPurpose expected,
  ) {
    if (challenge.purpose != expected) {
      throw ArgumentError.value(
        challenge.purpose,
        'challenge',
        'Expected a ${expected.name} verification',
      );
    }
  }
}
