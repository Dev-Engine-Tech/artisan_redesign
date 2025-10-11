import 'package:bloc/bloc.dart';
import 'package:artisans_circle/core/bloc/cached_bloc_mixin.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/usecases/get_my_catalog_items.dart';
import '../../domain/usecases/get_catalog_by_user.dart';
import '../../data/models/catalog_item_model.dart' show CatalogItemModel;

abstract class CatalogEvent {}

class LoadMyCatalog extends CatalogEvent {
  final int page;
  LoadMyCatalog({this.page = 1});
}

class LoadUserCatalog extends CatalogEvent {
  final String userId;
  final int page;
  LoadUserCatalog({required this.userId, this.page = 1});
}

class RefreshMyCatalog extends CatalogEvent {}

abstract class CatalogState {
  const CatalogState();
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  final List<CatalogItem> items;
  const CatalogLoaded(this.items);
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);
}

// ✅ WEEK 4: Added CachedBlocMixin for automatic caching
class CatalogBloc extends Bloc<CatalogEvent, CatalogState>
    with CachedBlocMixin {
  final GetMyCatalogItems getMyCatalogItems;
  final GetCatalogByUser getCatalogByUser;
  CatalogBloc({required this.getMyCatalogItems, required this.getCatalogByUser})
      : super(const CatalogInitial()) {
    on<LoadMyCatalog>((event, emit) async {
      emit(const CatalogLoading());
      try {
        final items = await getMyCatalogItems(page: event.page);
        emit(CatalogLoaded(items));
      } catch (e) {
        emit(CatalogError(e.toString()));
      }
    });
    on<LoadUserCatalog>((event, emit) async {
      emit(const CatalogLoading());
      try {
        final items = await getCatalogByUser(event.userId, page: event.page);
        emit(CatalogLoaded(items));
      } catch (e) {
        emit(CatalogError(e.toString()));
      }
    });
    on<RefreshMyCatalog>((event, emit) async {
      try {
        final items = await getMyCatalogItems(page: 1);
        emit(CatalogLoaded(items));
      } catch (e) {
        emit(CatalogError(e.toString()));
      }
    });
  }
}
