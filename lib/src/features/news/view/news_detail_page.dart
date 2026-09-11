import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/image_gallery.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../news_repository.dart';

class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(newsDetailProvider(id));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('cat.news')),
        actions: [
          IconButton(
            onPressed: () => async.whenData(
                (p) => shareText(p.title)),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(newsDetailProvider(id))),
        data: (post) => ListView(
          padding: EdgeInsets.zero,
          children: [
            if (post.cover.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ImageGallery(images: [post.cover], aspectRatio: 16 / 9),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.category != null)
                    Text(post.category!.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(post.title,
                      style: context.texts.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(formatDate(post.publishedAt),
                      style: TextStyle(color: context.muted, fontSize: 12)),
                  const SizedBox(height: 16),
                  Text(
                    (post.content?.trim().isNotEmpty ?? false)
                        ? post.content!.trim()
                        : (post.excerpt ?? ''),
                    style: context.texts.bodyLarge?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
