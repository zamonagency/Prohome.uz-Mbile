/// Frontend (prohome-b2c_front) veb-saytidagi "E'lon qo'shish" ustasi bilan
/// bir xil variantlar — shu bilan bir xil chiroyli, avtomatik ta'rif hosil
/// qiladigan mantiq mobil ilovada ham ishlaydi.
library;

class AmenityOption {
  const AmenityOption(this.value, this.icon);
  final String value;
  final String icon; // Material icon nomi emas — kodda alohida map qilinadi
}

const repairOptions = [
  "Ta'mirsiz",
  "Yangi ta'mir",
  'Qora suvoq',
  'Oq suvoq',
  "Evro ta'mir",
  "Dizayner ta'mir",
  "O'rtacha",
];
const gasOptions = ["Yo'q", 'Magistral', 'Gaz balloni'];
const heatingOptions = ["Yo'q", 'Markaziy', 'Avtonom', 'Elektr'];
const sewageOptions = ["Yo'q", 'Markaziy', 'Septik'];
const waterOptions = ["Yo'q", 'Markaziy', 'Quduq', 'Doimiy'];
const electricityOptions = ["Yo'q", 'Markaziy', 'Quyosh batareyalik'];
const parkingOptions = ['Yer usti', 'Yer osti', "Yo'q"];
const buildingTypeOptions = ['Panel', "G'isht", 'Monolit', 'Blok'];

class PropertyCategory {
  const PropertyCategory(this.label, this.propertyType);
  final String label;
  final String propertyType;
}

const propertyCategories = [
  PropertyCategory('Yangi binoda kvartira', 'APARTMENT'),
  PropertyCategory('Ikkilamchi kvartira', 'APARTMENT'),
  PropertyCategory('Hovli - uy', 'HOUSE'),
  PropertyCategory('Kottej', 'HOUSE'),
  PropertyCategory('Ofis', 'OFFICE'),
  PropertyCategory('Bino', 'RETAIL'),
  PropertyCategory('Garaj', 'RETAIL'),
  PropertyCategory('Savdo yer maydoni', 'RETAIL'),
];

/// Foydalanuvchi javob bergan savollardan (qulayliklar) chiroyli,
/// tayyor ta'rif matnini yig'ib beradi — veb saytdagi
/// `generateDescriptionDraft()` bilan bir xil mantiq.
String buildAutoDescription({
  required String categoryLabel,
  required String dealType,
  required String areaSize,
  required String roomCount,
  String? floor,
  String? totalFloors,
  String? livingArea,
  String? repairType,
  String? gas,
  String? heating,
  String? sewage,
  String? water,
  String? electricity,
  String? parking,
  String? buildingType,
  String? locationName,
}) {
  final deal = dealType == 'RENT' ? 'ijaraga beriladi' : 'sotiladi';
  final floorText =
      (floor?.isNotEmpty ?? false) || (totalFloors?.isNotEmpty ?? false)
          ? '${floor?.isNotEmpty ?? false ? floor : '-'}${totalFloors?.isNotEmpty ?? false ? '/$totalFloors' : ''}'
          : '';
  final lines = <String>[
    '$categoryLabel $deal.',
    if (areaSize.isNotEmpty) 'Maydoni: $areaSize m².',
    if (livingArea?.isNotEmpty ?? false) 'Yashash maydoni: $livingArea m².',
    if (roomCount.isNotEmpty) 'Xonalar soni: $roomCount.',
    if (floorText.isNotEmpty) 'Qavat: $floorText.',
    if (buildingType?.isNotEmpty ?? false) 'Uy turi: $buildingType.',
    if (repairType?.isNotEmpty ?? false) "Ta'mirlash holati: $repairType.",
    if (gas?.isNotEmpty ?? false) 'Gaz: $gas.',
    if (heating?.isNotEmpty ?? false) 'Isitish tizimi: $heating.',
    if (water?.isNotEmpty ?? false) 'Suv ta\'minoti: $water.',
    if (sewage?.isNotEmpty ?? false) 'Kanalizatsiya: $sewage.',
    if (electricity?.isNotEmpty ?? false) 'Elektr ta\'minoti: $electricity.',
    if (parking?.isNotEmpty ?? false) 'Avtoturargoh: $parking.',
    if (locationName?.isNotEmpty ?? false) 'Manzil: $locationName.',
    "Qo'shimcha savollar bo'lsa, telefon orqali bog'lanishingiz mumkin.",
  ];
  return lines.join('\n');
}
