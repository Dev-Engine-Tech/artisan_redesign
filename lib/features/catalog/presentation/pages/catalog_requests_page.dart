import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/catalog_request.dart';
import '../bloc/catalog_requests_bloc.dart';
import '../widgets/catalog_request_card.dart';

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
    // ✅ PERFORMANCE FIX: Check state before loading
    final currentState = bloc.state;
    if (currentState is! CatalogRequestsLoaded) {
      bloc.add(LoadCatalogRequests());
    }
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Catalog Requests'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
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
              if (items.isEmpty) {
                return const Center(child: Text('No catalog requests'));
              }
              return RefreshIndicator(
                // ✅ PERFORMANCE FIX: Force refresh on pull-to-refresh is intentional
                onRefresh: () async => bloc.add(RefreshCatalogRequests()),
                child: ListView.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      if (_next != null) {
                        return TextAppButton(
                          text: 'Load more',
                          // ✅ PERFORMANCE FIX: Load more for pagination is intentional
                          onPressed: () =>
                              bloc.add(LoadCatalogRequests(next: _next)),
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
    return CatalogRequestCard(request: r);
  }
}
