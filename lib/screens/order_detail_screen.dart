import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_user/order_item_dto.dart';
import '../models/order_user/order_ticket_dto.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/order_profile_providers.dart';
import '../providers/service_providers.dart';
import '../widgets/glass_card.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderTicketDto order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Future<OrderTicketDto> _detailFuture;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadOrderDetails();
  }

  Future<OrderTicketDto> _loadOrderDetails() async {
    final id = widget.order.orderId;
    if (id == null) {
      return widget.order;
    }
    try {
      return await ref.read(orderServiceProvider).getOrderDetails(id);
    } catch (_) {
      // Fallback to existing data if detail endpoint fails.
      return widget.order;
    }
  }

  String _formatDate(BuildContext context, String rawDateTime) {
    final parsed = DateTime.tryParse(rawDateTime);
    if (parsed == null) return rawDateTime;

    final local = parsed.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final datePart =
        '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
    final timePart = TimeOfDay.fromDateTime(local).format(context);
    return '$datePart, $timePart';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF16A34A);
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFEA580C);
    }
  }

  Future<void> _handleReorder() async {
    final orderId = widget.order.orderId;
    if (orderId == null || _isReordering) return;

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Items'),
        content: const Text('Do you want to reorder the exact same items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reorder'),
          ),
        ],
      ),
    );

    if (approved != true) return;

    setState(() => _isReordering = true);
    try {
      await ref.read(orderServiceProvider).reOrder(orderId);
      ref.invalidate(cartProvider);
      ref.invalidate(myOrdersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reorder successful! Items were added.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(mainNavigationIndexProvider.notifier).state = 1;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reorder: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReordering = false);
      }
    }
  }

  Widget _itemTile(BuildContext context, OrderItemDto item) {
    final itemTotal = item.historicalPrice * item.quantity;

    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.itemName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} • ₹${item.historicalPrice.toStringAsFixed(0)} each',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${itemTotal.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canReorder = widget.order.orderId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<OrderTicketDto>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && !snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Unable to load order details: ${snapshot.error}'),
              ],
            );
          }

          final order = snapshot.data ?? widget.order;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(order.orderStatus)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.orderStatus,
                            style: TextStyle(
                              color: _statusColor(order.orderStatus),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (order.orderId != null)
                      Text(
                        'Order ID: ${order.orderId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Placed at: ${_formatDate(context, order.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Items (${order.orderItems.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              ...order.orderItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _itemTile(context, item),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: canReorder && !_isReordering ? _handleReorder : null,
                icon: _isReordering
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.replay_rounded),
                label: Text(
                    _isReordering ? 'Reordering...' : 'Reorder Same Items'),
              ),
              if (!canReorder)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Order ID was not received from API, reorder is unavailable for this order.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
