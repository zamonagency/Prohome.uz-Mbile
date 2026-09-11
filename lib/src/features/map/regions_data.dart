import 'package:latlong2/latlong.dart';

/// O'zbekiston viloyatlari — nomi, markazi va tuman/shaharlari.
/// Rasm sifatida har bir viloyatning haqiqiy, tanish joyi (Wikimedia
/// Commons'dan, ochiq litsenziyali) ishlatiladi — oldin tasodifiy/fake
/// (picsum seed) rasmlar turardi.
class UzRegion {
  const UzRegion({
    required this.slug,
    required this.name,
    required this.center,
    required this.districts,
    required this.image,
  });

  final String slug;
  final String name;
  final LatLng center;
  final List<String> districts;
  final String image;
}

const uzRegions = <UzRegion>[
  UzRegion(
    slug: 'tashkent_city',
    name: 'Toshkent shahri',
    center: LatLng(41.3111, 69.2797),
    image: 'https://upload.wikimedia.org/wikipedia/en/f/f6/Nest_One_Tashkent.jpg',
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
    image:
        'https://upload.wikimedia.org/wikipedia/commons/6/68/Chirchik_River_in_Khodzhikent.jpg',
    districts: [
      'Nurafshon', 'Angren', 'Bekobod', 'Chirchiq', 'Ohangaron', 'Olmaliq',
      'Yangiyo‘l', 'Parkent', 'Bo‘ka', 'Qibray', 'Zangiota', 'Piskent',
    ],
  ),
  UzRegion(
    slug: 'andijan',
    name: 'Andijon',
    center: LatLng(40.7821, 72.3442),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/6/63/Devonaboy_Jome_Mosque_in_Andijan.jpg',
    districts: [
      'Andijon shahri', 'Asaka', 'Xonobod', 'Shahrixon', 'Marhamat', 'Baliqchi',
      'Bo‘z', 'Izboskan', 'Jalaquduq', 'Qo‘rg‘ontepa', 'Oltinko‘l', 'Paxtaobod',
    ],
  ),
  UzRegion(
    slug: 'fergana',
    name: 'Farg‘ona',
    center: LatLng(40.3864, 71.7864),
    image: 'https://upload.wikimedia.org/wikipedia/commons/3/3e/Ferghana0234-Urinboev.jpg',
    districts: [
      'Farg‘ona shahri', 'Marg‘ilon', 'Qo‘qon', 'Quvasoy', 'Rishton', 'Beshariq',
      'Bag‘dod', 'Buvayda', 'Dang‘ara', 'Furqat', 'Oltiariq', 'Yozyovon',
    ],
  ),
  UzRegion(
    slug: 'namangan',
    name: 'Namangan',
    center: LatLng(40.9983, 71.6726),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/f/f0/Mulla_Qirg%CA%BBiz_madrasasi_04.jpg',
    districts: [
      'Namangan shahri', 'Chust', 'Pop', 'Chortoq', 'Kosonsoy', 'Uychi',
      'To‘raqo‘rg‘on', 'Norin', 'Mingbuloq', 'Uchqo‘rg‘on', 'Yangiqo‘rg‘on',
    ],
  ),
  UzRegion(
    slug: 'samarkand',
    name: 'Samarqand',
    center: LatLng(39.6270, 66.9750),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/8/8c/RegistanSquare_Samarkand.jpg',
    districts: [
      'Samarqand shahri', 'Kattaqo‘rg‘on', 'Urgut', 'Bulung‘ur', 'Jomboy',
      'Ishtixon', 'Oqdaryo', 'Payariq', 'Pastdarg‘om', 'Nurobod', 'Toyloq',
    ],
  ),
  UzRegion(
    slug: 'bukhara',
    name: 'Buxoro',
    center: LatLng(39.7680, 64.4550),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/3/39/Kalon-Ensemble_Buchara.jpg',
    districts: [
      'Buxoro shahri', 'Kogon', 'G‘ijduvon', 'Vobkent', 'Shofirkon', 'Romitan',
      'Jondor', 'Qorako‘l', 'Olot', 'Peshku', 'Qorovulbozor',
    ],
  ),
  UzRegion(
    slug: 'khorezm',
    name: 'Xorazm (Xiva)',
    center: LatLng(41.3775, 60.3619),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/4/4e/Ayaz_Khala%2C_Khorezm_%284933878305%29.jpg',
    districts: [
      'Urganch', 'Xiva', 'Shovot', 'Hazorasp', 'Bog‘ot', 'Gurlan', 'Qo‘shko‘pir',
      'Xonqa', 'Yangiariq', 'Yangibozor',
    ],
  ),
  UzRegion(
    slug: 'navoi',
    name: 'Navoiy',
    center: LatLng(40.0844, 65.3792),
    image: 'https://upload.wikimedia.org/wikipedia/commons/e/e5/Sentob_valley.jpg',
    districts: [
      'Navoiy shahri', 'Zarafshon', 'Uchquduq', 'Konimex', 'Karmana', 'Nurota',
      'Xatirchi', 'Qiziltepa', 'Tomdi',
    ],
  ),
  UzRegion(
    slug: 'kashkadarya',
    name: 'Qashqadaryo',
    center: LatLng(38.8610, 65.7890),
    image: 'https://upload.wikimedia.org/wikipedia/commons/4/49/Kashkadar_3.jpg',
    districts: [
      'Qarshi', 'Shahrisabz', 'Kitob', 'G‘uzor', 'Koson', 'Muborak', 'Chiroqchi',
      'Dehqonobod', 'Kasbi', 'Mirishkor', 'Nishon', 'Qamashi', 'Yakkabog‘',
    ],
  ),
  UzRegion(
    slug: 'surkhandarya',
    name: 'Surxondaryo',
    center: LatLng(37.9410, 67.5710),
    image: 'https://upload.wikimedia.org/wikipedia/commons/5/50/Mausoleum_Termez.jpg',
    districts: [
      'Termiz', 'Denov', 'Sherobod', 'Boysun', 'Sho‘rchi', 'Angor', 'Bandixon',
      'Jarqo‘rg‘on', 'Qiziriq', 'Qumqo‘rg‘on', 'Muzrabot', 'Oltinsoy', 'Sariosiyo',
    ],
  ),
  UzRegion(
    slug: 'jizzakh',
    name: 'Jizzax',
    center: LatLng(40.1250, 67.8800),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/8/85/Road_near_Yangikishlak_%284%D1%803%D0%91%29.jpg',
    districts: [
      'Jizzax shahri', 'G‘allaorol', 'Zomin', 'Baxmal', 'Do‘stlik', 'Forish',
      'Mirzacho‘l', 'Paxtakor', 'Yangiobod', 'Zarbdor', 'Zafarobod', 'Arnasoy',
    ],
  ),
  UzRegion(
    slug: 'syrdarya',
    name: 'Sirdaryo',
    center: LatLng(40.4830, 68.7870),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/7/79/Guliston_jome_masjidi%2C_old.jpg',
    districts: [
      'Guliston', 'Yangiyer', 'Shirin', 'Sirdaryo', 'Boyovut', 'Sayxunobod',
      'Mirzaobod', 'Oqoltin', 'Xovos', 'Guliston tumani',
    ],
  ),
  UzRegion(
    slug: 'karakalpakstan',
    name: 'Qoraqalpog‘iston',
    center: LatLng(42.4600, 59.6100),
    image:
        'https://upload.wikimedia.org/wikipedia/commons/4/4b/Berdaq_at%C4%B1nda%C7%B5%C4%B1_Qaraqalpaq_%C3%A1debiyat%C4%B1_tariyx%C4%B1_m%C3%A1mleketlik_muzeyi.jpg',
    districts: [
      'Nukus', 'Xo‘jayli', 'Chimboy', 'Taxiatosh', 'Beruniy', 'To‘rtko‘l',
      'Amudaryo', 'Qo‘ng‘irot', 'Mo‘ynoq', 'Kegeyli', 'Qanliko‘l', 'Shumanay',
      'Taxtako‘pir', 'Ellikqal‘a',
    ],
  ),
];

UzRegion regionBySlug(String slug) =>
    uzRegions.firstWhere((r) => r.slug == slug, orElse: () => uzRegions.first);
