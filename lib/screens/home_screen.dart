import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/item_card.dart';
import '../widgets/promo_banner_carousel.dart';
import 'item_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _displayCategoryTitle(String? selectedCategory) {
    if (selectedCategory == null) return 'Popular Today';
    final pretty = selectedCategory
        .toLowerCase()
        .split('_')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    return '$pretty Picks';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF2E8), Color(0xFFFFFBF7)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF7E36), Color(0xFFFFB067)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FF7E36),
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            '🔥 Hot right now on campus',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cravings calling?\nGrab your bite now.',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Freshly prepared canteen favourites in minutes.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryHeaderDelegate(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  ref.invalidate(filteredItemsProvider);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _displayCategoryTitle(selectedCategory),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5D4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        selectedCategory ?? 'ALL ITEMS',
                        style: const TextStyle(
                          color: Color(0xFF9A3412),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(filteredItemsProvider);
                  ref.invalidate(instantReadyItemsProvider);
                },
                child: itemsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Unable to load items: $error',
                      style: const TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('No items available right now.'),
                      );
                    }

                    return Column(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: ItemCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(item: item),
                                ),
                              );
                            },
                            onAdd: () async {
                              try {
                                await ref.read(cartProvider.notifier).addToCart(item.itemId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.itemName} added to cart'),
                                      backgroundColor: const Color(0xFF15803D),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to add to cart: $e'),
                                      backgroundColor: const Color(0xFFB91C1C),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  _CategoryHeaderDelegate({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _banners = [
    (
      category: null,
      title: 'All Items',
      subtitle: 'Browse full canteen menu 🍽️',
      icon: '🍽️',
      colors: [Color(0xFFFF7A18), Color(0xFFFFB347)],
    ),
    (
      category: 'BREAKFAST',
      title: 'Breakfast',
      subtitle: 'Start your day with hot meals 🥪',
      icon: '🥪',
      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
    ),
    (
      category: 'SNACK',
      title: 'Snacks',
      subtitle: 'Quick bites between lectures 🌮',
      icon: '🌮',
      colors: [Color(0xFFFF8A65), Color(0xFFFF5252)],
    ),
    (
      category: 'BEVERAGE',
      title: 'Beverages',
      subtitle: 'Stay hydrated and refreshed 🧋',
      icon: '🧋',
      colors: [Color(0xFF4FC3F7), Color(0xFF00ACC1)],
    ),
    (
      category: 'VEG',
      title: 'Veg Specials',
      subtitle: 'Delicious vegetarian options 🥗',
      icon: '🥗',
      colors: [Color(0xFF8BC34A), Color(0xFF43A047)],
    ),
  ];

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = (1 - (shrinkOffset / maxExtent)).clamp(0.0, 1.0);

    return Container(
      color: Color(0xFFFFF8F2).withValues(alpha: 0.95),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8 + (8 * opacity),
        bottom: 8 + (8 * opacity),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _banners.length,
            (index) {
              final banner = _banners[index];
              final isSelected = selectedCategory == banner.category;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (_) => onCategorySelected(banner.category),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          banner.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFFE5D4),
                    selectedColor: banner.colors.first,
                    side: BorderSide(
                      color: isSelected
                          ? banner.colors.first
                          : Colors.transparent,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 62;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}
