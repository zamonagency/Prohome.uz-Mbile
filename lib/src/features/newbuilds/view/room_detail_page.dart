import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/image_gallery.dart';
import '../../../common/widgets/money_text.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../newbuild_repository.dart';

class RoomDetailPage extends ConsumerWidget {
  const RoomDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(b2cRoomDetailProvider(id));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('cat.newbuilds'))),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(b2cRoomDetailProvider(id))),
        data: (room) => ListView(
          padding: EdgeInsets.zero,
          children: [
            ImageGallery(
              images: room.gallery.isEmpty ? [room.cover] : room.gallery,
              aspectRatio: 4 / 3,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(
                    label: room.isAvailable ? 'Sotuvda' : 'Band',
                    filled: true,
                    color:
                        room.isAvailable ? AppColors.primary : context.muted,
                  ),
                  const SizedBox(height: 12),
                  MoneyText(room.price,
                      style: context.texts.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(room.projectName, style: context.texts.titleMedium),
                  if (room.projectAddress.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 16, color: context.muted),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(room.projectAddress,
                                style: TextStyle(color: context.muted))),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _spec(context, Icons.straighten_rounded,
                          formatArea(room.size), s('estate.area')),
                      _spec(context, Icons.stairs_outlined,
                          '${room.floorNumber}', s('estate.floor')),
                      if (room.block != null)
                        _spec(context, Icons.domain_rounded, room.block!, 'Blok'),
                      _spec(context, Icons.tag_rounded, '${room.roomNumber}',
                          'Xonadon'),
                    ],
                  ),
                  if ((room.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(s('estate.description'),
                        style: context.texts.titleMedium),
                    const SizedBox(height: 6),
                    Text(room.description!.trim(),
                        style: context.texts.bodyMedium?.copyWith(
                            height: 1.5, color: context.muted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (room) => (room.phoneNumber ?? '').isEmpty
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () => dialPhone(context, room.phoneNumber!),
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: Text('${s('common.call')} · ${room.phoneNumber}'),
                ),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _spec(
          BuildContext context, IconData icon, String value, String label) =>
      Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(fontSize: 11, color: context.muted)),
          ],
        ),
      );
}
