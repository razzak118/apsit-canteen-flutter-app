import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_cart/cart_dto.dart';
import 'service_providers.dart';
import 'transaction_provider.dart';

class CartNotifier extends AsyncNotifier<CartDto> {
  @override
  Future<CartDto> build() async {
    return ref.read(cartServiceProvider).getMyCart();
  }

  Future<void> refreshCart() async {
    state = const AsyncLoading();
    final nextState = await ref.read(transactionCounterProvider.notifier).guard(
          () => AsyncValue.guard(
            () => ref.read(cartServiceProvider).getMyCart(),
          ),
        );
    state = nextState;
  }

  Future<void> _runCartMutation(Future<CartDto> Function() mutation) async {
    final previous = state;
    state = const AsyncLoading();
    final nextState = await ref.read(transactionCounterProvider.notifier).guard(
          () => AsyncValue.guard(mutation),
        );
    state = nextState;
    if (nextState.hasError) {
      state = previous;
      throw nextState.error!;
    }
  }

  Future<void> addToCart(int itemId) async {
    await _runCartMutation(
        () => ref.read(cartServiceProvider).addToCart(itemId));
  }

  Future<void> removeFromCart(int itemId) async {
    await _runCartMutation(
        () => ref.read(cartServiceProvider).removeFromCart(itemId));
  }

  Future<void> deleteItemFromCart(int itemId) async {
    await _runCartMutation(
      () => ref.read(cartServiceProvider).deleteItemFromCart(itemId),
    );
  }
}

final cartProvider =
    AsyncNotifierProvider<CartNotifier, CartDto>(CartNotifier.new);
