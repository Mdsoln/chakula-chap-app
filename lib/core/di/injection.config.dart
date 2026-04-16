// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// dart format off

import 'package:chakula_chap/features/menu/domain/repositories/menu_repository.dart';
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
import '../../features/auth/domain/usecases/complete_profile_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/block/auth_bloc.dart';
import '../../features/auth/presentation/block/registration_bloc.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/favourites/data/datasources/favourite_remote_datasource.dart';
import '../../features/favourites/data/repositories/favourite_repository_impl.dart';
import '../../features/favourites/domain/repositories/favourite_repository.dart';
import '../../features/favourites/domain/usecases/get_favourites_usecase.dart';
import '../../features/favourites/domain/usecases/toggle_favourite_usecase.dart';
import '../../features/favourites/presentation/bloc/favourite_bloc.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location_usecase.dart';
import '../../features/menu/data/datasources/menu_local_datasource.dart';
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/usecases/menu_usecases.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/order_tracking/data/datasources/order_remote_datasource.dart';
import '../../features/order_tracking/data/datasources/order_tracking_datasource.dart';
import '../../features/order_tracking/data/repositories/order_repository_impl.dart';
import '../../features/order_tracking/domain/repositories/order_repository.dart';
import '../../features/order_tracking/domain/usecases/order_usecases.dart';
import '../../features/order_tracking/presentation/bloc/order_history_bloc.dart';
import '../../features/order_tracking/presentation/bloc/order_tracking_bloc.dart';
import '../network/auth_interceptor.dart';
import '../network/connectivity_checker.dart';
import '../network/network_client.dart';
import '../router/app_router.dart';
import 'injection.dart';

extension GetItInjectableX on _i174.GetIt {
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalModule = ExternalModule();

    // ── External ──────────────────────────────────────────────────────────────
    gh.singleton<FlutterSecureStorage>(() => externalModule.secureStorage);
    await gh.singletonAsync<SharedPreferences>(
          () => externalModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<Connectivity>(() => externalModule.connectivity);
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

    // ── Core / Network ────────────────────────────────────────────────────────
    gh.singleton<ConnectivityChecker>(
          () => ConnectivityChecker(gh<Connectivity>()),
    );
    gh.factory<AuthInterceptor>(
          () => AuthInterceptor(gh<FlutterSecureStorage>()),
    );
    gh.singleton<NetworkClient>(
          () => NetworkClient(gh<AuthInterceptor>(), gh<ConnectivityChecker>()),
    );

    // ── Location ──────────────────────────────────────────────────────────────
    gh.factory<LocationRepository>(
          () => LocationRepositoryImpl(),
    );
    gh.factory<GetCurrentLocationUseCase>(
          () => GetCurrentLocationUseCase(gh<LocationRepository>()),
    );

    // ── Auth ──────────────────────────────────────────────────────────────────
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
    gh.factory<SendOtpUseCase>(() => SendOtpUseCase(gh<AuthRepository>()));
    gh.factory<VerifyOtpUseCase>(() => VerifyOtpUseCase(gh<AuthRepository>()));
    gh.factory<LogoutUseCase>(() => LogoutUseCase(gh<AuthRepository>()));
    gh.factory<CompleteProfileUseCase>(
          () => CompleteProfileUseCase(gh<AuthRepository>()),
    );
    gh.factory<AuthBloc>(
          () => AuthBloc(
        gh<SendOtpUseCase>(),
        gh<VerifyOtpUseCase>(),
        gh<LogoutUseCase>(),
      ),
    );
    gh.factory<RegistrationBloc>(
          () => RegistrationBloc(
        gh<CompleteProfileUseCase>(),
        gh<GetCurrentLocationUseCase>(),
      ),
    );
    gh.singleton<AppRouter>(
          () => AppRouter(
        gh<FlutterSecureStorage>(),
        gh<AuthRepository>(),
      ),
    );

    // ── Menu ──────────────────────────────────────────────────────────────────
    gh.factory<MenuRemoteDataSource>(
          () => MenuRemoteDataSourceImpl(gh<NetworkClient>()),
    );
    gh.factory<MenuLocalDataSource>(
          () => MenuLocalDataSourceImpl(
        gh<Box<dynamic>>(instanceName: 'menuCacheBox'),
      ),
    );
    gh.factory<MenuRepository>(
          () => MenuRepositoryImpl(
        gh<MenuRemoteDataSource>(),
        gh<MenuLocalDataSource>(),
      ),
    );
    gh.factory<GetCategoriesUseCase>(
          () => GetCategoriesUseCase(gh<MenuRepository>()),
    );
    gh.factory<GetMenuItemsUseCase>(
          () => GetMenuItemsUseCase(gh<MenuRepository>()),
    );
    gh.factory<GetMenuItemByIdUseCase>(
          () => GetMenuItemByIdUseCase(gh<MenuRepository>()),
    );
    gh.factory<GetFeaturedItemsUseCase>(
          () => GetFeaturedItemsUseCase(gh<MenuRepository>()),
    );
    gh.factory<MenuBloc>(
          () => MenuBloc(
        gh<GetCategoriesUseCase>(),
        gh<GetMenuItemsUseCase>(),
        gh<GetFeaturedItemsUseCase>(),
      ),
    );

    // ── Favourites ────────────────────────────────────────────────────────────────
    gh.factory<FavouriteRemoteDataSource>(
          () => FavouriteRemoteDataSourceImpl(gh<NetworkClient>()),
    );
    gh.factory<FavouriteRepository>(
          () => FavouriteRepositoryImpl(gh<FavouriteRemoteDataSource>()),
    );
    gh.factory<ToggleFavouriteUseCase>(
          () => ToggleFavouriteUseCase(gh<FavouriteRepository>()),
    );
    gh.factory<GetFavouritesUseCase>(
          () => GetFavouritesUseCase(gh<FavouriteRepository>()),
    );
    gh.factory<FavouriteBloc>(
          () => FavouriteBloc(
        gh<ToggleFavouriteUseCase>(),
        gh<GetFavouritesUseCase>(),
      ),
    );

    // ── Cart ──────────────────────────────────────────────────────────────────
    gh.factory<CartLocalDataSource>(
          () => CartLocalDataSourceImpl(
        gh<Box<dynamic>>(instanceName: 'cartBox'),
      ),
    );
    gh.factory<CartRepository>(
          () => CartRepositoryImpl(gh<CartLocalDataSource>()),
    );
    gh.factory<GetCartUseCase>(() => GetCartUseCase(gh<CartRepository>()));
    gh.factory<AddToCartUseCase>(() => AddToCartUseCase(gh<CartRepository>()));
    gh.factory<RemoveFromCartUseCase>(
          () => RemoveFromCartUseCase(gh<CartRepository>()),
    );
    gh.factory<UpdateCartItemQuantityUseCase>(
          () => UpdateCartItemQuantityUseCase(gh<CartRepository>()),
    );
    gh.factory<ClearCartUseCase>(
          () => ClearCartUseCase(gh<CartRepository>()),
    );
    gh.factory<CartBloc>(
          () => CartBloc(
        gh<GetCartUseCase>(),
        gh<AddToCartUseCase>(),
        gh<RemoveFromCartUseCase>(),
        gh<UpdateCartItemQuantityUseCase>(),
        gh<ClearCartUseCase>(),
      ),
    );

    // ── Order Tracking ────────────────────────────────────────────────────────
    gh.factory<OrderTrackingDataSource>(
          () => OrderTrackingDataSourceImpl(),
    );
    gh.factory<OrderRemoteDataSource>(
          () => OrderRemoteDataSourceImpl(gh<NetworkClient>()),
    );
    gh.factory<OrderRepository>(
          () => OrderRepositoryImpl(gh<OrderRemoteDataSource>()),
    );
    gh.factory<OrderTrackingRepository>(
          () => OrderTrackingRepositoryImpl(
        gh<OrderTrackingDataSource>(),
        gh<OrderRemoteDataSource>(),
      ),
    );
    gh.factory<PlaceOrderUseCase>(
          () => PlaceOrderUseCase(gh<OrderRepository>()),
    );
    gh.factory<GetOrderByIdUseCase>(
          () => GetOrderByIdUseCase(gh<OrderRepository>()),
    );
    gh.factory<GetMyOrdersUseCase>(
          () => GetMyOrdersUseCase(gh<OrderRepository>()),
    );
    gh.factory<WatchOrderTrackingUseCase>(
          () => WatchOrderTrackingUseCase(gh<OrderTrackingRepository>()),
    );
    gh.factory<CheckoutBloc>(
          () => CheckoutBloc(gh<PlaceOrderUseCase>()),
    );
    gh.factory<OrderTrackingBloc>(
          () => OrderTrackingBloc(
        gh<WatchOrderTrackingUseCase>(),
        gh<GetOrderByIdUseCase>(),
      ),
    );
    gh.factory<OrderHistoryBloc>(
          () => OrderHistoryBloc(gh<GetMyOrdersUseCase>()),
    );

    return this;
  }
}