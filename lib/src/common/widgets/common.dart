import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Ko'rishlar va layklar soni — ko'chmas mulk, usta, ish e'loni va h.k.
/// kartalarida bir xil uslubda ko'rsatiladi.
class StatCounters extends StatelessWidget {
  const StatCounters({
    super.key,
    required this.viewCount,
    required this.likeCount,
    this.size = 12.5,
  });
  final int viewCount;
  final int likeCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_outlined, size: size + 2, color: context.muted),
        const SizedBox(width: 3),
        Text('$viewCount', style: TextStyle(fontSize: size, color: context.muted)),
        const SizedBox(width: 10),
        Icon(Icons.favorite_rounded, size: size + 1, color: context.muted),
        const SizedBox(width: 3),
        Text('$likeCount', style: TextStyle(fontSize: size, color: context.muted)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll, this.seeAllLabel});
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: context.texts.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 36),
              ),
              child: Row(
                children: [
                  Text(seeAllLabel ?? 'Barchasi',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.filled = false,
    this.dense = false,
  });
  final String label;
  final IconData? icon;
  final Color? color;
  final bool filled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: dense ? 11 : 13,
                color: filled ? Colors.white : c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 10.5 : 12,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : c,
            ),
          ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.size = 14, this.showValue = true});
  final double value;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 2, color: AppColors.accent),
        if (showValue) ...[
          const SizedBox(width: 3),
          Text(value.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: size, fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }
}

/// 2 (yoki ko'p) qatorli, gorizontal skrol qiladigan "javon" — har bir bo'lim
/// (ko'chmas mulk, ustalar, ishlar...) o'z ichida mustaqil x-o'qi bo'yicha
/// skrol bo'ladi, sahifaning o'zi esa y-o'qi bo'yicha skrol qiladi.
class HGridScroller extends StatelessWidget {
  const HGridScroller({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.rows = 2,
    this.itemWidth = 160,
    this.itemHeight = 210,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final int itemCount;
  final int rows;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    // Elementlar sonini to'ldirmasa (masalan 4 qatorga atigi 2 ta narsa)
    // ular ustma-ust "tushib" yarim qatorga o'xshab qolmasin uchun —
    // shunday holatda bitta qatorga tushirib, yonma-yon joylashtiramiz.
    final effectiveRows = itemCount <= rows ? 1 : rows;
    final height = itemHeight * effectiveRows + spacing * (effectiveRows - 1);
    return SizedBox(
      height: height,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: effectiveRows,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          mainAxisExtent: itemWidth,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Ichki gorizontal karusel uchun standart o'lcham.
class HScroller extends StatelessWidget {
  const HScroller({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 250,
    this.itemWidth = 260,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final int itemCount;
  final double height;
  final double itemWidth;
  final EdgeInsets padding;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (c, i) => SizedBox(width: itemWidth, child: itemBuilder(c, i)),
      ),
    );
  }
}
