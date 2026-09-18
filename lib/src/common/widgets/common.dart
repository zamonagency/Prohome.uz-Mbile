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

/// 2 (yoki ko'p) qatorli "javon" — MUHIM: har bir QATOR o'zining alohida,
/// mustaqil x-o'qi bo'yicha skroliga ega (bitta qatorni surish
/// boshqalariga ta'sir qilmaydi) — bitta umumiy grid sifatida emas, balki
/// bir-biriga bog'liq bo'lmagan bir nechta gorizontal qator sifatida
/// chiziladi. Sahifaning o'zi esa y-o'qi bo'yicha skrol qiladi.
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
    this.visibleColumns,
    this.minItemWidth,
    this.maxItemWidth,
    this.peek = 0,
    this.imageAspectRatio,
    this.footerHeight,
  });

  final int itemCount;
  final int rows;

  /// [visibleColumns] berilmasa — qat'iy kenglik/balandlik shu holicha
  /// ishlatiladi.
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  /// Berilsa: ekran kengligidan qat'i nazar (eng kichik telefondan
  /// planshetgacha) aynan shuncha ustun bir vaqtda TO'LIQ (keyingisi
  /// hatto bir siqim ham ko'rinmasdan) sig'adigan qilib kenglik
  /// hisoblanadi; ko'proq element bo'lsa — gorizontal skrol (har bir
  /// qator mustaqil, alohida-alohida skrol qiladi).
  final int? visibleColumns;

  /// Juda tor ekranlarda kartaning o'qib bo'lmas darajada torayib
  /// ketishining oldini oladigan pastki chegara.
  final double? minItemWidth;

  /// Juda keng (katta planshet) ekranlarda kartaning haddan tashqari
  /// kattalashib ketishining oldini oladigan yuqori chegara.
  final double? maxItemWidth;

  /// >0 bo'lsa, keyingi kartaning shuncha qismi ko'rinib turadi (skrol
  /// borligini bildiruvchi ishora). Standart 0 — chegaradan tashqari
  /// karta UMUMAN ko'rinmaydi, faqat qo'lda suriganda chiqadi.
  final double peek;

  /// [visibleColumns] bilan ishlatilganda — kartaning YUQORI (rasm)
  /// qismi shu nisbatda (en/bo'y) masshtablanadi.
  final double? imageAspectRatio;

  /// [visibleColumns] bilan ishlatilganda — kartaning matn/tugmalar
  /// qismi uchun QAT'IY (kenglikka qarab o'zgarmaydigan) balandlik.
  /// MUHIM: bu qism shrift/ikonka o'lchamlari FIKS bo'lgani uchun butun
  /// kartani "proporsional" kichraytirish balandlikni yetarlicha
  /// hisoblamay, matn tagida sariq-qora "overflow" chizig'iga olib
  /// kelgan edi — shu sabab rasm va footer balandligi ENDI ALOHIDA-
  /// ALOHIDA hisoblanadi: umumiy balandlik = kenglik/[imageAspectRatio]
  /// + [footerHeight].
  final double? footerHeight;

  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (visibleColumns == null) {
      return _HGridRows(
        itemCount: itemCount,
        rows: rows,
        itemWidth: itemWidth,
        itemHeight: itemHeight,
        spacing: spacing,
        padding: padding,
        itemBuilder: itemBuilder,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = visibleColumns!;
        final available = constraints.maxWidth - padding.horizontal - peek;
        var width = (available - spacing * (cols - 1)) / cols;
        final min = minItemWidth;
        final max = maxItemWidth;
        if (min != null && width < min) width = min;
        if (max != null && width > max) width = max;
        final aspect = imageAspectRatio;
        final footer = footerHeight;
        final height = (aspect != null && footer != null)
            ? width / aspect + footer
            : itemHeight * (width / itemWidth);
        return _HGridRows(
          itemCount: itemCount,
          rows: rows,
          itemWidth: width,
          itemHeight: height,
          spacing: spacing,
          padding: padding,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class _HGridRows extends StatelessWidget {
  const _HGridRows({
    required this.itemCount,
    required this.rows,
    required this.itemWidth,
    required this.itemHeight,
    required this.spacing,
    required this.padding,
    required this.itemBuilder,
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

    // Elementlarni qatorlarga navbat bilan (round-robin) taqsimlaymiz —
    // masalan 8 ta element, 4 qator bo'lsa: 0,4 / 1,5 / 2,6 / 3,7.
    final rowIndices = List.generate(
      effectiveRows,
      (r) => [for (var i = r; i < itemCount; i += effectiveRows) i],
    );

    return Column(
      children: [
        for (var r = 0; r < rowIndices.length; r++) ...[
          if (r > 0) SizedBox(height: spacing),
          SizedBox(
            height: itemHeight,
            // Har bir qator o'zining mustaqil `ListView`iga ega — bittasini
            // surish boshqalariga ta'sir qilmaydi (`HGridScroller`ning
            // asosiy xususiyati, kenglik endi responsiv bo'lsa ham saqlanadi).
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: padding,
              itemCount: rowIndices[r].length,
              separatorBuilder: (_, __) => SizedBox(width: spacing),
              itemBuilder: (c, i) => SizedBox(
                width: itemWidth,
                child: itemBuilder(c, rowIndices[r][i]),
              ),
            ),
          ),
        ],
      ],
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
