import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/item_dto.dart';
import 'service_providers.dart';

final allItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getItems();
});

final instantReadyItemsProvider = FutureProvider<List<ItemDto>>((ref) async {
  return ref.read(itemServiceProvider).getInstantReadyItems();
});
