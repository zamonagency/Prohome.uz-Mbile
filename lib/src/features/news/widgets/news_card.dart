import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../core/utils/formatters.dart';
import '../news_model.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.post});
  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.newsItem(post.id)),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
                aspectRatio: 16 / 9, child: AppNetworkImage(raw: post.cover)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.category != null)
                    Text(post.category!.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  if ((post.excerpt ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(post.excerpt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: context.muted)),
                  ],
                  const SizedBox(height: 8),
                  Text(formatDate(post.publishedAt),
                      style: TextStyle(fontSize: 11, color: context.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
