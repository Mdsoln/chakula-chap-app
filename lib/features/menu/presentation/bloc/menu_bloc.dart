import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/menu_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String? categoryId;
  const LoadMenuEvent({this.categoryId});
  @override
  List<Object?> get props => [categoryId];
}

class LoadMoreMenuItemsEvent extends MenuEvent {
  final String? categoryId;
  const LoadMoreMenuItemsEvent({this.categoryId});
}

class SearchMenuEvent extends MenuEvent {
  final String query;
  const SearchMenuEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

class SelectCategoryEvent extends MenuEvent {
  final String? categoryId; // null = "All"
  const SelectCategoryEvent({this.categoryId});
  @override
  List<Object?> get props => [categoryId];
}

class ClearSearchEvent extends MenuEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class MenuState extends Equatable {
  const MenuState();
  @override
  List<Object?> get props => [];
}

class MenuInitialState extends MenuState {}
class MenuLoadingState extends MenuState {}

class MenuLoadedState extends MenuState {
  final List<CategoryEntity> categories;
  final List<MenuItemEntity> items;
  final List<MenuItemEntity> featuredItems;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;

  const MenuLoadedState({
    required this.categories,
    required this.items,
    required this.featuredItems,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  MenuLoadedState copyWith({
    List<CategoryEntity>? categories,
    List<MenuItemEntity>? items,
    List<MenuItemEntity>? featuredItems,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
  }) =>
      MenuLoadedState(
        categories: categories ?? this.categories,
        items: items ?? this.items,
        featuredItems: featuredItems ?? this.featuredItems,
        selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
        searchQuery: searchQuery ?? this.searchQuery,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        currentPage: currentPage ?? this.currentPage,
      );

  @override
  List<Object?> get props => [
    categories,
    items,
    featuredItems,
    selectedCategoryId,
    searchQuery,
    isLoadingMore,
    hasReachedMax,
    currentPage,
  ];
}

class MenuErrorState extends MenuState {
  final String message;
  const MenuErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetCategoriesUseCase _getCategories;
  final GetMenuItemsUseCase _getMenuItems;
  final GetFeaturedItemsUseCase _getFeatured;

  MenuBloc(this._getCategories, this._getMenuItems, this._getFeatured)
      : super(MenuInitialState()) {
    on<LoadMenuEvent>(_onLoad);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SearchMenuEvent>(_onSearch);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadMoreMenuItemsEvent>(_onLoadMore);
  }

  Future<void> _onLoad(LoadMenuEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoadingState());

    // Load categories, items, and featured in parallel
    final results = await Future.wait([
      _getCategories(),
      _getMenuItems(GetMenuItemsParams(categoryId: event.categoryId)),
      _getFeatured(),
    ] as Iterable<Future<dynamic>>);

    final categoriesResult = results[0];
    final itemsResult = results[1];
    final featuredResult = results[2];

    // If items fail, show error; categories failure is non-fatal
    if (itemsResult.isLeft()) {
      emit(MenuErrorState(
        message: itemsResult.fold((f) => f.message, (_) => ''),
      ));
      return;
    }

    emit(MenuLoadedState(
      categories: categoriesResult.fold((_) => [], (c) => c as List<CategoryEntity>),
      items: itemsResult.fold((_) => [], (i) => i as List<MenuItemEntity>),
      featuredItems: featuredResult.fold((_) => [], (f) => f as List<MenuItemEntity>),
      selectedCategoryId: event.categoryId,
    ));
  }

  Future<void> _onSelectCategory(
      SelectCategoryEvent event,
      Emitter<MenuState> emit,
      ) async {
    if (state is! MenuLoadedState) return;
    final current = state as MenuLoadedState;

    emit(current.copyWith(
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
      isLoadingMore: false,
      currentPage: 1,
    ));

    final result = await _getMenuItems(
      GetMenuItemsParams(categoryId: event.categoryId),
    );

    result.fold(
          (f) => emit(MenuErrorState(message: f.message)),
          (items) => emit(current.copyWith(
        items: items,
        selectedCategoryId: event.categoryId,
        clearCategory: event.categoryId == null,
        currentPage: 1,
        hasReachedMax: false,
      )),
    );
  }

  Future<void> _onSearch(SearchMenuEvent event, Emitter<MenuState> emit) async {
    if (state is! MenuLoadedState) return;
    final current = state as MenuLoadedState;

    if (event.query.isEmpty) {
      add(ClearSearchEvent());
      return;
    }

    emit(current.copyWith(searchQuery: event.query));

    final result = await _getMenuItems(
      GetMenuItemsParams(search: event.query),
    );

    result.fold(
          (f) => emit(MenuErrorState(message: f.message)),
          (items) => emit(current.copyWith(items: items, searchQuery: event.query)),
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<MenuState> emit) {
    if (state is MenuLoadedState) {
      add(const LoadMenuEvent());
    }
  }

  Future<void> _onLoadMore(
      LoadMoreMenuItemsEvent event,
      Emitter<MenuState> emit,
      ) async {
    if (state is! MenuLoadedState) return;
    final current = state as MenuLoadedState;
    if (current.isLoadingMore || current.hasReachedMax) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _getMenuItems(
      GetMenuItemsParams(categoryId: event.categoryId, page: nextPage),
    );

    result.fold(
          (f) => emit(current.copyWith(isLoadingMore: false)),
          (newItems) => emit(current.copyWith(
        items: [...current.items, ...newItems],
        isLoadingMore: false,
        hasReachedMax: newItems.isEmpty,
        currentPage: nextPage,
      )),
    );
  }
}