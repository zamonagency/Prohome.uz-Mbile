import 'package:latlong2/latlong.dart';

/// O'zbekiston viloyatlari — nomi, markazi va tuman/shaharlari.
/// Rasm sifatida har bir viloyatning haqiqiy, tanish joyi ishlatiladi
/// (oldin tasodifiy/fake — picsum seed — rasmlar turardi). Endi tarmoqdan
/// jonli yuklanmaydi — oldindan kichraytirilib, ilova bilan birga
/// (`assets/images/regions/`) tarqatiladi: tezroq ochiladi va
/// internetsiz/sekin tarmoqda ham doim bir xil ko'rinadi.
class UzRegion {
  const UzRegion({
    required this.slug,
    required this.name,
    required this.center,
    required this.districts,
  });

  final String slug;
  final String name;
  final LatLng center;
  final List<String> districts;

  String get image => 'assets/images/regions/$slug.jpg';
}

const uzRegions = <UzRegion>[
  UzRegion(
    slug: 'tashkent_city',
    name: 'Toshkent shahri',
    center: LatLng(41.3111, 69.2797),
    districts: [
      'Chilonzor', 'Yunusobod', 'Mirzo Ulug‘bek', 'Yakkasaroy', 'Shayxontohur',
      'Olmazor', 'Bektemir', 'Mirobod', 'Sergeli', 'Uchtepa', 'Yashnobod',
      'Yangihayot',
    ],
  ),
  UzRegion(
    slug: 'tashkent_region',
    name: 'Toshkent viloyati',
    center: LatLng(41.0, 69.6),
    districts: [
      'Nurafshon', 'Angren', 'Bekobod', 'Chirchiq', 'Ohangaron', 'Olmaliq',
      'Yangiyo‘l', 'Parkent', 'Bo‘ka', 'Qibray', 'Zangiota', 'Piskent',
    ],
  ),
  UzRegion(
    slug: 'andijan',
    name: 'Andijon',
    center: LatLng(40.7821, 72.3442),
    districts: [
      'Andijon shahri', 'Asaka', 'Xonobod', 'Shahrixon', 'Marhamat', 'Baliqchi',
      'Bo‘z', 'Izboskan', 'Jalaquduq', 'Qo‘rg‘ontepa', 'Oltinko‘l', 'Paxtaobod',
    ],
  ),
  UzRegion(
    slug: 'fergana',
    name: 'Farg‘ona',
    center: LatLng(40.3864, 71.7864),
    districts: [
      'Farg‘ona shahri', 'Marg‘ilon', 'Qo‘qon', 'Quvasoy', 'Rishton', 'Beshariq',
      'Bag‘dod', 'Buvayda', 'Dang‘ara', 'Furqat', 'Oltiariq', 'Yozyovon',
    ],
  ),
  UzRegion(
    slug: 'namangan',
    name: 'Namangan',
    center: LatLng(40.9983, 71.6726),
    districts: [
      'Namangan shahri', 'Chust', 'Pop', 'Chortoq', 'Kosonsoy', 'Uychi',
      'To‘raqo‘rg‘on', 'Norin', 'Mingbuloq', 'Uchqo‘rg‘on', 'Yangiqo‘rg‘on',
    ],
  ),
  UzRegion(
    slug: 'samarkand',
    name: 'Samarqand',
    center: LatLng(39.6270, 66.9750),
    districts: [
      'Samarqand shahri', 'Kattaqo‘rg‘on', 'Urgut', 'Bulung‘ur', 'Jomboy',
      'Ishtixon', 'Oqdaryo', 'Payariq', 'Pastdarg‘om', 'Nurobod', 'Toyloq',
    ],
  ),
  UzRegion(
    slug: 'bukhara',
    name: 'Buxoro',
    center: LatLng(39.7680, 64.4550),
    districts: [
      'Buxoro shahri', 'Kogon', 'G‘ijduvon', 'Vobkent', 'Shofirkon', 'Romitan',
      'Jondor', 'Qorako‘l', 'Olot', 'Peshku', 'Qorovulbozor',
    ],
  ),
  UzRegion(
    slug: 'khorezm',
    name: 'Xorazm (Xiva)',
    center: LatLng(41.3775, 60.3619),
    districts: [
      'Urganch', 'Xiva', 'Shovot', 'Hazorasp', 'Bog‘ot', 'Gurlan', 'Qo‘shko‘pir',
      'Xonqa', 'Yangiariq', 'Yangibozor',
    ],
  ),
  UzRegion(
    slug: 'navoi',
    name: 'Navoiy',
    center: LatLng(40.0844, 65.3792),
    districts: [
      'Navoiy shahri', 'Zarafshon', 'Uchquduq', 'Konimex', 'Karmana', 'Nurota',
      'Xatirchi', 'Qiziltepa', 'Tomdi',
    ],
  ),
  UzRegion(
    slug: 'kashkadarya',
    name: 'Qashqadaryo',
    center: LatLng(38.8610, 65.7890),
    districts: [
      'Qarshi', 'Shahrisabz', 'Kitob', 'G‘uzor', 'Koson', 'Muborak', 'Chiroqchi',
      'Dehqonobod', 'Kasbi', 'Mirishkor', 'Nishon', 'Qamashi', 'Yakkabog‘',
    ],
  ),
  UzRegion(
    slug: 'surkhandarya',
    name: 'Surxondaryo',
    center: LatLng(37.9410, 67.5710),
    districts: [
      'Termiz', 'Denov', 'Sherobod', 'Boysun', 'Sho‘rchi', 'Angor', 'Bandixon',
      'Jarqo‘rg‘on', 'Qiziriq', 'Qumqo‘rg‘on', 'Muzrabot', 'Oltinsoy', 'Sariosiyo',
    ],
  ),
  UzRegion(
    slug: 'jizzakh',
    name: 'Jizzax',
    center: LatLng(40.1250, 67.8800),
    districts: [
      'Jizzax shahri', 'G‘allaorol', 'Zomin', 'Baxmal', 'Do‘stlik', 'Forish',
      'Mirzacho‘l', 'Paxtakor', 'Yangiobod', 'Zarbdor', 'Zafarobod', 'Arnasoy',
    ],
  ),
  UzRegion(
    slug: 'syrdarya',
    name: 'Sirdaryo',
    center: LatLng(40.4830, 68.7870),
    districts: [
      'Guliston', 'Yangiyer', 'Shirin', 'Sirdaryo', 'Boyovut', 'Sayxunobod',
      'Mirzaobod', 'Oqoltin', 'Xovos', 'Guliston tumani',
    ],
  ),
  UzRegion(
    slug: 'karakalpakstan',
    name: 'Qoraqalpog‘iston',
    center: LatLng(42.4600, 59.6100),
    districts: [
      'Nukus', 'Xo‘jayli', 'Chimboy', 'Taxiatosh', 'Beruniy', 'To‘rtko‘l',
      'Amudaryo', 'Qo‘ng‘irot', 'Mo‘ynoq', 'Kegeyli', 'Qanliko‘l', 'Shumanay',
      'Taxtako‘pir', 'Ellikqal‘a',
    ],
  ),
];

UzRegion regionBySlug(String slug) =>
    uzRegions.firstWhere((r) => r.slug == slug, orElse: () => uzRegions.first);
