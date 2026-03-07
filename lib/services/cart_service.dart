import '../models/item_cart/cart_dto.dart';
import 'api_client.dart';

class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<CartDto> getMyCart() async {
    final json = await _apiClient.get('/cart/my-cart');
    return CartDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CartDto> addToCart(int itemId) async {
    final json = await _apiClient.post('/cart/addToCart/$itemId');
    return CartDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CartDto> removeFromCart(int itemId) async {
    final json = await _apiClient.post('/cart/remove/$itemId');
    return CartDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CartDto> deleteItemFromCart(int itemId) async {
    final json = await _apiClient.post('/cart/deleteItemfromCart/$itemId');
    return CartDto.fromJson(json as Map<String, dynamic>);
  }
}
