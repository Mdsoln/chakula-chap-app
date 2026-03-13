import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

const bool useMock = true;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  // ── Mock override ─────────────────────────────────────────────────────────
  // When [useMock] is true, replace the real AuthRemoteDataSource with the
  // mock. Everything above the data layer (repository, BLoC) is untouched.
  if (useMock) {
    getIt.unregister<AuthRemoteDataSource>();
    getIt.registerFactory<AuthRemoteDataSource>(
          () => MockAuthRemoteDataSource(),
    );
  }

}

/// External (third-party) dependencies registered manually
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

// NOTE: Run `dart run build_runner build --delete-conflicting-outputs`
// to generate injection.config.dart after adding @injectable/@singleton annotations