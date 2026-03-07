import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/item_dto.dart';
import 'service_providers.dart';

final allItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getItems();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final priceRangeProvider = StateProvider<(int, int)?>((ref) => null);

final filteredItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final priceRange = ref.watch(priceRangeProvider);

  List<ItemDto> items;

  // Fetch items from backend
  if (selectedCategory == null) {
    items = await ref.read(itemServiceProvider).getItems();
  } else {
    items = await ref.read(itemServiceProvider).getItemsByCategory(selectedCategory);
  }

  // Apply search filter (fuzzy search - partial name matching)
  if (searchQuery.isNotEmpty) {
    items = items
        .where((item) => item.itemName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Apply price range filter
  if (priceRange != null) {
    final (minPrice, maxPrice) = priceRange;
    items = items.where((item) => item.price >= minPrice && item.price <= maxPrice).toList();
  }

  return items;
});

final instantReadyItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getInstantReadyItems();
});
