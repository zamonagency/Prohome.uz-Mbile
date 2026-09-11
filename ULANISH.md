# ProHome B2C mobil ilovani ishga tushirish va telefonga ulash

Qisqa, amaliy qo'llanma. Barcha buyruqlar shu papka (`prohome_b2c_modile/`) ichida bajariladi.

---

## 1. Kerakli dasturlar (bir marta)

1. **Flutter SDK 3.32+** — https://docs.flutter.dev/get-started/install
   `flutter --version` ishlashi kerak.
2. **Android**: Android Studio → SDK, "USB debugging" uchun. Yoki faqat `cmdline-tools`.
3. **iOS (ixtiyoriy, faqat macOS)**: Xcode + CocoaPods.
4. Tekshiruv:
   ```bash
   flutter doctor
   ```
   Barcha kerakli qatordan yashil ✓ bo'lsin (brauzer/Chrome shart emas).

---

## 2. Platforma papkalarini yaratish (bir marta)

Bu repoda faqat `lib/`, `pubspec.yaml` va konfiglar bor. `android/`, `ios/` papkalari
`flutter create` bilan qo'shiladi (mavjud `lib/` va `pubspec.yaml` **o'chirilmaydi**):

```bash
flutter create --org uz.prohome --project-name prohome_b2c --platforms=android,ios .
```

Keyin paketlarni o'rnatamiz:

```bash
flutter pub get
```

> Agar versiya to'qnashuvi chiqsa:
> `flutter pub upgrade --major-versions` (so'ng qayta `flutter pub get`).

---

## 3. Android sozlamalari (bir marta)

`android/app/src/main/AndroidManifest.xml` — `<application>` dan **oldin** internet ruxsati:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

`<manifest>` ichiga (Android 11+ da tel/link ochilishi uchun), `<application>` dan tashqarida:

```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
  <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
</queries>
```

`android/app/build.gradle` (yoki `build.gradle.kts`) — `minSdk` kamida **21**:

```gradle
defaultConfig {
    minSdk = 21
    // ...
}
```

`flutter_map` xaritasi, rasmlar, `flutter_secure_storage` uchun shu yetarli.

---

## 4. Telefonni ulash

### Variant A — USB kabel orqali (eng oson)

1. Telefonda **Sozlamalar → Telefon haqida → Build number** ni 7 marta bosing
   ("Developer options" yoqiladi).
2. **Developer options → USB debugging** ni yoqing.
3. Telefonni kompyuterga USB bilan ulang, telefonda "Allow USB debugging" → **OK**.
4. Tekshiring:
   ```bash
   flutter devices
   ```
   Ro'yxatda telefoningiz ko'rinishi kerak.
5. Ishga tushiring:
   ```bash
   flutter run
   ```
   Bir nechta qurilma bo'lsa: `flutter run -d <device_id>`.

### Variant B — Wi-Fi orqali (kabelsiz, Android 11+)

1. Avval bir marta USB bilan ulang (Variant A, 1–3).
2. ```bash
   adb tcpip 5555
   adb shell ip route        # telefon IP manzilini ko'ring, masalan 192.168.1.50
   adb connect 192.168.1.50:5555
   ```
3. Kabelni uzing → `flutter run`.

### Variant C — APK yig'ib, telefonga o'rnatish

```bash
flutter build apk --release
# Fayl: build/app/outputs/flutter-apk/app-release.apk
```
Shu `.apk` ni telefonga o'tkazing va o'rnating ("Noma'lum manbalar" ruxsatini bering).

### Variant D — Emulyator

```bash
flutter emulators                 # ro'yxat
flutter emulators --launch <id>   # ishga tushirish
flutter run
```

---

## 5. Foydali buyruqlar

| Buyruq | Vazifasi |
| --- | --- |
| `flutter run` | Debug rejimida ishga tushirish (hot reload: `r`, restart: `R`) |
| `flutter run --release` | Tez, release rejimi |
| `flutter run --dart-define=API_URL=https://boshqa-server` | API manzilini almashtirish |
| `flutter build apk --release` | Android APK |
| `flutter build appbundle` | Play Store uchun `.aab` |
| `flutter build ios --release` | iOS (macOS + Xcode) |
| `flutter analyze` | Statik tahlil (xatolarni ko'rish) |
| `flutter clean && flutter pub get` | Keshni tozalash |

---

## 6. Tez-tez uchraydigan muammolar

- **"No connected devices"** → `flutter devices` bo'sh. USB debugging yoqilganini,
  kabel "data" kabel ekanini tekshiring; `adb kill-server && adb start-server`.
- **Rasm/ma'lumot kelmayapti** → internet bor-yo'qligini, `AndroidManifest.xml` da
  `INTERNET` ruxsatini tekshiring. API manzili: `lib/src/core/config/env.dart`.
- **`flutter pub get` versiya xatosi** → `flutter pub upgrade --major-versions`.
- **Gradle/AndroidX xatolari** → `flutter clean`, so'ng qayta `flutter run`.
- **iOS: CocoaPods** → `cd ios && pod install && cd ..`.

---

## 7. Nima tayyor, nima yo'q

**Tayyor (API ga ulangan):** auth (OTP + parol), bosh sahifa, e'lonlar (filtr/qidiruv/
detal/xarita/"E'lon berish"), yangi binolar, ustalar (portfolio/reyting/chat), ishlar,
kompaniyalar, blog, saqlanganlar, chat (REST), bildirishnomalar, profil, til (uz/ru/en),
tungi/kunduzgi mavzu, OLX + Joymee bozori.

**Keyingi bosqich uchun:** admin-panel (web'dagi ~28 sahifa — mobil B2C ilovaga
kiritilmagan), real-time chat (socket.io), push-bildirishnoma (FCM),
media yuklash (rasm/video e'longa). Arxitektura shu qo'shimchalarni oson qo'shishga tayyor.
