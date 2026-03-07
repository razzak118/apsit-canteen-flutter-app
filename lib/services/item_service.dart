import '../models/item_cart/item_dto.dart';
import 'api_client.dart';

class ItemService {
  final ApiClient _apiClient;

  ItemService({ApiClient? apiClient, Future<void> Function()? onUnauthorized})
      : _apiClient = apiClient ?? ApiClient(onUnauthorized: onUnauthorized);

  Future<List<ItemDto>> getItems() async {
    final json = await _apiClient.get('/item');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ItemDto>> getItemsByCategory(String categoryName) async {
    final normalizedCategory = categoryName.trim().toUpperCase();
    final json = await _apiClient.get('/item/category/$normalizedCategory');
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

  Future<ItemDto> getItemByName(String itemName) async {
    final json = await _apiClient.get('/item/$itemName');
    return ItemDto.fromJson(json as Map<String, dynamic>);
  }

  Future<List<ItemDto>> getItemsByPriceRange(int minPrice, int maxPrice) async {
    final json = await _apiClient.get('/item/price-range?minPrice=$minPrice&highPrice=$maxPrice');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
