import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/cart_dto.dart';
import 'service_providers.dart';

class CartNotifier extends AsyncNotifier<CartDto> {
  @override
  Future<CartDto> build() async {
    return ref.read(cartServiceProvider).getMyCart();
  }

  Future<void> refreshCart() async {
    // Keep current cart visible while refreshing in background.
    final nextState = await AsyncValue.guard(
      () => ref.read(cartServiceProvider).getMyCart(),
    );
    state = nextState;
  }

  Future<void> addToCart(int itemId) async {
    final previous = state;
    final nextState = await AsyncValue.guard(
      () => ref.read(cartServiceProvider).addToCart(itemId),
    );
    state = nextState;
    if (nextState.hasError) {
      state = previous;
      throw nextState.error!;
    }
  }

  Future<void> removeFromCart(int itemId) async {
    final previous = state;
    final nextState = await AsyncValue.guard(
      () => ref.read(cartServiceProvider).removeFromCart(itemId),
    );
    state = nextState;
    if (nextState.hasError) {
      state = previous;
      throw nextState.error!;
    }
  }

  Future<void> deleteItemFromCart(int itemId) async {
    final previous = state;
    final nextState = await AsyncValue.guard(
      () => ref.read(cartServiceProvider).deleteItemFromCart(itemId),
    );
    state = nextState;
    if (nextState.hasError) {
      state = previous;
      throw nextState.error!;
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartDto>(CartNotifier.new);
