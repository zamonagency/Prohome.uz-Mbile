import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/view/become_master_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/otp_page.dart';
import '../features/auth/view/register_flow_page.dart';
import '../features/auth/view/register_page.dart';
import '../features/chat/view/chat_thread_page.dart';
import '../features/chat/view/chats_page.dart';
import '../features/companies/view/company_detail_page.dart';
import '../features/companies/view/companies_page.dart';
import '../features/favorites/view/favorites_page.dart';
import '../features/home/view/home_page.dart';
import '../features/jobs/view/job_detail_page.dart';
import '../features/jobs/view/jobs_page.dart';
import '../features/map/map_page.dart';
import '../features/map/region_detail_page.dart';
import '../features/newbuilds/view/newbuilds_page.dart';
import '../features/newbuilds/view/room_detail_page.dart';
import '../features/news/view/news_detail_page.dart';
import '../features/news/view/news_page.dart';
import '../features/notifications/view/notifications_page.dart';
import '../features/masters/view/master_detail_page.dart';
import '../features/masters/view/masters_page.dart';
import '../features/profile/view/edit_profile_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/realestate/real_estate_repository.dart';
import '../features/realestate/view/add_listing_page.dart';
import '../features/realestate/view/real_estate_detail_page.dart';
import '../features/realestate/view/real_estate_list_page.dart';
import '../features/search/view/search_page.dart';
import '../features/shell/app_shell.dart';
import '../features/catalog/catalog_page.dart';

class Routes {
  static const home = '/';
  static const catalog = '/catalog';
  static const map = '/map';
  static const favorites = '/favorites';
  static const chats = '/chats';
  static const profile = '/profile';
  static const search = '/search';

  static const estates = '/estates';
  static const estateDetail = '/estates/:id';
  static const addListing = '/estates/new';
  static const newbuilds = '/newbuilds';
  static const roomDetail = '/newbuilds/:id';
  static const masters = '/masters';
  static const masterDetail = '/masters/:id';
  static const jobs = '/jobs';
  static const jobDetail = '/jobs/:id';
  static const companies = '/companies';
  static const companyDetail = '/companies/:id';
  static const news = '/news';
  static const newsDetail = '/news/:id';
  static const notifications = '/notifications';
  static const editProfile = '/profile/edit';

  static const login = '/login';
  static const otp = '/login/otp';
  static const register = '/login/register';
  /// Yangi, 4 bosqichli (telefon → kod → ma'lumot → xavfsizlik) ro'yxatdan
  /// o'tish sahifasi — [RegisterFlowPage].
  static const registerFlow = '/register';
  static const becomeMaster = '/become-master';

  static String estate(int id) => '/estates/$id';
  static String room(int id) => '/newbuilds/$id';
  static String master(int id) => '/masters/$id';
  static String job(int id) => '/jobs/$id';
  static String company(int id) => '/companies/$id';
  static String newsItem(int id) => '/news/$id';
  static String chat(int id) => '/chats/$id';
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (c, s) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: Routes.catalog,
            pageBuilder: (c, s) => const NoTransitionPage(child: CatalogPage()),
          ),
          GoRoute(
            path: Routes.map,
            pageBuilder: (c, s) => const NoTransitionPage(child: MapPage()),
          ),
          GoRoute(
            path: Routes.favorites,
            pageBuilder: (c, s) => const NoTransitionPage(child: FavoritesPage()),
          ),
          GoRoute(
            path: Routes.chats,
            pageBuilder: (c, s) => const NoTransitionPage(child: ChatsPage()),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (c, s) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),

      // Full-screen (shell tashqarisidagi) sahifalar
      GoRoute(
        path: Routes.search,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => SearchPage(initialQuery: s.uri.queryParameters['q']),
      ),
      GoRoute(
        path: Routes.estates,
        parentNavigatorKey: _rootKey,
        builder: (c, s) {
          final extra = s.extra;
          return RealEstateListPage(
            initialSearch: s.uri.queryParameters['q'],
            initialPropertyType: s.uri.queryParameters['propertyType'],
            initialDealType: s.uri.queryParameters['dealType'],
            initialFilter: extra is RealEstateFilter ? extra : null,
            openFilterOnStart: s.uri.queryParameters['openFilter'] == '1',
            onlyMine: s.uri.queryParameters['mine'] == '1',
          );
        },
      ),
      GoRoute(
        path: Routes.addListing,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const AddListingPage(),
      ),
      GoRoute(
        path: Routes.estateDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            RealEstateDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      // Veb-saytdagi (prohome.uz) yo'l bilan mos — ulashilgan havola orqali
      // (App Links) ilova ochilganda ham ishlashi uchun.
      GoRoute(
        path: '/real-estates/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            RealEstateDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: Routes.newbuilds,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const NewBuildsPage(),
      ),
      GoRoute(
        path: Routes.roomDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            RoomDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: Routes.masters,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const MastersPage(),
      ),
      GoRoute(
        path: Routes.masterDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            MasterDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: Routes.jobs,
        parentNavigatorKey: _rootKey,
        builder: (c, s) {
          final extra = s.extra;
          return JobsPage(initialBbox: extra is GeoBounds ? extra : null);
        },
      ),
      GoRoute(
        path: Routes.jobDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            JobDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: Routes.companies,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CompaniesPage(),
      ),
      GoRoute(
        path: Routes.companyDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            CompanyDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: Routes.news,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const NewsPage(),
      ),
      GoRoute(
        path: Routes.newsDetail,
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            NewsDetailPage(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/map/:slug',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => RegionDetailPage(slug: s.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: Routes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const NotificationsPage(),
      ),
      GoRoute(
        path: Routes.editProfile,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/chats/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => ChatThreadPage(
          chatId: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
          title: s.uri.queryParameters['title'],
        ),
      ),

      // Auth
      GoRoute(
        path: Routes.login,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.otp,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => OtpPage(
          phone: s.uri.queryParameters['phone'] ?? '',
          mode: s.uri.queryParameters['mode'] ?? 'login',
        ),
      ),
      GoRoute(
        path: Routes.register,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => RegisterPage(
          phone: s.uri.queryParameters['phone'] ?? '',
          otp: s.uri.queryParameters['otp'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.registerFlow,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const RegisterFlowPage(),
      ),
      GoRoute(
        path: Routes.becomeMaster,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const BecomeMasterPage(),
      ),
    ],
  );
});

/// Login talab qilinadigan amallarda chaqiriladi.
Future<bool> ensureAuth(BuildContext context, WidgetRef ref) async {
  if (ref.read(isAuthenticatedProvider)) return true;
  final ok = await context.push<bool>(Routes.login);
  return ok == true && ref.read(isAuthenticatedProvider);
}
