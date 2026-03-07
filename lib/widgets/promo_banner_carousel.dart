import 'package:flutter/material.dart';

import 'glass_card.dart';

class PromoBannerCarousel extends StatelessWidget {
  const PromoBannerCarousel({super.key});

  static const _banners = [
    (
      title: 'Fresh Breakfast Deals',
      subtitle: 'Up to 25% off on combo meals',
      colors: [Color(0xFFFF7A59), Color(0xFFFFB199)],
    ),
    (
      title: 'Instant Ready Items',
      subtitle: 'Grab quick bites in under 5 mins',
      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    ),
    (
      title: 'Hydration Break',
      subtitle: 'Cool beverages for your lectures',
      colors: [Color(0xFF34D399), Color(0xFF10B981)],
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
          return SizedBox(
            width: 290,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: banner.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
          );
        },
      ),
    );
  }
}
