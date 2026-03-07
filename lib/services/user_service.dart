import '../models/order_user/order_ticket_dto.dart';
import '../models/order_user/user_response_dto.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<OrderTicketDto>> getMyOrders() async {
    final json = await _apiClient.get('/users/my-orders');
    return (json as List<dynamic>)
        .map((order) => OrderTicketDto.fromJson(order as Map<String, dynamic>))
        .toList();
  }

  Future<UserResponseDto> getMyProfile() async {
    final json = await _apiClient.get('/users');
    return UserResponseDto.fromJson(json as Map<String, dynamic>);
  }
}
