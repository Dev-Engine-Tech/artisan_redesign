import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import '../../domain/entities/catalog_item.dart';
import '../bloc/catalog_bloc.dart';
import 'catalog_item_details_page.dart';

class CatalogItemDetailsLoaderPage extends StatefulWidget {
  final String id;
  const CatalogItemDetailsLoaderPage({required this.id, super.key});

  @override
  State<CatalogItemDetailsLoaderPage> createState() =>
      _CatalogItemDetailsLoaderPageState();
}

class _CatalogItemDetailsLoaderPageState
    extends State<CatalogItemDetailsLoaderPage> {
  late final CatalogBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt<CatalogBloc>();
    // Kick off load
    bloc.add(LoadCatalogDetails(widget.id));
  }

  @override
  void dispose() {
    // CatalogBloc is provided from DI as factory; let Provider manage lifecycle if needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoading || state is CatalogInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is CatalogDetailsLoaded) {
            final CatalogItem item = state.item;
            return CatalogItemDetailsPage(item: item);
          }
          if (state is CatalogError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Catalogue')),
              body: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          // If a list was loaded instead of details, show generic page
          return const Scaffold(
            body: Center(child: Text('No details available')),
          );
        },
      ),
    );
  }
}
