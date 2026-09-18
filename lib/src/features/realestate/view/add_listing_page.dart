import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../l10n/strings.dart';
import '../../../common/widgets/location_picker.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../real_estate_repository.dart';
import 'add_listing_amenities.dart';
import 'location_point_picker_page.dart';

class AddListingPage extends ConsumerStatefulWidget {
  const AddListingPage({super.key});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _area = TextEditingController();
  final _livingArea = TextEditingController();
  final _rooms = TextEditingController(text: '1');
  final _floor = TextEditingController();
  final _totalFloors = TextEditingController();
  final _plotSize = TextEditingController();
  final _phone = TextEditingController();

  String _deal = 'SALE';
  PropertyCategory _category = propertyCategories.first;
  int? _locationId;
  String? _locationName;
  LatLng? _point;

  String? _repair, _gas, _heating, _sewage, _water, _electricity, _parking, _buildingType;

  final List<XFile> _images = [];
  bool _busy = false;
  String? _error;

  bool get _isHouseLike => _category.propertyType == 'HOUSE';

  @override
  void dispose() {
    for (final c in [
      _title, _desc, _price, _area, _livingArea, _rooms, _floor, _totalFloors,
      _plotSize, _phone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() => _images.addAll(picked));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Rasm tanlab bo\'lmadi')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final shot = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
      if (shot != null) setState(() => _images.add(shot));
    } catch (_) {}
  }

  Future<void> _pickPoint() async {
    final p = await LocationPointPickerPage.show(context, initial: _point);
    if (p != null) setState(() => _point = p);
  }

  void _generateDescription() {
    final desc = buildAutoDescription(
      categoryLabel: _category.label,
      dealType: _deal,
      areaSize: _area.text,
      roomCount: _rooms.text,
      floor: _floor.text,
      totalFloors: _totalFloors.text,
      livingArea: _livingArea.text,
      repairType: _repair,
      gas: _gas,
      heating: _heating,
      sewage: _sewage,
      water: _water,
      electricity: _electricity,
      parking: _parking,
      buildingType: _isHouseLike ? _buildingType : null,
      locationName: _locationName,
    );
    setState(() => _desc.text = desc);
    if (_title.text.trim().isEmpty) {
      final roomsTxt = _rooms.text.isNotEmpty ? '${_rooms.text} xonali' : '';
      final dealTxt = _deal == 'RENT' ? 'ijaraga beriladi' : 'sotiladi';
      _title.text = [_category.label, roomsTxt, dealTxt]
          .where((e) => e.isNotEmpty)
          .join(', ');
    }
  }

  String? _validate() {
    if (_title.text.trim().isEmpty) return 'Sarlavhani kiriting';
    if (num.tryParse(_price.text) == null || num.parse(_price.text) <= 0) {
      return 'Narxni kiriting';
    }
    if (_locationId == null) return 'Hududni tanlang';
    if (_point == null) {
      return 'Xaritadan aniq joyni belgilang (majburiy)';
    }
    if (num.tryParse(_area.text) == null || num.parse(_area.text) <= 0) {
      return 'Maydonni kiriting';
    }
    if (int.tryParse(_rooms.text) == null) return 'Xonalar sonini kiriting';
    if (normalizePhone(_phone.text).isEmpty || !isValidPhone(normalizePhone(_phone.text))) {
      return 'Telefon raqamini to\'g\'ri kiriting';
    }
    if (_images.isEmpty) return 'Kamida 1 ta rasm qo\'shing';
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final created = await ref.read(realEstateRepositoryProvider).create({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'price': num.parse(_price.text),
        'propertyType': _category.propertyType,
        'dealType': _deal,
        'sellerType': 'INDIVIDUAL',
        'locationId': _locationId,
        'contactPhone': normalizePhone(_phone.text),
        'areaSize': num.parse(_area.text),
        'roomCount': int.parse(_rooms.text),
        if (_floor.text.isNotEmpty) 'floor': int.tryParse(_floor.text),
        if (_totalFloors.text.isNotEmpty)
          'totalFloors': int.tryParse(_totalFloors.text),
        if (_isHouseLike && _plotSize.text.isNotEmpty)
          'plotSize': num.tryParse(_plotSize.text),
        'address': _locationName ?? '',
        'latitude': _point!.latitude,
        'longitude': _point!.longitude,
      });

      // Rasmlarni birma-bir yuklaymiz — birinchisi asosiy (isMain) bo'ladi.
      for (var i = 0; i < _images.length; i++) {
        try {
          final bytes = await _images[i].readAsBytes();
          await ref.read(realEstateRepositoryProvider).uploadImage(
                created.id,
                bytes,
                _images[i].name,
                isMain: i == 0,
              );
        } catch (_) {
          // Bitta rasm muvaffaqiyatsiz bo'lsa ham e'lonning o'zi joylangan —
          // qolganlarini yuklashda davom etamiz.
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E’lon yuborildi. Moderatsiyadan so‘ng chop etiladi.')),
      );
      context.pop(created.id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final authed = ref.watch(isAuthenticatedProvider);

    if (!authed) {
      return Scaffold(
        appBar: AppBar(title: Text(s('estate.add'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 48),
                const SizedBox(height: 12),
                Text(s('auth.need_login'), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push(Routes.login),
                  child: Text(s('auth.login')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s('estate.add'))),
      body: Center(
        child: ConstrainedBox(
          // Planshetda forma cheksiz cho'zilib ketmasin uchun.
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _Hero(s: s),
              const SizedBox(height: 18),

              _sectionCard(
                icon: Icons.sell_rounded,
                color: AppColors.primary,
                title: 'Bitim va toifa',
                children: [
                  _seg(
                    label: s('filter.deal'),
                    value: _deal,
                    options: const {'SALE': 'Sotiladi', 'RENT': 'Ijaraga'},
                    onChanged: (v) => setState(() => _deal = v),
                  ),
                  const SizedBox(height: 16),
                  Text("Ko'chmas mulk toifasi",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: context.muted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: propertyCategories
                        .map((c) => ChoiceChip(
                              label: Text(c.label),
                              selected: _category.label == c.label,
                              onSelected: (_) => setState(() => _category = c),
                              selectedColor: AppColors.primary,
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                  color: _category.label == c.label
                                      ? Colors.white
                                      : null,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5),
                            ))
                        .toList(),
                  ),
                ],
              ),

              _sectionCard(
                icon: Icons.location_on_rounded,
                color: const Color(0xFF0F80FF),
                title: 'Manzil',
                required: true,
                children: [
                  LocationField(
                    locationId: _locationId,
                    required: true,
                    onChanged: (l) {
                      setState(() {
                        _locationId = l.id;
                        _locationName = l.name;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Xaritadagi aniq nuqta *',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: context.muted)),
                  const SizedBox(height: 8),
                  // MUHIM: `InputDecorator` o'zining ikonka/matn oralig'ini
                  // qattiq belgilab qo'yadi — uzunroq matn strelka
                  // ikonkasiga deyarli yopishib qolardi. Endi to'liq
                  // qo'lda chizilgan qator — matn va strelka orasida
                  // aniq, kafolatlangan bo'shliq bilan.
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickPoint,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? AppColors.darkSurfaceAlt
                            : const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined,
                              size: 20, color: context.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _point == null
                                  ? "Xaritadan tanlash uchun bosing"
                                  : '${_point!.latitude.toStringAsFixed(6)}, ${_point!.longitude.toStringAsFixed(6)}',
                              maxLines: 2,
                              style: TextStyle(
                                  color: _point == null ? context.muted : null,
                                  fontWeight: _point == null
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  height: 1.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.chevron_right_rounded,
                              size: 20, color: context.muted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              _sectionCard(
                icon: Icons.straighten_rounded,
                color: AppColors.accent,
                title: 'Xususiyatlari',
                children: [
                  _text(_area, 'Maydon (m²)',
                      required: true,
                      number: true,
                      decimal: true,
                      icon: Icons.square_foot_rounded),
                  // MUHIM: bu yerda ikkita maydon yonma-yon, tor ustunda —
                  // ikonka + to'liq label (masalan "Xonalar soni") sig'may,
                  // label "Xonalar so..." bo'lib qisqarib, ikonkaga
                  // yopishib qolgan ko'rinardi. Shu sabab juftlashgan
                  // (yarim kenglikdagi) maydonlarda ikonka ishlatilmaydi —
                  // faqat to'liq kenglikdagilarda (Maydon, Narx va h.k.).
                  Row(
                    children: [
                      Expanded(
                        child: _text(_rooms, 'Xonalar soni',
                            required: true, number: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _text(_livingArea, 'Yashash maydoni (m²)',
                            number: true, decimal: true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _text(_floor, 'Qavat', number: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _text(_totalFloors, 'Jami qavat', number: true),
                      ),
                    ],
                  ),
                  if (_isHouseLike)
                    _text(_plotSize, 'Yer maydoni (sotix)',
                        number: true,
                        decimal: true,
                        icon: Icons.landscape_outlined),
                ],
              ),

              _sectionCard(
                icon: Icons.tune_rounded,
                color: const Color(0xFF7F4DFF),
                title: 'Qulayliklar',
                dense: true,
                children: [
                  _amenity(Icons.format_paint_outlined, "Ta'mirlash", repairOptions, _repair,
                      (v) => setState(() => _repair = v)),
                  _amenity(Icons.local_fire_department_outlined, 'Gaz', gasOptions, _gas,
                      (v) => setState(() => _gas = v)),
                  _amenity(Icons.thermostat_outlined, 'Isitish tizimi', heatingOptions, _heating,
                      (v) => setState(() => _heating = v)),
                  _amenity(Icons.water_drop_outlined, "Suv ta'minoti", waterOptions, _water,
                      (v) => setState(() => _water = v)),
                  _amenity(Icons.plumbing_outlined, 'Kanalizatsiya', sewageOptions, _sewage,
                      (v) => setState(() => _sewage = v)),
                  _amenity(Icons.bolt_outlined, "Elektr ta'minoti", electricityOptions,
                      _electricity, (v) => setState(() => _electricity = v)),
                  _amenity(Icons.local_parking_outlined, 'Avtoturargoh', parkingOptions,
                      _parking, (v) => setState(() => _parking = v), isLast: !_isHouseLike),
                  if (_isHouseLike)
                    _amenity(Icons.apartment_outlined, 'Uy turi', buildingTypeOptions,
                        _buildingType, (v) => setState(() => _buildingType = v),
                        isLast: true),
                ],
              ),

              _sectionCard(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF10B782),
                title: 'Rasmlar',
                required: true,
                children: [_photosGrid()],
              ),

              _sectionCard(
                icon: Icons.edit_note_rounded,
                color: const Color(0xFFE5484D),
                title: "Sarlavha va ta'rif",
                children: [
                  _text(_title, 'Sarlavha', required: true, icon: Icons.title_rounded),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _generateDescription,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text("Qulayliklardan ta'rif yasash"),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _text(_desc, s('estate.description'), maxLines: 6),
                ],
              ),

              _sectionCard(
                icon: Icons.payments_rounded,
                color: AppColors.primaryDeep,
                title: 'Narx va aloqa',
                children: [
                  _text(_price, 'Narx (USD)',
                      required: true,
                      number: true,
                      decimal: true,
                      icon: Icons.attach_money_rounded),
                  _text(_phone, s('auth.phone'),
                      required: true, icon: Icons.phone_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(s('common.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Har bir bo'lim endi alohida, ikonkali karta — avvalgi "1. 2. 3."
  /// oddiy matn sarlavhalar bir-biriga o'xshab, ko'zga tashlanmasdi.
  Widget _sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
    bool required = false,
    bool dense = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(dense ? 16 : 18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: context.border),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
              ),
              if (required)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Majburiy',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          SizedBox(height: dense ? 14 : 18),
          ...children,
        ],
      ),
    );
  }

  Widget _photosGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < _images.length; i++)
          _ImageThumb(
            file: _images[i],
            isMain: i == 0,
            onRemove: () => setState(() => _images.removeAt(i)),
          ),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) => SafeArea(
              child: Wrap(children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galereyadan tanlash'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Kamera bilan olish'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
              ]),
            ),
          ),
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.4),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    color: AppColors.primary, size: 24),
                SizedBox(height: 4),
                Text("Qo'shish",
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _amenity(IconData icon, String label, List<String> options,
      String? value, ValueChanged<String?> onChanged,
      {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: isLast ? 0 : 0),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: context.border)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((o) => ChoiceChip(
                      label: Text(o),
                      selected: value == o,
                      onSelected: (sel) => onChanged(sel ? o : null),
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                          color: value == o ? Colors.white : null,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _text(
    TextEditingController c,
    String label, {
    bool required = false,
    bool number = false,
    bool decimal = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number
            ? TextInputType.numberWithOptions(decimal: decimal)
            : TextInputType.text,
        inputFormatters: number
            ? [
                FilteringTextInputFormatter.allow(
                    decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
              ]
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        ),
      ),
    );
  }

  Widget _seg({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13, color: context.muted)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: options.entries
              .map((e) => ChoiceChip(
                    label: Text(e.value),
                    selected: value == e.key,
                    onSelected: (_) => onChanged(e.key),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                        color: value == e.key ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Sahifa tepasidagi brend gradienti — kontekst beradi va boshqa
/// "usta bo'lish" kabi sahifalar bilan vizual izchillikni saqlaydi.
class _Hero extends StatelessWidget {
  const _Hero({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_home_work_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s('estate.add'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  "Ma'lumotlarni to'ldiring — e'loningiz moderatsiyadan so'ng chop etiladi",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12,
                      height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.file, required this.isMain, required this.onRemove});
  final XFile file;
  final bool isMain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container(width: 88, height: 88, color: context.border);
              }
              return Image.memory(snap.data!, width: 88, height: 88, fit: BoxFit.cover);
            },
          ),
        ),
        if (isMain)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Asosiy',
                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
            ),
          ),
        Positioned(
          right: 2,
          top: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
