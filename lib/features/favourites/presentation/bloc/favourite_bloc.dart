// ── Events ────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_favourites_usecase.dart';
import '../../domain/usecases/toggle_favourite_usecase.dart';

abstract class FavouriteEvent extends Equatable {
  const FavouriteEvent();
}

class LoadFavouritesEvent extends FavouriteEvent {
  @override List<Object?> get props => [];
}

class ToggleFavouriteEvent extends FavouriteEvent {
  final String menuItemId;
  const ToggleFavouriteEvent(this.menuItemId);
  @override List<Object?> get props => [menuItemId];
}

// ── State ─────────────────────────────────
class FavouriteState extends Equatable {
  final Set<String> favouriteIds;  // set of menu item IDs
  final bool isLoading;
  final String? toggledItemId;     // for optimistic UI

  const FavouriteState({
    this.favouriteIds = const {},
    this.isLoading = false,
    this.toggledItemId,
  });

  bool isFavourited(String menuItemId) => favouriteIds.contains(menuItemId);

  FavouriteState copyWith({
    Set<String>? favouriteIds,
    bool? isLoading,
    String? toggledItemId,
  }) => FavouriteState(
    favouriteIds: favouriteIds ?? this.favouriteIds,
    isLoading: isLoading ?? this.isLoading,
    toggledItemId: toggledItemId,
  );

  @override
  List<Object?> get props => [favouriteIds, isLoading, toggledItemId];
}

// ── BLoC ──────────────────────────────────
@injectable
class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final ToggleFavouriteUseCase _toggle;
  final GetFavouritesUseCase _getFavourites;

  FavouriteBloc(this._toggle, this._getFavourites)
      : super(const FavouriteState()) {
    on<LoadFavouritesEvent>(_onLoad);
    on<ToggleFavouriteEvent>(_onToggle);
  }

  Future<void> _onLoad(
      LoadFavouritesEvent event,
      Emitter<FavouriteState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _getFavourites();
    result.fold(
          (_) => emit(state.copyWith(isLoading: false)),
          (ids) => emit(state.copyWith(favouriteIds: ids, isLoading: false)),
    );
  }

  Future<void> _onToggle(
      ToggleFavouriteEvent event,
      Emitter<FavouriteState> emit,
      ) async {
    // ── Optimistic update ─────────────────
    final current = Set<String>.from(state.favouriteIds);
    final isCurrentlyFav = current.contains(event.menuItemId);

    if (isCurrentlyFav) {
      current.remove(event.menuItemId);
    } else {
      current.add(event.menuItemId);
    }

    emit(state.copyWith(
      favouriteIds: current,
      toggledItemId: event.menuItemId,
    ));

    // ── Sync with backend ─────────────────────────────────
    final result = await _toggle(event.menuItemId);

    result.fold(
          (_) {
        // Rollback on failure
        final rollback = Set<String>.from(state.favouriteIds);
        if (isCurrentlyFav) {
          rollback.add(event.menuItemId);
        } else {
          rollback.remove(event.menuItemId);
        }
        emit(state.copyWith(favouriteIds: rollback, toggledItemId: null));
      },
          (_) => emit(state.copyWith(toggledItemId: null)),
    );
  }
}