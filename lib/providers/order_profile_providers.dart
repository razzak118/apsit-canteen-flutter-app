import 'package:canteen_user_app/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_user/order_ticket_dto.dart';
import '../models/order_user/user_response_dto.dart';
import 'service_providers.dart';

final myOrdersProvider = FutureProvider<List<OrderTicketDto>>((ref) async {
  return ref.read(userServiceProvider).getMyOrders();
});

final myProfileProvider = FutureProvider<UserResponseDto>((ref) async {
  return ref.read(userServiceProvider).getMyProfile();
});

// Pagination state for orders
class OrdersPaginationState {
  final List<OrderTicketDto> orders;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  OrdersPaginationState({
    required this.orders,
    required this.currentPage,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  OrdersPaginationState copyWith({
    List<OrderTicketDto>? orders,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return OrdersPaginationState(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

// Orders pagination notifier
class OrdersPaginationNotifier extends StateNotifier<OrdersPaginationState> {
  final UserService _userService;

  OrdersPaginationNotifier(this._userService)
      : super(OrdersPaginationState(
          orders: [],
          currentPage: 0,
          isLoading: false,
          hasMore: true,
        ));

  Future<void> loadInitial() async {
    state = OrdersPaginationState(
      orders: [],
      currentPage: 0,
      isLoading: true,
      hasMore: true,
    );

    try {
      final response = await _userService.getMyOrdersPaginated(0);
      state = OrdersPaginationState(
        orders: response.content,
        currentPage: 0,
        isLoading: false,
        hasMore: !response.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _userService.getMyOrdersPaginated(nextPage);
      
      state = OrdersPaginationState(
        orders: [...state.orders, ...response.content],
        currentPage: nextPage,
        isLoading: false,
        hasMore: !response.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final ordersPaginationProvider =
    StateNotifierProvider<OrdersPaginationNotifier, OrdersPaginationState>(
  (ref) => OrdersPaginationNotifier(ref.read(userServiceProvider)),
);

