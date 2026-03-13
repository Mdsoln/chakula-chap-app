
import 'package:chakula_chap/features/order_tracking/data/datasources/mock_order_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock datasources
import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/menu/data/datasources/menu_mock_datasource.dart';
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/order_tracking/data/datasources/order_remote_datasource.dart';
import '../../features/order_tracking/data/datasources/order_tracking_datasource.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// ── THE ONE SWITCH ────────────────────────────────────────────────────────────
const bool kUseMock = true;
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
