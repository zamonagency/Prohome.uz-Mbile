import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/money_text.dart';
import '../../../core/utils/formatters.dart';
import '../newbuild_model.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room});
  final B2CRoom room;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.room(room.id)),
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
            Stack(
              children: [
                AspectRatio(
                    aspectRatio: 16 / 10,
                    child: AppNetworkImage(raw: room.cover)),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Pill(
                    label: room.isAvailable ? 'Sotuvda' : 'Band',
                    filled: true,
                    color: room.isAvailable
                        ? AppColors.primary
                        : context.muted,
                    dense: true,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(room.price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(room.projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '${formatArea(room.size)} · ${room.floorNumber}-qavat${room.block != null ? ' · ${room.block}' : ''}',
                    style: TextStyle(fontSize: 12, color: context.muted),
                  ),
                  if (room.projectAddress.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 13, color: context.muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(room.projectAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11.5, color: context.muted)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
