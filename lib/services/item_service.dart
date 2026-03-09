import '../models/item_cart/item_dto.dart';
import 'api_client.dart';

class PagedResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  PagedResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      pageNumber: json['number'] as int,
      pageSize: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      last: json['last'] as bool,
    );
  }
}

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

  Future<PagedResponse<ItemDto>> getItemsPaginated(int pageNo) async {
    final json = await _apiClient.get('/item?pageNo=$pageNo');
    return PagedResponse.fromJson(
      json as Map<String, dynamic>,
      (json) => ItemDto.fromJson(json),
    );
  }

  Future<List<ItemDto>> getItemsByCategory(String categoryName) async {
    final normalizedCategory = categoryName.trim().toUpperCase();
    final json = await _apiClient.get('/item/category?categoryName=$normalizedCategory');
    return (json as List<dynamic>)
        .map((item) => ItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PagedResponse<ItemDto>> getItemsByCategoryPaginated(
      String categoryName, int pageNo) async {
    final normalizedCategory = categoryName.trim().toUpperCase();
    final json =
        await _apiClient.get('/item/category?categoryName=$normalizedCategory&pageNo=$pageNo');
    return PagedResponse.fromJson(
      json as Map<String, dynamic>,
      (json) => ItemDto.fromJson(json),
    );
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
