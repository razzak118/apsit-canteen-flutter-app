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
