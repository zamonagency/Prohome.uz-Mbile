import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/settings_controller.dart';
import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/utils/media.dart';
import '../jobs/job_model.dart';
import '../masters/master_model.dart';
import '../news/news_model.dart';
import '../realestate/real_estate_model.dart';

class HomeBanner {
  const HomeBanner({
    required this.id,
    this.image = '',
    this.link,
    this.title,
    this.location,
    this.order = 0,
    this.isActive = true,
  });
  final int id;
  final String image;
  final String? link;
  final String? title;
  final String? location;
  final int order;
  final bool isActive;

  factory HomeBanner.fromJson(Map<String, dynamic> j) => HomeBanner(
        id: asInt(j['id']) ?? 0,
        image: mediaUrl((j['mediaUrl'] ?? j['image'])?.toString()),
        link: j['link']?.toString(),
        title: j['title']?.toString(),
        location: j['location']?.toString(),
        order: asInt(j['order']) ?? 0,
        isActive: j['isActive'] == null ? true : asBool(j['isActive']),
      );
}

/// Bosh sahifadagi 2 qatorli, gorizontal skrol qiladigan kategoriyalar
/// (`GET /home/categories`).
class HomeCategory {
  const HomeCategory({
    required this.key,
    required this.name,
    this.description = '',
    this.count = 0,
  });
  final String key;
  final String name;
  final String description;
  final int count;

  factory HomeCategory.fromJson(Map<String, dynamic> j) => HomeCategory(
        key: j['key']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        count: asInt(j['count']) ?? 0,
      );
}

class HomeStats {
  const HomeStats({this.estates = 0, this.masters = 0, this.jobs = 0, this.companies = 0});
  final int estates;
  final int masters;
  final int jobs;
  final int companies;

  factory HomeStats.fromJson(Map<String, dynamic> j) => HomeStats(
        estates: asInt(j['realEstates'] ?? j['totalRealEstates'] ?? j['estates']) ?? 0,
        masters: asInt(j['masters'] ?? j['totalMasters']) ?? 0,
        jobs: asInt(j['jobs'] ?? j['totalJobs']) ?? 0,
        companies: asInt(j['companies'] ?? j['totalCompanies']) ?? 0,
      );
}

class HomeBundle {
  const HomeBundle({
    this.banners = const [],
    this.categories = const [],
    this.stats = const HomeStats(),
    this.freshEstates = const [],
    this.rentEstates = const [],
    this.topMasters = const [],
    this.jobs = const [],
    this.news = const [],
  });

  final List<HomeBanner> banners;
  final List<HomeCategory> categories;
  final HomeStats stats;
  final List<RealEstate> freshEstates;
  /// Faqat ijaraga (RENT) e'lonlar — mavjud bo'lsagina bo'lim ko'rsatiladi.
  final List<RealEstate> rentEstates;
  final List<Master> topMasters;
  final List<Job> jobs;
  final List<NewsPost> news;
}

/// Bosh sahifa uchun barcha so'rovlar. Tezroq ochilishi uchun oxirgi
/// muvaffaqiyatli javob (xom JSON holida) diskka keshlanadi — ilova
/// ochilganda avval kesh ko'rsatiladi, orqa fonda esa yangisi so'raladi.
class HomeRepository {
  HomeRepository(this._api, this._prefs);
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _cacheKey = 'ph_home_cache_v1';

  Future<List<dynamic>> _rawListOf(String path, {bool auth = true}) async {
    try {
      final res = await _api.get(path, auth: auth);
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return list is List ? list : const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>> _fetchRaw() async {
    final results = await Future.wait([
      _rawListOf('/banners', auth: false),
      _rawListOf('/home/categories', auth: false),
      _api.get('/home/stats').catchError((_) => <String, dynamic>{}),
      // Amalda "limitsiz" — bosh sahifa birinchi ochilishida bitta
      // so'rovda haddan tashqari katta (masalan minglab) javob kelib,
      // yuklanishni sekinlashtirmasin uchun ancha katta, lekin baribir
      // chegaralangan qiymat (150) qo'yilgan. Backendda shundan kamroq
      // e'lon bo'lsa — baribir HAMMASI keladi (chegaraga yetilmaydi).
      _api
          .get('/real-estates',
              query: {'page': 1, 'limit': 150, 'sort': 'newest'})
          .catchError((_) => const {'data': <dynamic>[]}),
      _api
          .get('/real-estates',
              query: {
                'page': 1,
                'limit': 150,
                'dealType': 'RENT',
                'sort': 'newest',
              })
          .catchError((_) => const {'data': <dynamic>[]}),
      _rawListOf('/masters/top'),
      _api.get('/jobs', query: {'page': 1, 'limit': 6}).catchError((_) => const {'data': <dynamic>[]}),
      _api
          .get('/news', query: {'page': 1, 'limit': 6, 'status': 'PUBLISHED'})
          .catchError((_) => const {'data': <dynamic>[]}),
    ]);
    return {
      'banners': results[0],
      'categories': results[1],
      'stats': results[2],
      'estates': results[3],
      'rentEstates': results[4],
      'masters': results[5],
      'jobs': results[6],
      'news': results[7],
    };
  }

  HomeBundle _mapBundle(Map<String, dynamic> raw) {
    final banners = ((raw['banners'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => HomeBanner.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isActive && (b.location == null || b.location == 'HOME_TOP'))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final categories = ((raw['categories'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => HomeCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final statsRaw = raw['stats'];
    final stats = HomeStats.fromJson(
        statsRaw is Map ? Map<String, dynamic>.from(statsRaw) : {});

    final estates = Paginated.parse(raw['estates'], RealEstate.fromJson).items;
    final rentEstates =
        Paginated.parse(raw['rentEstates'], RealEstate.fromJson).items;

    final masters = ((raw['masters'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Master.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final jobs = Paginated.parse(raw['jobs'], Job.fromJson).items;
    final news = Paginated.parse(raw['news'], NewsPost.fromJson).items;

    return HomeBundle(
      banners: banners,
      categories: categories,
      stats: stats,
      freshEstates: estates,
      rentEstates: rentEstates,
      topMasters: masters,
      jobs: jobs,
      news: news,
    );
  }

  /// Diskdagi oxirgi muvaffaqiyatli javob — bo'lmasa `null`.
  HomeBundle? readCache() {
    try {
      final raw = _prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      return _mapBundle(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<HomeBundle> load() async {
    final raw = await _fetchRaw();
    final bundle = _mapBundle(raw);
    unawaited(_writeCache(raw));
    return bundle;
  }

  Future<void> _writeCache(Map<String, dynamic> raw) async {
    try {
      await _prefs.setString(_cacheKey, jsonEncode(raw));
    } catch (_) {
      // kesh yozib bo'lmasa ham ilova ishlayveradi
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(apiClientProvider), ref.watch(sharedPrefsProvider)),
);

/// Kesh-avval, keyin tarmoq (stale-while-revalidate): kesh bo'lsa darhol
/// ko'rsatiladi va orqa fonda yangilanadi; bo'lmasa oddiy tarmoq so'rovi
/// kutiladi. Pastga tortib yangilashda esa har doim tarmoqdan so'raladi.
class HomeBundleController extends AsyncNotifier<HomeBundle> {
  @override
  Future<HomeBundle> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    final cached = repo.readCache();
    if (cached != null) {
      unawaited(_refreshInBackground(repo));
      return cached;
    }
    return repo.load();
  }

  Future<void> _refreshInBackground(HomeRepository repo) async {
    try {
      final fresh = await repo.load();
      state = AsyncData(fresh);
    } catch (_) {
      // kesh ko'rsatilgani yetarli — xatoni yutamiz
    }
  }

  /// Pastga tortib yangilash — har doim tarmoqdan so'raydi.
  Future<void> refresh() async {
    state = const AsyncLoading<HomeBundle>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => ref.read(homeRepositoryProvider).load());
  }
}

final homeBundleProvider =
    AsyncNotifierProvider<HomeBundleController, HomeBundle>(HomeBundleController.new);
