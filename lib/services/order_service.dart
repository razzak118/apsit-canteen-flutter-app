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

  Future<OrderTicketDto> getOrderDetails(int orderId) async {
    final json = await _apiClient.post('/order/get-order-detail/$orderId');
    return OrderTicketDto.fromJson(json as Map<String, dynamic>);
  }

  Future<void> reOrder(int orderId) async {
    await _apiClient.post('/order/re-order/$orderId');
  }

  Future<void> cancelOrder(int orderId) async {
    await _apiClient.post('/order/cancel-order/$orderId');
  }
}
