import 'package:dio/dio.dart';
import 'api_client.dart';
import 'guest_access_errors.dart';
import '../models/guest_access.dart';
import '../models/json_read.dart';
import '../models/article.dart';
import '../models/department.dart';
import '../models/paginated_response.dart';
import '../models/tag.dart';
import '../models/ticket.dart';
import '../models/ticket_summary.dart';
import '../models/user.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  Dio get _dio => _client.dio;

  // ─── Auth ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<User> getProfile() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<User> updateProfile({String? name, String? email}) async {
    final response = await _dio.put(
      '/auth/profile',
      data: {'name': ?name, 'email': ?email},
    );
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ─── Tickets ───────────────────────────────────────────────────────

  Future<PaginatedResponse<TicketSummary>> getTickets({
    int page = 1,
    String? search,
    String? status,
    String? priority,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
    };

    final response = await _dio.get('/tickets', queryParameters: queryParams);
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      TicketSummary.fromJson,
    );
  }

  Future<Ticket> getTicket(String reference) async {
    final response = await _dio.get('/tickets/$reference');
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Ticket> createTicket({
    required String subject,
    required String description,
    String? priority,
    int? departmentId,
    List<String>? attachmentPaths,
  }) async {
    final formData = FormData.fromMap({
      'subject': subject,
      'description': description,
      'priority': ?priority,
      'department_id': ?departmentId,
    });

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(
          MapEntry(
            'attachments[$i]',
            await MultipartFile.fromFile(attachmentPaths[i]),
          ),
        );
      }
    }

    final response = await _dio.post('/tickets', data: formData);
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> replyToTicket({
    required String reference,
    required String body,
    List<String>? attachmentPaths,
  }) async {
    final formData = FormData.fromMap({'body': body});

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(
          MapEntry(
            'attachments[$i]',
            await MultipartFile.fromFile(attachmentPaths[i]),
          ),
        );
      }
    }

    final response = await _dio.post(
      '/tickets/$reference/replies',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Ticket> closeTicket(String reference) async {
    final response = await _dio.post('/tickets/$reference/close');
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Ticket> reopenTicket(String reference) async {
    final response = await _dio.post('/tickets/$reference/reopen');
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> rateTicket({
    required String reference,
    required int rating,
    String? comment,
  }) async {
    await _dio.post(
      '/tickets/$reference/rate',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  // ─── Knowledge Base ────────────────────────────────────────────────

  Future<PaginatedResponse<Article>> getArticles({
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
      'category_id': ?categoryId,
    };

    final response = await _dio.get(
      '/kb/articles',
      queryParameters: queryParams,
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      Article.fromJson,
    );
  }

  Future<Article> getArticle(String slug) async {
    final response = await _dio.get('/kb/articles/$slug');
    return Article.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> rateArticle({
    required String slug,
    required bool helpful,
  }) async {
    await _dio.post('/kb/articles/$slug/rate', data: {'helpful': helpful});
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dio.get('/kb/categories');
    return (response.data['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  // ─── Tags ─────────────────────────────────────────────────────────

  Future<List<Tag>> getTags() async {
    final response = await _dio.get('/tags');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data
        .map((json) => Tag.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ─── Token Validation ────────────────────────────────────────────

  Future<User> validateToken() async {
    final response = await _dio.post('/auth/validate');
    return User.fromJson(
      (response.data['data'] ?? response.data) as Map<String, dynamic>,
    );
  }

  // ─── Departments ───────────────────────────────────────────────────

  Future<List<Department>> getDepartments() async {
    final response = await _dio.get('/departments');
    return (response.data['data'] as List<dynamic>)
        .map((d) => Department.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // ─── Guest ─────────────────────────────────────────────────────────
  //
  // Guest access is verified and expiring. The guest proves they can read
  // their mailbox with an emailed code, and the server answers with an
  // opaque access grant for the ticket. The grant goes in the existing
  // `/guest/tickets/{token}` route segment. Most apps use
  // `GuestAccessService`, which stores grants per ticket, rather than these
  // calls directly.

  /// Asks the server to email a verification code to [email].
  ///
  /// Throws [GuestRateLimitedException] (429) when the client or mailbox has
  /// asked too often, and [GuestTicketsDisabledException] (403) when guest
  /// tickets are off.
  Future<GuestVerificationChallenge> requestGuestVerification({
    required String email,
    required GuestVerificationPurpose purpose,
  }) {
    return _guest(null, () async {
      final response = await _dio.post(
        '/guest/verification',
        data: {'email': email, 'purpose': purpose.name},
      );
      return GuestVerificationChallenge.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        email: email,
        purpose: purpose,
      );
    });
  }

  /// Creates a guest ticket with a `ticket`-purpose verification.
  ///
  /// The returned [Ticket] carries the new grant in
  /// [Ticket.guestAccessToken] and [Ticket.guestAccessExpiresAt].
  Future<Ticket> createGuestTicket({
    required String name,
    required String email,
    required String subject,
    required String description,
    required String verificationId,
    required String verificationCode,
    String? priority,
    int? departmentId,
    List<String>? attachmentPaths,
  }) {
    return _guest(null, () async {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'subject': subject,
        'description': description,
        'verification_id': verificationId,
        'verification_code': verificationCode,
        'priority': ?priority,
        'department_id': ?departmentId,
      });
      await _addAttachments(formData, attachmentPaths);

      final response = await _dio.post('/guest/tickets', data: formData);
      return Ticket.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    });
  }

  /// Finds the guest's tickets matching [reference] (an Escalated reference
  /// or a host-assigned external reference) with a `lookup`-purpose
  /// verification, and issues a fresh grant for each.
  ///
  /// The list may be empty; the code is spent either way. Issuing a grant
  /// replaces any earlier grant for that ticket.
  Future<List<GuestAccessGrant>> lookupGuestTickets({
    required String email,
    required String reference,
    required String verificationId,
    required String verificationCode,
  }) {
    return _guest(null, () async {
      final response = await _dio.post(
        '/guest/lookup',
        data: {
          'email': email,
          'reference': reference,
          'verification_id': verificationId,
          'verification_code': verificationCode,
        },
      );
      final body = response.data;
      final rows = body is Map ? body['data'] : body;
      return readMapList(rows)
          .map(GuestAccessGrant.fromJson)
          .where((grant) => grant.token.isNotEmpty)
          .map((grant) => grant.copyWith(email: email))
          .toList();
    });
  }

  /// Reads a guest ticket with its access grant.
  ///
  /// Throws [GuestAccessRequiredException] when the server refuses the grant
  /// (404): it expired or was replaced, or it is a pre-verification
  /// permanent token.
  Future<Ticket> getGuestTicket(String accessToken, {String? reference}) {
    return _guest(reference ?? '', () async {
      final response = await _dio.get(_guestTicketPath(accessToken));
      return Ticket.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    });
  }

  /// Replies to a guest ticket with its access grant. [email] must be the
  /// ticket's verified guest email.
  Future<Map<String, dynamic>> replyToGuestTicket({
    required String accessToken,
    required String body,
    required String email,
    String? reference,
    List<String>? attachmentPaths,
  }) {
    return _guest(reference ?? '', () async {
      final formData = FormData.fromMap({'body': body, 'email': email});
      await _addAttachments(formData, attachmentPaths);

      final response = await _dio.post(
        '${_guestTicketPath(accessToken)}/replies',
        data: formData,
      );
      final data = response.data;
      return data is Map ? Map<String, dynamic>.from(data) : {};
    });
  }

  String _guestTicketPath(String accessToken) =>
      '/guest/tickets/${Uri.encodeComponent(accessToken)}';

  Future<void> _addAttachments(
    FormData formData,
    List<String>? attachmentPaths,
  ) async {
    if (attachmentPaths == null) return;
    for (int i = 0; i < attachmentPaths.length; i++) {
      formData.files.add(
        MapEntry(
          'attachments[$i]',
          await MultipartFile.fromFile(attachmentPaths[i]),
        ),
      );
    }
  }

  /// Runs a guest request, turning refusals the guest can act on into
  /// [GuestAccessException]s. Anything else is rethrown unchanged.
  Future<T> _guest<T>(String? reference, Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      final mapped = guestAccessErrorFrom(e, reference: reference);
      if (mapped != null) throw mapped;
      rethrow;
    }
  }
}
