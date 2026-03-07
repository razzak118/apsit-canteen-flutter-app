import '../models/order_user/order_ticket_dto.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient, Future<void> Function()? onUnauthorized})
      : _apiClient = apiClient ?? ApiClient(onUnauthorized: onUnauthorized);

  Future<OrderTicketDto> placeOrder() async {
    final json = await _apiClient.post('/order/place');
    return OrderTicketDto.fromJson(json as Map<String, dynamic>);
  }
}
