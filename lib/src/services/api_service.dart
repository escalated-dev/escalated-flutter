import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/article.dart';
import '../models/department.dart';
import '../models/paginated_response.dart';
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
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<User> getProfile() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<User> updateProfile({
    String? name,
    String? email,
  }) async {
    final response = await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });
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
      if (priority != null) 'priority': priority,
      if (departmentId != null) 'department_id': departmentId,
    });

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(MapEntry(
          'attachments[$i]',
          await MultipartFile.fromFile(attachmentPaths[i]),
        ));
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
    final formData = FormData.fromMap({
      'body': body,
    });

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(MapEntry(
          'attachments[$i]',
          await MultipartFile.fromFile(attachmentPaths[i]),
        ));
      }
    }

    final response =
        await _dio.post('/tickets/$reference/replies', data: formData);
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
    await _dio.post('/tickets/$reference/rate', data: {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
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
      if (categoryId != null) 'category_id': categoryId,
    };

    final response = await _dio.get('/kb/articles', queryParameters: queryParams);
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
    await _dio.post('/kb/articles/$slug/rate', data: {
      'helpful': helpful,
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dio.get('/kb/categories');
    return (response.data['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  // ─── Departments ───────────────────────────────────────────────────

  Future<List<Department>> getDepartments() async {
    final response = await _dio.get('/departments');
    return (response.data['data'] as List<dynamic>)
        .map((d) => Department.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // ─── Guest ─────────────────────────────────────────────────────────

  Future<Ticket> createGuestTicket({
    required String name,
    required String email,
    required String subject,
    required String description,
    String? priority,
    int? departmentId,
    List<String>? attachmentPaths,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'subject': subject,
      'description': description,
      if (priority != null) 'priority': priority,
      if (departmentId != null) 'department_id': departmentId,
    });

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(MapEntry(
          'attachments[$i]',
          await MultipartFile.fromFile(attachmentPaths[i]),
        ));
      }
    }

    final response = await _dio.post('/guest/tickets', data: formData);
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Ticket> getGuestTicket(String reference) async {
    final response = await _dio.get('/guest/tickets/$reference');
    return Ticket.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> replyToGuestTicket({
    required String reference,
    required String body,
    required String email,
    List<String>? attachmentPaths,
  }) async {
    final formData = FormData.fromMap({
      'body': body,
      'email': email,
    });

    if (attachmentPaths != null) {
      for (int i = 0; i < attachmentPaths.length; i++) {
        formData.files.add(MapEntry(
          'attachments[$i]',
          await MultipartFile.fromFile(attachmentPaths[i]),
        ));
      }
    }

    final response =
        await _dio.post('/guest/tickets/$reference/replies', data: formData);
    return response.data as Map<String, dynamic>;
  }
}
