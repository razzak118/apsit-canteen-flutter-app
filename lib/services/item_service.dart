import '../models/item_cart/item_dto.dart';
import 'api_client.dart';

class ItemService {
  final ApiClient _apiClient;

  ItemService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ItemDto>> getItems() async {
    final json = await _apiClient.get('/item');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ItemDto>> getItemsByCategory(String categoryName) async {
    final json = await _apiClient.get('/item/category/$categoryName');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ItemDto>> getInstantReadyItems() async {
    final json = await _apiClient.get('/item/instant-ready');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
