import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import '../models/ticket_summary.dart';
import 'auth_provider.dart';

// Ticket list state
class TicketListState {
  final List<TicketSummary> tickets;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? statusFilter;
  final String? priorityFilter;

  const TicketListState({
    this.tickets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.statusFilter,
    this.priorityFilter,
  });

  TicketListState copyWith({
    List<TicketSummary>? tickets,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? statusFilter,
    String? priorityFilter,
  }) {
    return TicketListState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
    );
  }
}

class TicketListNotifier extends StateNotifier<TicketListState> {
  final Ref _ref;

  TicketListNotifier(this._ref) : super(const TicketListState());

  Future<void> loadTickets({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        tickets: [],
        hasMore: true,
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.getTickets(
        page: 1,
        search: state.searchQuery,
        status: state.statusFilter,
        priority: state.priorityFilter,
      );
      state = state.copyWith(
        tickets: response.data,
        isLoading: false,
        currentPage: response.currentPage,
        hasMore: response.hasMore,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to load tickets.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final api = _ref.read(apiServiceProvider);
      final nextPage = state.currentPage + 1;
      final response = await api.getTickets(
        page: nextPage,
        search: state.searchQuery,
        status: state.statusFilter,
        priority: state.priorityFilter,
      );
      state = state.copyWith(
        tickets: [...state.tickets, ...response.data],
        isLoadingMore: false,
        currentPage: response.currentPage,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setFilters({
    String? search,
    String? status,
    String? priority,
  }) {
    state = state.copyWith(
      searchQuery: search,
      statusFilter: status,
      priorityFilter: priority,
    );
    loadTickets(refresh: true);
  }

  void clearFilters() {
    state = const TicketListState();
    loadTickets(refresh: true);
  }
}

final ticketListProvider =
    StateNotifierProvider<TicketListNotifier, TicketListState>((ref) {
  return TicketListNotifier(ref);
});

// Ticket detail state
class TicketDetailState {
  final Ticket? ticket;
  final bool isLoading;
  final String? error;
  final bool isSendingReply;
  final bool isUpdating;

  const TicketDetailState({
    this.ticket,
    this.isLoading = false,
    this.error,
    this.isSendingReply = false,
    this.isUpdating = false,
  });

  TicketDetailState copyWith({
    Ticket? ticket,
    bool? isLoading,
    String? error,
    bool? isSendingReply,
    bool? isUpdating,
  }) {
    return TicketDetailState(
      ticket: ticket ?? this.ticket,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSendingReply: isSendingReply ?? this.isSendingReply,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class TicketDetailNotifier extends StateNotifier<TicketDetailState> {
  final Ref _ref;

  TicketDetailNotifier(this._ref) : super(const TicketDetailState());

  Future<void> loadTicket(String reference) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final ticket = await api.getTicket(reference);
      state = state.copyWith(ticket: ticket, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to load ticket.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<bool> sendReply({
    required String reference,
    required String body,
    List<String>? attachmentPaths,
  }) async {
    state = state.copyWith(isSendingReply: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.replyToTicket(
        reference: reference,
        body: body,
        attachmentPaths: attachmentPaths,
      );
      await loadTicket(reference);
      state = state.copyWith(isSendingReply: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isSendingReply: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to send reply.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSendingReply: false,
        error: 'An unexpected error occurred.',
      );
      return false;
    }
  }

  Future<bool> closeTicket(String reference) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final ticket = await api.closeTicket(reference);
      state = state.copyWith(ticket: ticket, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to close ticket.',
      );
      return false;
    }
  }

  Future<bool> reopenTicket(String reference) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final ticket = await api.reopenTicket(reference);
      state = state.copyWith(ticket: ticket, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to reopen ticket.',
      );
      return false;
    }
  }

  Future<bool> rateTicket({
    required String reference,
    required int rating,
    String? comment,
  }) async {
    try {
      final api = _ref.read(apiServiceProvider);
      await api.rateTicket(
        reference: reference,
        rating: rating,
        comment: comment,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final ticketDetailProvider =
    StateNotifierProvider<TicketDetailNotifier, TicketDetailState>((ref) {
  return TicketDetailNotifier(ref);
});

// Guest ticket detail
class GuestTicketNotifier extends StateNotifier<TicketDetailState> {
  final Ref _ref;

  GuestTicketNotifier(this._ref) : super(const TicketDetailState());

  Future<void> loadTicket(String reference) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final ticket = await api.getGuestTicket(reference);
      state = state.copyWith(ticket: ticket, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to load ticket.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<bool> sendReply({
    required String reference,
    required String body,
    required String email,
    List<String>? attachmentPaths,
  }) async {
    state = state.copyWith(isSendingReply: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.replyToGuestTicket(
        reference: reference,
        body: body,
        email: email,
        attachmentPaths: attachmentPaths,
      );
      await loadTicket(reference);
      state = state.copyWith(isSendingReply: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSendingReply: false,
        error: 'Failed to send reply.',
      );
      return false;
    }
  }
}

final guestTicketProvider =
    StateNotifierProvider<GuestTicketNotifier, TicketDetailState>((ref) {
  return GuestTicketNotifier(ref);
});
