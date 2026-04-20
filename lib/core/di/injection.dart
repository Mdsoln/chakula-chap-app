
import 'package:chakula_chap/features/order_tracking/data/datasources/mock_order_datasource.dart';
import 'package:chakula_chap/features/order_tracking/presentation/bloc/order_history_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock datasources
import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/complete_profile_usecase.dart';
import '../../features/auth/presentation/block/registration_bloc.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location_usecase.dart';
import '../../features/menu/data/datasources/menu_mock_datasource.dart';
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/order_tracking/data/datasources/order_remote_datasource.dart';
import '../../features/order_tracking/data/datasources/order_tracking_datasource.dart';

import '../../features/order_tracking/domain/repositories/order_repository.dart';
import '../../features/order_tracking/domain/usecases/order_usecases.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

/// ── THE ONE SWITCH ────────────────────────────────────────────────────────────
const bool kUseMock = false;
/// ─────────────────────────────────────────────────────────────────────────────

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  if (kUseMock) {
    _registerMocks();
  }
}

/// Replaces real datasources with mock singletons.
/// The repository and BLoC layers are untouched — they receive the same
/// abstract interface, so they don't know or care it's a mock.
void _registerMocks() {
  // ── Auth ────────────────────────────────────────────────────────────────────
  getIt.unregister<AuthRemoteDataSource>();
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => MockAuthRemoteDataSource.instance,
  );

  getIt.registerFactory<RegistrationBloc>(
        () => RegistrationBloc(
          getIt<CompleteProfileUseCase>(),
          getIt<GetCurrentLocationUseCase>(),
        ),
  );

  getIt.registerFactory<CompleteProfileUseCase>(
        () => CompleteProfileUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<GetCurrentLocationUseCase>(
        () => GetCurrentLocationUseCase(getIt<LocationRepository>()),
  );

  getIt.unregister<LocationRepository>();
  getIt.registerLazySingleton<LocationRepository>(
        () => LocationRepositoryImpl(),
  );

  // ── Menu ────────────────────────────────────────────────────────────────────
  getIt.unregister<MenuRemoteDataSource>();
  getIt.registerLazySingleton<MenuRemoteDataSource>(
        () => MockMenuRemoteDataSource.instance,
  );

  // ── Orders (remote) ─────────────────────────────────────────────────────────
  getIt.unregister<OrderRemoteDataSource>();
  getIt.registerLazySingleton<OrderRemoteDataSource>(
        () => MockOrderRemoteDataSource.instance,
  );

  // ── Order Tracking (WebSocket → timer-based stream) ─────────────────────────
  getIt.unregister<OrderTrackingDataSource>();
  getIt.registerLazySingleton<OrderTrackingDataSource>(
        () => MockOrderTrackingDataSource.instance,
  );

  getIt.registerFactory<OrderHistoryBloc>(
        () => OrderHistoryBloc(getIt<GetMyOrdersUseCase>()),
  );

  getIt.unregister<GetMyOrdersUseCase>();
  getIt.registerFactory<GetMyOrdersUseCase>(
        () => GetMyOrdersUseCase(getIt<OrderRepository>()),
  );

}

/// External (third-party) dependencies registered manually.
@module
class ExternalModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  Connectivity get connectivity => Connectivity();

  @preResolve
  @singleton
  Future<Box<dynamic>> get cartBox => Hive.openBox('cart_box');

  @preResolve
  @singleton
  Future<Box<dynamic>> get menuCacheBox => Hive.openBox('menu_cache_box');
}
