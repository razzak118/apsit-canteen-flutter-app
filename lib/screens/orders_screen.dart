import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_user/order_ticket_dto.dart';
import '../providers/order_profile_providers.dart';
import '../widgets/skeleton_box.dart';
import 'order_detail_screen.dart';
import '../widgets/glass_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data only if empty
    Future.microtask(() {
      final currentState = ref.read(ordersPaginationProvider);
      if (currentState.orders.isEmpty && !currentState.isLoading) {
        ref.read(ordersPaginationProvider.notifier).loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ordersPaginationProvider.notifier).loadMore();
    }
  }

  DateTime? _parsePlacedAt(String rawDateTime) {
    return DateTime.tryParse(rawDateTime)?.toLocal();
  }

  String _getSectionLabel(DateTime now, DateTime placedAt) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final lastWeekStart = todayStart.subtract(const Duration(days: 7));

    if (!placedAt.isBefore(todayStart)) {
      return 'Today';
    }
    if (!placedAt.isBefore(yesterdayStart)) {
      return 'Yesterday';
    }
    if (!placedAt.isBefore(lastWeekStart)) {
      return 'Last 7 Days';
    }
    return 'Older';
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderTicketDto order) {
    return GlassCard(
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
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _statusColor(order.orderStatus).withValues(alpha: 0.12),
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
          Text(
            'Placed at: ${_formatPlacedAt(context, order.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.orderItems.length} item(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPlacedAt(BuildContext context, String rawDateTime) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call for AutomaticKeepAliveClientMixin
    final paginationState = ref.watch(ordersPaginationProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(ordersPaginationProvider.notifier).refresh();
          },
          child: _buildOrdersList(paginationState),
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrdersPaginationState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [_OrdersSkeleton()],
      );
    }

    if (state.error != null && state.orders.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [Text('Failed to load orders: ${state.error}')],
      );
    }

    if (state.orders.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                    Icons.receipt_long_rounded,
                    size: 56,
                    color: Color(0xFFFF5A1F),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Orders Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Start ordering your favorite meals from the canteen. Your order history will appear here!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final sortedOrders = [...state.orders]..sort((a, b) {
        final aTime = _parsePlacedAt(a.createdAt);
        final bTime = _parsePlacedAt(b.createdAt);

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

    final grouped = <String, List<OrderTicketDto>>{
      'Today': [],
      'Yesterday': [],
      'Last 7 Days': [],
      'Older': [],
    };

    for (final order in sortedOrders) {
      final placedAt = _parsePlacedAt(order.createdAt);
      if (placedAt == null) {
        grouped['Older']!.add(order);
        continue;
      }
      final label = _getSectionLabel(now, placedAt);
      grouped[label]!.add(order);
    }

    final children = <Widget>[];
    for (final entry in grouped.entries) {
      if (entry.value.isEmpty) continue;

      children.add(_sectionHeader(context, entry.key));
      for (final order in entry.value) {
        children.add(
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: _orderCard(context, order),
          ),
        );
        children.add(const SizedBox(height: 12));
      }
    }

    // Add loading indicator at the bottom
    if (state.isLoading) {
      children.add(const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ));
    }

    if (children.isNotEmpty && !state.isLoading) {
      children.removeLast();
    }

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonBox(height: 18, width: 90),
        const SizedBox(height: 10),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(height: 24, width: 72),
                      SkeletonBox(height: 24, width: 92),
                    ],
                  ),
                  SizedBox(height: 10),
                  SkeletonBox(height: 13, width: double.infinity),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(height: 12, width: 70),
                      SkeletonBox(height: 14, width: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
