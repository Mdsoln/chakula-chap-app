import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  const SendOtpEvent({required this.phone});
  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent({required this.phone, required this.otp});
  @override
  List<Object?> get props => [phone, otp];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class OtpTimerTickEvent extends AuthEvent {
  final int secondsRemaining;
  const OtpTimerTickEvent(this.secondsRemaining);
  @override
  List<Object?> get props => [secondsRemaining];
}

class ResendOtpEvent extends AuthEvent {
  final String phone;
  const ResendOtpEvent({required this.phone});
  @override
  List<Object?> get props => [phone];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}
class AuthLoadingState extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final String maskedPhone;
  final int otpTimerSeconds;

  const OtpSentState({
    required this.phone,
    required this.maskedPhone,
    required this.otpTimerSeconds,
  });

  OtpSentState copyWith({int? otpTimerSeconds}) => OtpSentState(
    phone: phone,
    maskedPhone: maskedPhone,
    otpTimerSeconds: otpTimerSeconds ?? this.otpTimerSeconds,
  );

  @override
  List<Object?> get props => [phone, maskedPhone, otpTimerSeconds];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthenticatedState({required this.user});
  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase _sendOtp;
  final VerifyOtpUseCase _verifyOtp;
  final LogoutUseCase _logout;

  AuthBloc(this._sendOtp, this._verifyOtp, this._logout)
      : super(AuthInitialState()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<OtpTimerTickEvent>(_onTimerTick);
    on<ResendOtpEvent>(_onResendOtp);
  }

  Future<void> _onSendOtp(
      SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await _sendOtp(SendOtpParams(phone: event.phone));
    result.fold(
          (failure) => emit(AuthErrorState(message: failure.message)),
          (otpSent) => emit(OtpSentState(
        phone: otpSent.phone,
        maskedPhone: otpSent.maskedPhone,
        otpTimerSeconds: otpSent.expiresInSeconds.clamp(0, 600),
      )),
    );
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await _verifyOtp(
      VerifyOtpParams(phone: event.phone, otp: event.otp),
    );
    result.fold(
          (failure) => emit(AuthErrorState(message: failure.message)),
          (session) => emit(AuthenticatedState(user: session.user)),
    );
  }

  Future<void> _onLogout(
      LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await _logout();
    emit(UnauthenticatedState());
  }

  void _onTimerTick(OtpTimerTickEvent event, Emitter<AuthState> emit) {
    if (state is OtpSentState) {
      emit((state as OtpSentState)
          .copyWith(otpTimerSeconds: event.secondsRemaining));
    }
  }

  Future<void> _onResendOtp(
      ResendOtpEvent event, Emitter<AuthState> emit) async {
    final result = await _sendOtp(SendOtpParams(phone: event.phone));
    result.fold(
          (failure) => emit(AuthErrorState(message: failure.message)),
          (otpSent) => emit(OtpSentState(
        phone: otpSent.phone,
        maskedPhone: otpSent.maskedPhone,
        otpTimerSeconds: otpSent.expiresInSeconds.clamp(0, 600),
      )),
    );
  }
}