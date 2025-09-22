import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import '../../domain/entities/catalog_request.dart';
import '../bloc/catalog_requests_bloc.dart';
import 'catalog_request_view_page.dart';

class CatalogRequestsPage extends StatefulWidget {
  const CatalogRequestsPage({super.key});
  @override
  State<CatalogRequestsPage> createState() => _CatalogRequestsPageState();
}

class _CatalogRequestsPageState extends State<CatalogRequestsPage> {
  late final CatalogRequestsBloc bloc;
  String? _next;

  @override
  void initState() {
    super.initState();
    bloc = getIt<CatalogRequestsBloc>();
    bloc.add(LoadCatalogRequests());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Catalog Requests')),
        body: BlocConsumer<CatalogRequestsBloc, CatalogRequestsState>(
          listener: (context, state) {
            if (state is CatalogRequestsLoaded) _next = state.next;
          },
          builder: (context, state) {
            if (state is CatalogRequestsLoading ||
                state is CatalogRequestsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CatalogRequestsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is CatalogRequestsLoaded) {
              final items = state.items;
              if (items.isEmpty)
                return const Center(child: Text('No catalog requests'));
              return RefreshIndicator(
                onRefresh: () async => bloc.add(RefreshCatalogRequests()),
                child: ListView.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      if (_next != null) {
                        return TextButton(
                          onPressed: () =>
                              bloc.add(LoadCatalogRequests(next: _next)),
                          child: const Text('Load more'),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    final r = items[index];
                    return _tile(r);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _tile(CatalogRequest r) {
    final subtitle = [r.clientName ?? '', r.clientPhone ?? '']
        .where((e) => e.isNotEmpty)
        .join(' • ');
    return ListTile(
      title: Text(r.title),
      subtitle: Text(subtitle),
      trailing: Text(r.status ?? ''),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CatalogRequestViewPage(requestId: r.id))),
    );
  }
}
