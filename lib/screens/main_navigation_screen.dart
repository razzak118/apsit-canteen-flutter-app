import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../events/order_updates_events.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/order_profile_providers.dart';
import '../providers/order_realtime_provider.dart';
import '../providers/service_providers.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  static const _screens = [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  late final ProviderSubscription<AsyncValue<OrderStatusUpdatedEvent>>
      _orderUpdatesSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(localNotificationServiceProvider);
      await notifier.initialize();
      await notifier.requestPermissionIfNeeded();
    });

    _orderUpdatesSubscription = ref.listenManual(
      orderStatusUpdatesProvider,
      (_, next) {
        next.whenData((event) async {
          ref.read(ordersPaginationProvider.notifier).applyOrderUpdate(event.order);
          ref.invalidate(myOrdersProvider);

          final shown = await ref.read(localNotificationServiceProvider).showOrderStatusUpdate(
                orderId: event.order.orderId,
                status: event.order.orderStatus,
              );

          if (!shown && mounted) {
            final orderId = event.order.orderId;
            final status = event.order.orderStatus.trim().toUpperCase().replaceAll('_', ' ');
            final message = orderId == null
                ? 'Order updated: $status'
                : 'Order #$orderId updated: $status';

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        });
      },
      fireImmediately: false,
    );

  }

  @override
  void dispose() {
    _orderUpdatesSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(orderRealtimeLifecycleProvider);

    final index = ref.watch(mainNavigationIndexProvider);
    final cartAsync = ref.watch(cartProvider);
    final cartItemCount = cartAsync.whenOrNull(
          data: (cart) => cart.cartItems.length,
        ) ??
        0;

    return Scaffold(
      body: _screens[index],
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (value) {
          ref.read(mainNavigationIndexProvider.notifier).state = value;
        },
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
              icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          const NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
