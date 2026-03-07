import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/cart_dto.dart';
import 'service_providers.dart';

class CartNotifier extends AsyncNotifier<CartDto> {
  @override
  Future<CartDto> build() async {
    return ref.read(cartServiceProvider).getMyCart();
  }

  Future<void> refreshCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(cartServiceProvider).getMyCart());
  }

  Future<void> addToCart(int itemId) async {
    final previous = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(cartServiceProvider).addToCart(itemId));
    if (state.hasError) {
      state = previous;
    }
  }

  Future<void> removeFromCart(int itemId) async {
    final previous = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(cartServiceProvider).removeFromCart(itemId));
    if (state.hasError) {
      state = previous;
    }
  }

  Future<void> deleteItemFromCart(int itemId) async {
    final previous = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartServiceProvider).deleteItemFromCart(itemId),
    );
    if (state.hasError) {
      state = previous;
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartDto>(CartNotifier.new);
