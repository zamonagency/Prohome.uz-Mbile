# ProHome B2C — Mobil ilova (Flutter / Dart)

`prohome-your-trusted-hub` (React) frontendining mobil versiyasi. Ko'chmas mulk
e'lonlari, yangi binolar, ustalar, ish e'lonlari, quruvchi kompaniyalar, blog,
chat va OLX / Joymee (Wenny) kabi tashqi bozorlar — barchasi bitta ilovada.

Backend o'zgartirilmagan — web bilan **bir xil API** ishlatiladi:

| Maqsad | Manzil |
| --- | --- |
| Asosiy B2C API | `https://api-b2c.prohome.uz` |
| Yangi binolar (advanced) | `https://backend.prohome.uz/api/v1` |
| Wenny / Joymee marketpleys | `https://backen.prohome.uz/api` |
| OLX e'lonlari (feed) | `https://prohome.uz/olx-real-estates.json` |

Barcha manzillarni `--dart-define` orqali almashtirsa bo'ladi (`lib/src/core/config/env.dart`).

---

## Texnologiyalar

- **Flutter 3.32+ / Dart 3.8+**, Material 3
- **flutter_riverpod** — holat boshqaruvi va DI
- **go_router** — navigatsiya (bottom-nav shell + full-screen sahifalar)
- **dio** — HTTP klient (avto `Bearer` token, 401 da `refresh` va so'rovni takrorlash)
- **flutter_secure_storage** — access/refresh tokenlar (Keystore/Keychain)
- **cached_network_image + shimmer** — rasm keshi va skeleton yuklanish
- **infinite_scroll_pagination** — cheksiz skroll ro'yxatlar
- **flutter_map (OpenStreetMap)** — web'dagi `react-leaflet` bilan mos xarita
- **carousel_slider**, **smooth_page_indicator** — bannerlar va galereya

## Loyiha tuzilishi

```
lib/
  main.dart                     # ProviderScope + SharedPreferences bootstrap
  src/
    app/                        # App widget, theme, router, settings (til/mavzu)
    core/
      config/env.dart           # API manzillari
      network/                  # ApiClient (dio), ApiException
      storage/token_storage.dart
      utils/                    # media URL, formatlash, call/share
    common/
      models/                   # Paginated, User, Location
      widgets/                  # AppNetworkImage, AppPagedList, ImageGallery, MiniMap ...
    l10n/strings.dart           # uz / ru / en lug'at (kod-generatorsiz)
    features/
      auth/                     # telefon → OTP → login/register, refresh, profil
      home/                     # bosh sahifa (banner, kategoriya, bo'limlar)
      catalog/                  # kategoriyalar hub
      realestate/               # e'lonlar ro'yxati + filtr + detal + "E'lon berish"
      newbuilds/                # yangi binolar (B2C rooms) ro'yxati + detal
      masters/                  # ustalar ro'yxati + detal + reyting/portfolio
      jobs/                     # ish e'lonlari ro'yxati + detal
      companies/                # quruvchilar ro'yxati + detal (majmualar)
      news/                     # blog ro'yxati + maqola
      chat/                     # suhbatlar ro'yxati + xabarlar oynasi (REST)
      favorites/                # saqlanganlar (lokal + server "like")
      notifications/            # bildirishnomalar
      marketplace/              # ProHome + OLX + Joymee/Wenny yagona bozor
      profile/                  # profil, tahrirlash, til, mavzu, chiqish
      shell/                    # pastki navigatsiya
```

## Ishga tushirish

Qisqa qo'llanma → **[ULANISH.md](ULANISH.md)** (o'rnatish + telefonga ulash).

```bash
flutter pub get
flutter run           # ulangan qurilma/emulyatorda
```
