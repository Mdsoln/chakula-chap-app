import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();

/// External (third-party) dependencies registered manually
@module
abstract class ExternalModule {
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