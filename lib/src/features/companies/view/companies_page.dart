import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../common/widgets/paged_list.dart';
import '../company_repository.dart';
import '../widgets/company_card.dart';

class CompaniesPage extends ConsumerStatefulWidget {
  const CompaniesPage({super.key});

  @override
  ConsumerState<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends ConsumerState<CompaniesPage> {
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
    return Scaffold(
      appBar: AppBar(title: Text(s('cat.companies'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          Expanded(
            child: AppPagedList(
              key: ValueKey(_query),
              fetch: (page) => ref.read(companyRepositoryProvider).list(
                    page: page,
                    search: _query.isEmpty ? null : _query,
                  ),
              itemBuilder: (_, c, __) => CompanyCard(company: c),
              emptyIcon: Icons.business_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
