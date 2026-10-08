import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved StateNotifier/StateNotifierProvider into legacy.dart.
import 'package:flutter_riverpod/legacy.dart';
import '../models/guest_access.dart';
import '../models/ticket.dart';
import '../services/guest_access_errors.dart';
import '../services/guest_access_service.dart';
import '../services/guest_access_store.dart';
import 'auth_provider.dart';
import 'error_message.dart';

/// Where guest access grants are kept. `EscalatedPlugin` overrides this with
/// `EscalatedConfig.guestAccessStore`; the default is the secure keychain/
/// keystore.
final guestAccessStoreProvider = Provider<GuestAccessStore>((ref) {
  return SecureGuestAccessStore();
});

final guestAccessServiceProvider = Provider<GuestAccessService>((ref) {
  return GuestAccessService(
    ref.watch(apiServiceProvider),
    ref.watch(guestAccessStoreProvider),
  );
});

/// The `AppLocalizations` key (or server text) for a failed guest request.
String guestErrorKey(Object error, String fallbackKey) {
  if (error is GuestAccessException) return error.messageKey;
  if (error is DioException) return serverMessageOr(error, fallbackKey);
  return fallbackKey;
}

class GuestTicketState {
  final Ticket? ticket;

  /// The grant the ticket was loaded with: its expiry and verified email.
  final GuestAccessGrant? grant;
  final bool isLoading;
  final bool isSendingReply;
  final String? error;

  /// Set when there is no working grant for the ticket. The guest must
  /// verify their email again through a lookup.
  final GuestAccessRequiredReason? accessRequired;

  /// How long to wait after a 429, when the server said.
  final Duration? retryAfter;

  const GuestTicketState({
    this.ticket,
    this.grant,
    this.isLoading = false,
    this.isSendingReply = false,
    this.error,
    this.accessRequired,
    this.retryAfter,
  });

  bool get needsVerification => accessRequired != null;
}

class GuestTicketNotifier extends StateNotifier<GuestTicketState> {
  GuestTicketNotifier(this._ref) : super(const GuestTicketState());

  final Ref _ref;
  String? _reference;

  GuestAccessService get _guest => _ref.read(guestAccessServiceProvider);

  /// Opens the guest ticket [reference] with its stored grant.
  Future<void> loadTicket(String reference) async {
    if (_reference != reference) state = const GuestTicketState();
    _reference = reference;
    state = GuestTicketState(
      ticket: state.ticket,
      grant: state.grant,
      isLoading: true,
    );
    try {
      final ticket = await _guest.show(reference);
      final grant = await _guest.grantFor(reference);
      if (_reference != reference) return;
      state = GuestTicketState(ticket: ticket, grant: grant);
    } catch (e) {
      if (_reference != reference) return;
      state = _failed(e, 'failed_to_load_ticket', isLoading: false);
    }
  }

  Future<bool> sendReply({
    required String reference,
    required String body,
    String? email,
    List<String>? attachmentPaths,
  }) async {
    state = GuestTicketState(
      ticket: state.ticket,
      grant: state.grant,
      isSendingReply: true,
    );
    try {
      await _guest.reply(
        reference: reference,
        body: body,
        email: email,
        attachmentPaths: attachmentPaths,
      );
      await loadTicket(reference);
      return state.error == null && !state.needsVerification;
    } catch (e) {
      state = _failed(e, 'failed_to_send_reply', isLoading: false);
      return false;
    }
  }

  GuestTicketState _failed(
    Object error,
    String fallbackKey, {
    required bool isLoading,
  }) {
    if (error is GuestAccessRequiredException) {
      // The grant is gone: drop the correspondence it unlocked.
      return GuestTicketState(accessRequired: error.reason);
    }
    return GuestTicketState(
      ticket: state.ticket,
      grant: state.grant,
      isLoading: isLoading,
      error: guestErrorKey(error, fallbackKey),
      retryAfter: error is GuestRateLimitedException ? error.retryAfter : null,
    );
  }
}

final guestTicketProvider =
    StateNotifierProvider<GuestTicketNotifier, GuestTicketState>((ref) {
      return GuestTicketNotifier(ref);
    });
