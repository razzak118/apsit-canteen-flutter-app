import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/item_dto.dart';
import 'service_providers.dart';

final allItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getItems();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return ref.read(itemServiceProvider).getItems();
  }

  return ref.read(itemServiceProvider).getItemsByCategory(selectedCategory);
});

final instantReadyItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getInstantReadyItems();
});
