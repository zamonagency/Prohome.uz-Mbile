import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../real_estate_repository.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.initial});
  final RealEstateFilter initial;

  static Future<RealEstateFilter?> show(
      BuildContext context, RealEstateFilter initial) {
    return showModalBottomSheet<RealEstateFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FilterSheet(initial: initial),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _deal = widget.initial.dealType;
  late String? _type = widget.initial.propertyType;
  late int? _rooms = widget.initial.rooms;
  late final _minCtrl =
      TextEditingController(text: widget.initial.minPrice?.toStringAsFixed(0));
  late final _maxCtrl =
      TextEditingController(text: widget.initial.maxPrice?.toStringAsFixed(0));

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 4,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s('common.filter'),
                style: context.texts.titleLarge),
            const SizedBox(height: 16),
            _label(s('filter.deal')),
            _chips(
              ['SALE', 'RENT'],
              _deal,
              (v) => setState(() => _deal = v),
              (v) => v == 'RENT' ? s('estate.deal_rent') : s('estate.deal_sale'),
            ),
            const SizedBox(height: 16),
            _label(s('filter.type')),
            _chips(
              ['APARTMENT', 'HOUSE', 'OFFICE', 'RETAIL'],
              _type,
              (v) => setState(() => _type = v),
              (v) => switch (v) {
                'HOUSE' => s('estate.type_house'),
                'OFFICE' => s('estate.type_office'),
                'RETAIL' => s('estate.type_retail'),
                _ => s('estate.type_apartment'),
              },
            ),
            const SizedBox(height: 16),
            _label(s('filter.rooms')),
            _chips(
              ['1', '2', '3', '4', '5'],
              _rooms?.toString(),
              (v) => setState(() => _rooms = v == null ? null : int.tryParse(v)),
              (v) => '$v+',
            ),
            const SizedBox(height: 16),
            _label(s('filter.price')),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: s('filter.price_min')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: s('filter.price_max')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const RealEstateFilter()),
                    child: Text(s('common.reset')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        widget.initial.copyWith(
                          dealType: _deal,
                          propertyType: _type,
                          rooms: _rooms,
                          minPrice: num.tryParse(_minCtrl.text),
                          maxPrice: num.tryParse(_maxCtrl.text),
                        ),
                      );
                    },
                    child: Text(s('common.apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      );

  Widget _chips(
    List<String> values,
    String? selected,
    ValueChanged<String?> onTap,
    String Function(String) label,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final active = selected == v;
        return ChoiceChip(
          label: Text(label(v)),
          selected: active,
          onSelected: (_) => onTap(active ? null : v),
          showCheckmark: false,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: active ? Colors.white : null,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        );
      }).toList(),
    );
  }
}
