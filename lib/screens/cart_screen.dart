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
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF5A1F).withOpacity(0.1),
                            const Color(0xFFFF8C42).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFE4D6),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5A1F).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 56,
                              color: Color(0xFFFF5A1F),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your Cart is Empty',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Explore our delicious menu and start adding items to your cart!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              DefaultTabController.of(context).animateTo(0);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.restaurant_menu_rounded),
                            label: const Text('Browse Menu'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5A1F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                    try {
                                      await ref
                                          .read(cartProvider.notifier)
                                          .deleteItemFromCart(cartItem.cartItemId);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to remove item: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
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
                          '₹${cart.totalCartPrice.toStringAsFixed(0)}',
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
                    onPressed: cart.cartItems.isEmpty
                        ? null
                        : () async {
                            try {
                              await ref.read(orderServiceProvider).placeOrder();
                              await ref.read(cartProvider.notifier).refreshCart();
                              ref.invalidate(myOrdersProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order placed successfully! 🎉'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to place order: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
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
