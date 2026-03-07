// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// dart format off

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/pages/auth_bloc.dart';
import '../network/auth_interceptor.dart';
import '../network/connectivity_checker.dart';
import '../network/network_client.dart';
import '../router/app_router.dart';
import 'injection.dart';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);

    final externalModule = ExternalModule();

    // ── External / Platform ──────────────────────────────────────────────────

    gh.singleton<FlutterSecureStorage>(
          () => externalModule.secureStorage,
    );

    await gh.singletonAsync<SharedPreferences>(
          () => externalModule.sharedPreferences,
      preResolve: true,
    );

    gh.singleton<Connectivity>(
          () => externalModule.connectivity,
    );

    await gh.singletonAsync<Box<dynamic>>(
          () => externalModule.cartBox,
      preResolve: true,
      instanceName: 'cartBox',
    );

    await gh.singletonAsync<Box<dynamic>>(
          () => externalModule.menuCacheBox,
      preResolve: true,
      instanceName: 'menuCacheBox',
    );

    // ── Network ───────────────────────────────────────────────────────────────

    gh.singleton<ConnectivityChecker>(
          () => ConnectivityChecker(gh<Connectivity>()),
    );

    gh.factory<AuthInterceptor>(
          () => AuthInterceptor(gh<FlutterSecureStorage>()),
    );

    gh.singleton<NetworkClient>(
          () => NetworkClient(
        gh<AuthInterceptor>(),
        gh<ConnectivityChecker>(),
      ),
    );

    // ── Router ────────────────────────────────────────────────────────────────

    gh.singleton<AppRouter>(
          () => AppRouter(gh<FlutterSecureStorage>()),
    );

    // ── Auth Feature ──────────────────────────────────────────────────────────

    gh.factory<AuthLocalDataSource>(
          () => AuthLocalDataSourceImpl(
        gh<FlutterSecureStorage>(),
        gh<SharedPreferences>(),
      ),
    );

    gh.factory<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(gh<NetworkClient>()),
    );

    gh.factory<AuthRepository>(
          () => AuthRepositoryImpl(
        gh<AuthRemoteDataSource>(),
        gh<AuthLocalDataSource>(),
      ),
    );

    gh.factory<SendOtpUseCase>(
          () => SendOtpUseCase(gh<AuthRepository>()),
    );

    gh.factory<VerifyOtpUseCase>(
          () => VerifyOtpUseCase(gh<AuthRepository>()),
    );

    gh.factory<LogoutUseCase>(
          () => LogoutUseCase(gh<AuthRepository>()),
    );

    gh.factory<AuthBloc>(
          () => AuthBloc(
        gh<SendOtpUseCase>(),
        gh<VerifyOtpUseCase>(),
        gh<LogoutUseCase>(),
      ),
    );

    return this;
  }
}