/// Yengil, kod-generatorsiz lokalizatsiya.
/// Til o'zgarganda [stringsProvider] yangi [AppStrings] beradi.
enum AppLang { uz, ru, en }

extension AppLangX on AppLang {
  String get code => name;
  String get label => switch (this) {
        AppLang.uz => "O'zbekcha",
        AppLang.ru => 'Русский',
        AppLang.en => 'English',
      };
  static AppLang fromCode(String? c) => switch (c) {
        'ru' => AppLang.ru,
        'en' => AppLang.en,
        _ => AppLang.uz,
      };
}

class AppStrings {
  const AppStrings(this.lang);
  final AppLang lang;

  String call(String key) {
    final table = _data[key];
    if (table == null) return key;
    return table[lang] ?? table[AppLang.uz] ?? key;
  }

  static const Map<String, Map<AppLang, String>> _data = {
    // ── Common ────────────────────────────────────────────────────────────
    'app.name': {AppLang.uz: 'ProHome', AppLang.ru: 'ProHome', AppLang.en: 'ProHome'},
    'common.retry': {AppLang.uz: 'Qayta urinish', AppLang.ru: 'Повторить', AppLang.en: 'Retry'},
    'common.loading': {AppLang.uz: 'Yuklanmoqda…', AppLang.ru: 'Загрузка…', AppLang.en: 'Loading…'},
    'common.empty': {AppLang.uz: "Ma'lumot yo'q", AppLang.ru: 'Нет данных', AppLang.en: 'No data'},
    'common.all': {AppLang.uz: 'Hammasi', AppLang.ru: 'Все', AppLang.en: 'All'},
    'common.search': {AppLang.uz: 'Qidirish', AppLang.ru: 'Поиск', AppLang.en: 'Search'},
    'common.filter': {AppLang.uz: 'Filtr', AppLang.ru: 'Фильтр', AppLang.en: 'Filter'},
    'common.apply': {AppLang.uz: 'Qo‘llash', AppLang.ru: 'Применить', AppLang.en: 'Apply'},
    'common.reset': {AppLang.uz: 'Tozalash', AppLang.ru: 'Сбросить', AppLang.en: 'Reset'},
    'common.cancel': {AppLang.uz: 'Bekor qilish', AppLang.ru: 'Отмена', AppLang.en: 'Cancel'},
    'common.save': {AppLang.uz: 'Saqlash', AppLang.ru: 'Сохранить', AppLang.en: 'Save'},
    'common.call': {AppLang.uz: 'Qo‘ng‘iroq', AppLang.ru: 'Позвонить', AppLang.en: 'Call'},
    'common.share': {AppLang.uz: 'Ulashish', AppLang.ru: 'Поделиться', AppLang.en: 'Share'},
    'common.from': {AppLang.uz: 'dan', AppLang.ru: 'от', AppLang.en: 'from'},
    'common.currency': {AppLang.uz: "so'm", AppLang.ru: 'сум', AppLang.en: 'UZS'},
    'common.error': {AppLang.uz: 'Xatolik yuz berdi', AppLang.ru: 'Произошла ошибка', AppLang.en: 'Something went wrong'},
    'common.view_all': {AppLang.uz: 'Barchasi', AppLang.ru: 'Смотреть все', AppLang.en: 'View all'},
    'common.results': {AppLang.uz: 'ta natija', AppLang.ru: 'результатов', AppLang.en: 'results'},
    'common.view_list': {AppLang.uz: 'Ro‘yxat ko‘rinishi', AppLang.ru: 'Список', AppLang.en: 'List view'},
    'common.view_grid': {AppLang.uz: 'Katak ko‘rinishi', AppLang.ru: 'Сетка', AppLang.en: 'Grid view'},

    // ── Nav ──────────────────────────────────────────────────────────────
    'nav.home': {AppLang.uz: 'Asosiy', AppLang.ru: 'Главная', AppLang.en: 'Home'},
    'nav.catalog': {AppLang.uz: 'Katalog', AppLang.ru: 'Каталог', AppLang.en: 'Catalog'},
    'nav.market': {AppLang.uz: 'Bozor', AppLang.ru: 'Маркет', AppLang.en: 'Market'},
    'nav.favorites': {AppLang.uz: 'Saqlangan', AppLang.ru: 'Избранное', AppLang.en: 'Saved'},
    'nav.chats': {AppLang.uz: 'Suhbatlar', AppLang.ru: 'Чаты', AppLang.en: 'Chats'},
    'nav.profile': {AppLang.uz: 'Profil', AppLang.ru: 'Профиль', AppLang.en: 'Profile'},

    // ── Home ─────────────────────────────────────────────────────────────
    'home.search_hint': {AppLang.uz: 'Uy, usta yoki ish qidiring', AppLang.ru: 'Жильё, мастера или работа', AppLang.en: 'Homes, pros or jobs'},
    'home.sec_recommended': {AppLang.uz: 'Siz uchun tavsiya', AppLang.ru: 'Рекомендуем вам', AppLang.en: 'Recommended for you'},
    'home.sec_recent': {AppLang.uz: 'Oxirgi ko‘rilganlar', AppLang.ru: 'Недавно просмотренные', AppLang.en: 'Recently viewed'},
    'home.sec_nearby': {AppLang.uz: 'Yaqin atrofingizda', AppLang.ru: 'Рядом с вами', AppLang.en: 'Near you'},
    'home.sec_similar_estates': {AppLang.uz: 'O‘xshash e’lonlar', AppLang.ru: 'Похожие объявления', AppLang.en: 'Similar listings'},
    'home.sec_similar_masters': {AppLang.uz: 'O‘xshash ustalar', AppLang.ru: 'Похожие мастера', AppLang.en: 'Similar pros'},
    'home.sec_fresh_estates': {AppLang.uz: 'Yangi e’lonlar', AppLang.ru: 'Свежие объявления', AppLang.en: 'Fresh listings'},
    'home.sec_rent': {AppLang.uz: 'Ijaraga beriladi', AppLang.ru: 'Сдаётся в аренду', AppLang.en: 'For rent'},
    'home.sec_new_builds': {AppLang.uz: 'Yangi binolar', AppLang.ru: 'Новостройки', AppLang.en: 'New builds'},
    'home.sec_top_masters': {AppLang.uz: 'Top ustalar', AppLang.ru: 'Лучшие мастера', AppLang.en: 'Top pros'},
    'home.sec_jobs': {AppLang.uz: 'Ish e’lonlari', AppLang.ru: 'Вакансии', AppLang.en: 'Jobs'},
    'home.sec_news': {AppLang.uz: 'Yangiliklar', AppLang.ru: 'Новости', AppLang.en: 'News'},
    'home.brand_tagline': {
      AppLang.uz: 'Uy-joy, ustalar va ish — hammasi bir joyda.',
      AppLang.ru: 'Жильё, мастера и работа — всё в одном месте.',
      AppLang.en: 'Homes, pros and jobs — all in one place.',
    },

    // ── Intent (bosh sahifa tanlov kartalari) ────────────────────────────
    'intent.buy': {AppLang.uz: 'Uy olish', AppLang.ru: 'Купить', AppLang.en: 'Buy home'},
    'intent.sell': {AppLang.uz: 'Uy sotish', AppLang.ru: 'Продать', AppLang.en: 'Sell home'},
    'intent.find_master': {AppLang.uz: 'Usta topish', AppLang.ru: 'Найти мастера', AppLang.en: 'Find a pro'},
    'intent.become_master': {AppLang.uz: 'Usta bo‘lish', AppLang.ru: 'Стать мастером', AppLang.en: 'Become a pro'},

    // ── Map / regions ────────────────────────────────────────────────────
    'map.title': {AppLang.uz: 'Xarita', AppLang.ru: 'Карта', AppLang.en: 'Map'},
    'map.pick_region': {AppLang.uz: 'Viloyatni tanlang', AppLang.ru: 'Выберите регион', AppLang.en: 'Choose a region'},
    'map.pick_district': {AppLang.uz: 'Tuman yoki shaharni tanlang', AppLang.ru: 'Выберите район или город', AppLang.en: 'Choose a district or city'},
    'map.open_map': {AppLang.uz: 'Xaritada ochish', AppLang.ru: 'Открыть на карте', AppLang.en: 'Open on map'},
    'map.search_here': {AppLang.uz: 'Shu hududda qidirish', AppLang.ru: 'Искать в этом районе', AppLang.en: 'Search in this area'},
    'map.listings_here': {AppLang.uz: 'Shu yerdagi e’lonlar', AppLang.ru: 'Объявления здесь', AppLang.en: 'Listings here'},

    // ── Categories ───────────────────────────────────────────────────────
    'cat.estates': {AppLang.uz: 'Ko‘chmas mulk', AppLang.ru: 'Недвижимость', AppLang.en: 'Real estate'},
    'cat.newbuilds': {AppLang.uz: 'Yangi binolar', AppLang.ru: 'Новостройки', AppLang.en: 'New builds'},
    'cat.masters': {AppLang.uz: 'Ustalar', AppLang.ru: 'Мастера', AppLang.en: 'Pros'},
    'cat.jobs': {AppLang.uz: 'Ishlar', AppLang.ru: 'Работа', AppLang.en: 'Jobs'},
    'cat.companies': {AppLang.uz: 'Quruvchilar', AppLang.ru: 'Застройщики', AppLang.en: 'Developers'},
    'cat.news': {AppLang.uz: 'Blog', AppLang.ru: 'Блог', AppLang.en: 'Blog'},

    // ── Real estate ──────────────────────────────────────────────────────
    'estate.rooms': {AppLang.uz: 'xona', AppLang.ru: 'комн.', AppLang.en: 'rooms'},
    'estate.floor': {AppLang.uz: 'qavat', AppLang.ru: 'этаж', AppLang.en: 'floor'},
    'estate.area': {AppLang.uz: 'maydon', AppLang.ru: 'площадь', AppLang.en: 'area'},
    'estate.deal_sale': {AppLang.uz: 'Sotiladi', AppLang.ru: 'Продажа', AppLang.en: 'Sale'},
    'estate.deal_rent': {AppLang.uz: 'Ijaraga', AppLang.ru: 'Аренда', AppLang.en: 'Rent'},
    'estate.type_apartment': {AppLang.uz: 'Kvartira', AppLang.ru: 'Квартира', AppLang.en: 'Apartment'},
    'estate.type_house': {AppLang.uz: 'Uy', AppLang.ru: 'Дом', AppLang.en: 'House'},
    'estate.type_office': {AppLang.uz: 'Ofis', AppLang.ru: 'Офис', AppLang.en: 'Office'},
    'estate.type_retail': {AppLang.uz: 'Savdo maydoni', AppLang.ru: 'Коммерция', AppLang.en: 'Retail'},
    'estate.description': {AppLang.uz: 'Tavsif', AppLang.ru: 'Описание', AppLang.en: 'Description'},
    'estate.on_map': {AppLang.uz: 'Xaritada', AppLang.ru: 'На карте', AppLang.en: 'On map'},
    'estate.contact': {AppLang.uz: 'Bog‘lanish', AppLang.ru: 'Контакты', AppLang.en: 'Contact'},
    'estate.views': {AppLang.uz: 'ko‘rish', AppLang.ru: 'просмотров', AppLang.en: 'views'},
    'estate.add': {AppLang.uz: 'E’lon berish', AppLang.ru: 'Разместить объявление', AppLang.en: 'Post a listing'},

    // ── Filter ───────────────────────────────────────────────────────────
    'filter.deal': {AppLang.uz: 'Bitim turi', AppLang.ru: 'Тип сделки', AppLang.en: 'Deal type'},
    'filter.type': {AppLang.uz: 'Mulk turi', AppLang.ru: 'Тип недвижимости', AppLang.en: 'Property type'},
    'filter.price': {AppLang.uz: 'Narx', AppLang.ru: 'Цена', AppLang.en: 'Price'},
    'filter.rooms': {AppLang.uz: 'Xonalar soni', AppLang.ru: 'Комнат', AppLang.en: 'Rooms'},
    'filter.price_min': {AppLang.uz: 'dan', AppLang.ru: 'от', AppLang.en: 'min'},
    'filter.price_max': {AppLang.uz: 'gacha', AppLang.ru: 'до', AppLang.en: 'max'},
    'filter.region': {AppLang.uz: 'Hudud', AppLang.ru: 'Регион', AppLang.en: 'Region'},

    // ── Masters ──────────────────────────────────────────────────────────
    'master.experience': {AppLang.uz: 'yil tajriba', AppLang.ru: 'лет опыта', AppLang.en: 'yrs exp.'},
    'master.free_now': {AppLang.uz: 'Hozir bo‘sh', AppLang.ru: 'Свободен', AppLang.en: 'Available'},
    'master.team': {AppLang.uz: 'Jamoa (brigada)', AppLang.ru: 'Бригада', AppLang.en: 'Team'},
    'master.busy': {AppLang.uz: 'Band', AppLang.ru: 'Занят', AppLang.en: 'Busy'},
    'master.portfolio': {AppLang.uz: 'Ishlari', AppLang.ru: 'Работы', AppLang.en: 'Portfolio'},
    'master.reviews': {AppLang.uz: 'Sharhlar', AppLang.ru: 'Отзывы', AppLang.en: 'Reviews'},
    'master.write': {AppLang.uz: 'Yozish', AppLang.ru: 'Написать', AppLang.en: 'Message'},
    'master.skills': {AppLang.uz: 'Ko‘nikmalar', AppLang.ru: 'Навыки', AppLang.en: 'Skills'},

    // ── Jobs ─────────────────────────────────────────────────────────────
    'job.status_open': {AppLang.uz: 'Ochiq', AppLang.ru: 'Открыт', AppLang.en: 'Open'},
    'job.budget': {AppLang.uz: 'Byudjet', AppLang.ru: 'Бюджет', AppLang.en: 'Budget'},
    'job.respond': {AppLang.uz: 'Bog‘lanish', AppLang.ru: 'Откликнуться', AppLang.en: 'Respond'},

    // ── Auth ─────────────────────────────────────────────────────────────
    'auth.login': {AppLang.uz: 'Kirish', AppLang.ru: 'Вход', AppLang.en: 'Sign in'},
    'auth.logout': {AppLang.uz: 'Chiqish', AppLang.ru: 'Выйти', AppLang.en: 'Sign out'},
    'auth.register': {AppLang.uz: 'Ro‘yxatdan o‘tish', AppLang.ru: 'Регистрация', AppLang.en: 'Sign up'},
    'auth.phone': {AppLang.uz: 'Telefon raqami', AppLang.ru: 'Номер телефона', AppLang.en: 'Phone number'},
    'auth.phone_hint': {AppLang.uz: '+998 90 123 45 67', AppLang.ru: '+998 90 123 45 67', AppLang.en: '+998 90 123 45 67'},
    'auth.continue': {AppLang.uz: 'Davom etish', AppLang.ru: 'Продолжить', AppLang.en: 'Continue'},
    'auth.otp_title': {AppLang.uz: 'Tasdiqlash kodi', AppLang.ru: 'Код подтверждения', AppLang.en: 'Verification code'},
    'auth.otp_sent': {AppLang.uz: 'raqamiga 6 xonali kod yuborildi', AppLang.ru: 'на номер отправлен 6-значный код', AppLang.en: 'a 6-digit code was sent to'},
    'auth.otp_resend': {AppLang.uz: 'Kodni qayta yuborish', AppLang.ru: 'Отправить код снова', AppLang.en: 'Resend code'},
    'auth.password': {AppLang.uz: 'Parol', AppLang.ru: 'Пароль', AppLang.en: 'Password'},
    'auth.login_with_password': {AppLang.uz: 'Parol bilan kirish', AppLang.ru: 'Войти по паролю', AppLang.en: 'Sign in with password'},
    'auth.login_with_otp': {AppLang.uz: 'SMS-kod bilan kirish', AppLang.ru: 'Войти по SMS', AppLang.en: 'Sign in with SMS'},
    'auth.first_name': {AppLang.uz: 'Ism', AppLang.ru: 'Имя', AppLang.en: 'First name'},
    'auth.last_name': {AppLang.uz: 'Familiya', AppLang.ru: 'Фамилия', AppLang.en: 'Last name'},
    'auth.need_login': {AppLang.uz: 'Bu bo‘lim uchun tizimga kiring', AppLang.ru: 'Войдите, чтобы продолжить', AppLang.en: 'Sign in to continue'},
    'auth.no_account': {AppLang.uz: 'Hisobingiz yo‘qmi?', AppLang.ru: 'Нет аккаунта?', AppLang.en: 'No account yet?'},
    'auth.guest': {AppLang.uz: 'Mehmon', AppLang.ru: 'Гость', AppLang.en: 'Guest'},

    // ── Profile ──────────────────────────────────────────────────────────
    'profile.my_listings': {AppLang.uz: 'Mening e’lonlarim', AppLang.ru: 'Мои объявления', AppLang.en: 'My listings'},
    'profile.notifications': {AppLang.uz: 'Bildirishnomalar', AppLang.ru: 'Уведомления', AppLang.en: 'Notifications'},
    'notif.mark_all_read': {AppLang.uz: 'Hammasini o‘qish', AppLang.ru: 'Прочитать все', AppLang.en: 'Mark all read'},
    'profile.language': {AppLang.uz: 'Til', AppLang.ru: 'Язык', AppLang.en: 'Language'},
    'profile.currency': {AppLang.uz: 'Valyuta', AppLang.ru: 'Валюта', AppLang.en: 'Currency'},
    'profile.theme': {AppLang.uz: 'Mavzu', AppLang.ru: 'Тема', AppLang.en: 'Theme'},
    'profile.theme_system': {AppLang.uz: 'Tizim', AppLang.ru: 'Система', AppLang.en: 'System'},
    'profile.theme_light': {AppLang.uz: 'Yorug‘', AppLang.ru: 'Светлая', AppLang.en: 'Light'},
    'profile.theme_dark': {AppLang.uz: 'Tungi', AppLang.ru: 'Тёмная', AppLang.en: 'Dark'},
    'profile.edit': {AppLang.uz: 'Profilni tahrirlash', AppLang.ru: 'Редактировать профиль', AppLang.en: 'Edit profile'},
    'profile.about': {AppLang.uz: 'Ilova haqida', AppLang.ru: 'О приложении', AppLang.en: 'About'},

    // ── Favorites ────────────────────────────────────────────────────────
    'fav.empty': {AppLang.uz: 'Hali saqlangan e’lon yo‘q', AppLang.ru: 'Пока нет избранного', AppLang.en: 'Nothing saved yet'},
    'fav.added': {AppLang.uz: 'Saqlanganlarga qo‘shildi', AppLang.ru: 'Добавлено в избранное', AppLang.en: 'Added to saved'},
    'fav.removed': {AppLang.uz: 'Saqlanganlardan olib tashlandi', AppLang.ru: 'Удалено из избранного', AppLang.en: 'Removed from saved'},

    // ── Chat ─────────────────────────────────────────────────────────────
    'chat.empty': {AppLang.uz: 'Suhbatlar yo‘q', AppLang.ru: 'Нет чатов', AppLang.en: 'No chats'},
    'chat.message_hint': {AppLang.uz: 'Xabar yozing…', AppLang.ru: 'Сообщение…', AppLang.en: 'Message…'},

    // ── Market ───────────────────────────────────────────────────────────
    'market.title': {AppLang.uz: 'Bozor', AppLang.ru: 'Маркет', AppLang.en: 'Market'},
    'market.subtitle': {AppLang.uz: 'OLX, Uzum va boshqa manbalardan e’lonlar', AppLang.ru: 'Объявления из OLX, Uzum и др.', AppLang.en: 'Listings from OLX, Uzum & more'},
    'market.source_prohome': {AppLang.uz: 'ProHome', AppLang.ru: 'ProHome', AppLang.en: 'ProHome'},
    'market.source_olx': {AppLang.uz: 'OLX', AppLang.ru: 'OLX', AppLang.en: 'OLX'},
    'market.source_wenny': {AppLang.uz: 'Joymee / Wenny', AppLang.ru: 'Joymee / Wenny', AppLang.en: 'Joymee / Wenny'},
    'market.open_source': {AppLang.uz: 'Manbada ochish', AppLang.ru: 'Открыть в источнике', AppLang.en: 'Open in source'},
  };
}
