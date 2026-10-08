import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/guest_access.dart';

/// Where guest access grants are kept, one per ticket reference.
///
/// Grants are bearer credentials for a ticket's correspondence, so the
/// default store keeps them in the platform keychain/keystore. Supply your
/// own through `EscalatedConfig.guestAccessStore` to use different storage.
abstract class GuestAccessStore {
  Future<GuestAccessGrant?> read(String reference);

  Future<void> write(GuestAccessGrant grant);

  Future<void> delete(String reference);
}

/// [GuestAccessStore] backed by [FlutterSecureStorage].
class SecureGuestAccessStore implements GuestAccessStore {
  SecureGuestAccessStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String keyPrefix = 'escalated_guest_access.';

  String _key(String reference) =>
      '$keyPrefix${base64Url.encode(utf8.encode(reference))}';

  @override
  Future<GuestAccessGrant?> read(String reference) async {
    final raw = await _storage.read(key: _key(reference));
    if (raw == null) return null;
    try {
      final grant = GuestAccessGrant.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (grant.reference == reference && grant.token.isNotEmpty) {
        return grant;
      }
    } catch (_) {
      // Unreadable entry: fall through and drop it.
    }
    await _storage.delete(key: _key(reference));
    return null;
  }

  @override
  Future<void> write(GuestAccessGrant grant) {
    return _storage.write(
      key: _key(grant.reference),
      value: jsonEncode(grant.toJson()),
    );
  }

  @override
  Future<void> delete(String reference) {
    return _storage.delete(key: _key(reference));
  }
}

/// [GuestAccessStore] that forgets everything when the app exits. For tests,
/// or apps that must not persist guest access.
class InMemoryGuestAccessStore implements GuestAccessStore {
  final Map<String, GuestAccessGrant> _grants = {};

  @override
  Future<GuestAccessGrant?> read(String reference) async => _grants[reference];

  @override
  Future<void> write(GuestAccessGrant grant) async {
    _grants[grant.reference] = grant;
  }

  @override
  Future<void> delete(String reference) async {
    _grants.remove(reference);
  }
}
