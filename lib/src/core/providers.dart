import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    tokens: ref.watch(tokenStorageProvider),
    onSessionExpired: () async {
      // Sessiya tugadi — foydalanuvchini chiqaramiz (loop bo'lmasligi uchun silent).
      await ref.read(authControllerProvider.notifier).handleSessionExpired();
    },
  );
  ref.onDispose(() {});
  return client;
});
