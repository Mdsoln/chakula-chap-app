
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../../location/domain/entities/user_location_entity.dart';
import '../../../location/domain/usecases/get_current_location_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
  @override
  List<Object?> get props => [];
}

class SubmitRegistrationEvent extends RegistrationEvent {
  final String fullName;
  final String? email;
  const SubmitRegistrationEvent({required this.fullName, this.email});
  @override
  List<Object?> get props => [fullName, email];
}

class FetchLocationEvent extends RegistrationEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class RegistrationState extends Equatable {
  const RegistrationState();
  @override
  List<Object?> get props => [];
}

class RegistrationInitialState extends RegistrationState {}
class RegistrationLoadingState extends RegistrationState {}
class LocationLoadingState extends RegistrationState {}

class RegistrationSuccessState extends RegistrationState {
  final UserEntity user;
  const RegistrationSuccessState({required this.user});
  @override
  List<Object?> get props => [user];
}

class LocationFetchedState extends RegistrationState {
  final UserLocationEntity location;
  const LocationFetchedState({required this.location});
  @override
  List<Object?> get props => [location];
}

class RegistrationErrorState extends RegistrationState {
  final String message;
  const RegistrationErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final CompleteProfileUseCase _completeProfile;
  final GetCurrentLocationUseCase _getLocation;

  RegistrationBloc(this._completeProfile, this._getLocation)
      : super(RegistrationInitialState()) {
    on<SubmitRegistrationEvent>(_onSubmit);
    on<FetchLocationEvent>(_onFetchLocation);
  }

  Future<void> _onSubmit(
      SubmitRegistrationEvent event,
      Emitter<RegistrationState> emit,
      ) async {
    emit(RegistrationLoadingState());
    final result = await _completeProfile(
      CompleteProfileParams(fullName: event.fullName, email: event.email),
    );
    result.fold(
          (failure) => emit(RegistrationErrorState(message: failure.message)),
          (user) => emit(RegistrationSuccessState(user: user)),
    );
  }

  Future<void> _onFetchLocation(
      FetchLocationEvent event,
      Emitter<RegistrationState> emit,
      ) async {
    emit(LocationLoadingState());
    final result = await _getLocation();
    result.fold(
          (failure) => emit(RegistrationErrorState(message: failure.message)),
          (location) => emit(LocationFetchedState(location: location)),
    );
  }
}