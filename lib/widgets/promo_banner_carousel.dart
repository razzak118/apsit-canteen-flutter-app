import 'package:flutter/material.dart';

import 'glass_card.dart';

class PromoBannerCarousel extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const PromoBannerCarousel({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _banners = [
    (
      category: null,
      title: 'All Items',
      subtitle: 'Browse full canteen menu 🍽️',
      colors: [Color(0xFFFF7A18), Color(0xFFFFB347)],
    ),
    (
      category: 'BREAKFAST',
      title: 'Breakfast',
      subtitle: 'Start your day with hot meals 🥪',
      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
    ),
    (
      category: 'SNACK',
      title: 'Snacks',
      subtitle: 'Quick bites between lectures 🌮',
      colors: [Color(0xFFFF8A65), Color(0xFFFF5252)],
    ),
    (
      category: 'BEVERAGE',
      title: 'Beverages',
      subtitle: 'Stay hydrated and refreshed 🧋',
      colors: [Color(0xFF4FC3F7), Color(0xFF00ACC1)],
    ),
    (
      category: 'VEG',
      title: 'Veg Specials',
      subtitle: 'Delicious vegetarian options 🥗',
      colors: [Color(0xFF8BC34A), Color(0xFF43A047)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final banner = _banners[index];
          final isSelected = selectedCategory == banner.category;
          return SizedBox(
            width: 290,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onCategorySelected(banner.category),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: banner.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF0F172A), width: 2)
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: GlassCard(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF334155),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
