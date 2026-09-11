import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/settings_controller.dart';
import '../../app/theme.dart';
import '../../core/network/api_exception.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
}

class EmptyView extends ConsumerWidget {
  const EmptyView({super.key, this.icon = Icons.inbox_outlined, this.message, this.action});
  final IconData icon;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.muted),
            const SizedBox(height: 14),
            Text(
              message ?? s('common.empty'),
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(color: context.muted),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends ConsumerWidget {
  const ErrorView({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final msg = error is ApiException
        ? (error as ApiException).message
        : s('common.error');
    final isNet = error is ApiException && (error as ApiException).isNetwork;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isNet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 56, color: context.muted),
            const SizedBox(height: 14),
            Text(msg,
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium?.copyWith(color: context.muted)),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(s('common.retry')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 20)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton karta ro'yxati (grid yoki list).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.height = 108});
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF232A3A)
        : const Color(0xFFEDEFF3);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: base.withValues(alpha: 0.45),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
        ),
      ),
    );
  }
}
