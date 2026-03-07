import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();
  @override
  List<Object?> get props => [];
}

class StartTrackingEvent extends TrackingEvent {
  final String orderId;
  const StartTrackingEvent({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class StopTrackingEvent extends TrackingEvent {}

class _TrackingUpdateReceived extends TrackingEvent {
  final OrderTrackingUpdate update;
  const _TrackingUpdateReceived(this.update);
  @override
  List<Object?> get props => [update];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class TrackingState extends Equatable {
  const TrackingState();
  @override
  List<Object?> get props => [];
}

class TrackingInitialState extends TrackingState {}
class TrackingLoadingState extends TrackingState {}

class TrackingActiveState extends TrackingState {
  final OrderEntity order;
  final List<OrderTrackingUpdate> history;
  final OrderTrackingUpdate? latestUpdate;
  final int etaMinutes;

  const TrackingActiveState({
    required this.order,
    this.history = const [],
    this.latestUpdate,
    this.etaMinutes = 30,
  });

  OrderStatus get currentStatus =>
      latestUpdate?.status ?? order.status;

  TrackingActiveState copyWith({
    OrderEntity? order,
    List<OrderTrackingUpdate>? history,
    OrderTrackingUpdate? latestUpdate,
    int? etaMinutes,
  }) =>
      TrackingActiveState(
        order: order ?? this.order,
        history: history ?? this.history,
        latestUpdate: latestUpdate ?? this.latestUpdate,
        etaMinutes: etaMinutes ?? this.etaMinutes,
      );

  @override
  List<Object?> get props => [order, history, latestUpdate, etaMinutes];
}

class TrackingErrorState extends TrackingState {
  final String message;
  const TrackingErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class OrderTrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final WatchOrderTrackingUseCase _watchTracking;
  final GetOrderByIdUseCase _getOrder;

  StreamSubscription? _trackingSubscription;

  OrderTrackingBloc(this._watchTracking, this._getOrder)
      : super(TrackingInitialState()) {
    on<StartTrackingEvent>(_onStart);
    on<StopTrackingEvent>(_onStop);
    on<_TrackingUpdateReceived>(_onUpdateReceived);
  }

  Future<void> _onStart(
      StartTrackingEvent event,
      Emitter<TrackingState> emit,
      ) async {
    emit(TrackingLoadingState());

    // 1. Load current order state
    final orderResult = await _getOrder(event.orderId);
    if (orderResult.isLeft()) {
      emit(TrackingErrorState(
        message: orderResult.fold((f) => f.message, (_) => ''),
      ));
      return;
    }
    final order = orderResult.getOrElse(() => throw Exception());

    emit(TrackingActiveState(order: order));

    // 2. Subscribe to live WebSocket updates
    await _trackingSubscription?.cancel();
    _trackingSubscription = _watchTracking(event.orderId).listen(
          (result) => result.fold(
            (f) => add(StopTrackingEvent()),
            (update) => add(_TrackingUpdateReceived(update)),
      ),
    );
  }

  void _onStop(StopTrackingEvent event, Emitter<TrackingState> emit) {
    _trackingSubscription?.cancel();
  }

  void _onUpdateReceived(
      _TrackingUpdateReceived event,
      Emitter<TrackingState> emit,
      ) {
    if (state is! TrackingActiveState) return;
    final current = state as TrackingActiveState;

    final updatedHistory = [...current.history, event.update];

    // Rough ETA estimation based on status
    final etaMinutes = switch (event.update.status) {
      OrderStatus.confirmed => 30,
      OrderStatus.preparing => 20,
      OrderStatus.ready => 10,
      OrderStatus.pickedUp => 8,
      OrderStatus.delivered => 0,
      _ => current.etaMinutes,
    };

    emit(current.copyWith(
      history: updatedHistory,
      latestUpdate: event.update,
      etaMinutes: etaMinutes,
    ));
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}