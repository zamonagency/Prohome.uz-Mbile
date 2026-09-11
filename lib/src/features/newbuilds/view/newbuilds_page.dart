import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/paged_list.dart';
import '../newbuild_repository.dart';
import '../widgets/room_card.dart';

class NewBuildsPage extends ConsumerStatefulWidget {
  const NewBuildsPage({super.key});

  @override
  ConsumerState<NewBuildsPage> createState() => _NewBuildsPageState();
}

class _NewBuildsPageState extends ConsumerState<NewBuildsPage> {
  int? _projectId;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final projects = ref.watch(b2cProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('cat.newbuilds'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: s('common.search'),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          projects.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(s('common.all')),
                            selected: _projectId == null,
                            onSelected: (_) =>
                                setState(() => _projectId = null),
                            selectedColor: AppColors.primary,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                                color:
                                    _projectId == null ? Colors.white : null,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5),
                          ),
                        ),
                        ...list.map((p) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(p.name),
                                selected: _projectId == p.id,
                                onSelected: (_) => setState(() =>
                                    _projectId =
                                        _projectId == p.id ? null : p.id),
                                selectedColor: AppColors.primary,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                    color: _projectId == p.id
                                        ? Colors.white
                                        : null,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5),
                              ),
                            )),
                      ],
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AppPagedList(
              key: ValueKey('$_projectId$_query'),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.66,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              fetch: (page) => ref.read(newBuildRepositoryProvider).rooms(
                    page: page,
                    projectId: _projectId,
                    search: _query.isEmpty ? null : _query,
                  ),
              itemBuilder: (_, room, __) => RoomCard(room: room),
              emptyIcon: Icons.location_city_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ProjectHeaderImage extends StatelessWidget {
  const _ProjectHeaderImage({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) =>
      AppNetworkImage(raw: url, height: 120, radius: AppTheme.radius);
}
