import 'package:canteen_user_app/providers/order_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/glass_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: RefreshIndicator(
          onRefresh: () => ref.read(cartProvider.notifier).refreshCart(),
          child: cartAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Unable to load cart: $error'),
              ],
            ),
            data: (cart) {
              if (cart.cartItems.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 60),
                    Icon(Icons.shopping_cart_checkout_rounded, size: 48),
                    SizedBox(height: 12),
                    Center(child: Text('Your cart is empty.')),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...cart.cartItems.map(
                    (cartItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cartItem.menuItem.itemName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await ref
                                        .read(cartProvider.notifier)
                                        .deleteItemFromCart(cartItem.menuItem.itemId);
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${cartItem.cartItemPrice.toStringAsFixed(0)}'),
                                Row(
                                  children: [
                                    IconButton.filledTonal(
                                      onPressed: () async {
                                        await ref
                                            .read(cartProvider.notifier)
                                            .removeFromCart(cartItem.menuItem.itemId);
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('${cartItem.quantity}'),
                                    ),
                                    IconButton.filledTonal(
                                      onPressed: () async {
                                        await ref
                                            .read(cartProvider.notifier)
                                            .addToCart(cartItem.menuItem.itemId);
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '₹${cart.totalCartPrice}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(orderServiceProvider).placeOrder();
                      await ref.read(cartProvider.notifier).refreshCart();
                      ref.invalidate(myOrdersProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order placed successfully')),
                        );
                      }
                    },
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Place Order'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
