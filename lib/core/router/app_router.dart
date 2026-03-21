import 'dart:convert';

import 'package:chakula_chap/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/menu/domain/entities/menu_item_entity.dart';
import '../../features/menu/presentation/pages/menu_item_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/order_tracking/presentation/pages/order_confirm_page.dart';
import '../../features/order_tracking/presentation/pages/order_history_page.dart';
import '../../features/order_tracking/presentation/pages/order_tracking_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';

class _AppExtraCodec extends Codec<Object?, Object?> {
  const _AppExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();
}

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    // ── UserEntity ────────────────────────────────────────────────────────
    if (input is UserEntity) {
      return <String, Object?>{
        '__type': 'UserEntity',
        'id': input.id,
        'phone': input.phone,
        'name': input.name,
        'email': input.email,
        'avatarUrl': input.avatarUrl,
        'verified': input.verified,
        'isProfileComplete': input.isProfileComplete,
        'createdAt': input.createdAt.toIso8601String(),
      };
    }

    // ── MenuItemEntity ────────────────────────────────────────────────────────
    if (input is MenuItemEntity) {
      return <String, Object?>{
        '__type': 'MenuItemEntity',
        'id': input.id,
        'name': input.name,
        'description': input.description,
        'price': input.price,
        'categoryId': input.categoryId,
        'emoji': input.emoji,
        'imageUrl': input.imageUrl,
        'rating': input.rating,
        'reviewCount': input.reviewCount,
        'prepTimeMinutes': input.prepTimeMinutes,
        'calories': input.calories,
        'isAvailable': input.isAvailable,
        'isFeatured': input.isFeatured,
        'tag': input.tag,
        'variants': input.variants
            .map((v) => {
          'id': v.id,
          'label': v.label,
          'priceModifier': v.priceModifier,
        })
            .toList(),
        'extras': input.extras
            .map((e) => {
          'id': e.id,
          'name': e.name,
          'price': e.price,
        })
            .toList(),
      };
    }

    // ── String (used by OtpPage phone, OrderConfirmPage orderId) ─────────────
    if (input is String) {
      return <String, Object?>{'__type': 'String', 'value': input};
    }

    throw ArgumentError(
      '[AppRouter] Unsupported extra type: ${input.runtimeType}. '
          'Add a branch in _AppExtraEncoder and _AppExtraDecoder.',
    );
  }
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is! Map<String, Object?>) return input;

    final type = input['__type'] as String?;

    switch (type) {

    // ── UserEntity ────────────────────────────────────────────────────────
      case 'UserEntity':
        return UserEntity(
          id: input['id'] as String,
          phone: input['phone'] as String,
          name: input['name'] as String?,
          email: input['email'] as String?,
          avatarUrl: input['avatarUrl'] as String?,
          verified: input['verified'] as bool,
          isProfileComplete: input['isProfileComplete'] as bool,
          createdAt: DateTime.parse(input['createdAt'] as String),
        );

    // ── MenuItemEntity ────────────────────────────────────────────────────
      case 'MenuItemEntity':
        final variantsList = (input['variants'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map((v) => MenuItemVariantEntity(
          id: v['id'] as String,
          label: v['label'] as String,
          priceModifier: (v['priceModifier'] as num).toDouble(),
        ))
            .toList();

        final extrasList = (input['extras'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map((e) => MenuItemExtraEntity(
          id: e['id'] as String,
          name: e['name'] as String,
          price: (e['price'] as num).toDouble(),
        ))
            .toList();

        return MenuItemEntity(
          id: input['id'] as String,
          name: input['name'] as String,
          description: input['description'] as String,
          price: (input['price'] as num).toDouble(),
          categoryId: input['categoryId'] as String,
          emoji: input['emoji'] as String,
          imageUrl: input['imageUrl'] as String?,
          rating: (input['rating'] as num).toDouble(),
          reviewCount: input['reviewCount'] as int,
          prepTimeMinutes: input['prepTimeMinutes'] as int,
          calories: input['calories'] as int,
          isAvailable: input['isAvailable'] as bool,
          isFeatured: input['isFeatured'] as bool,
          tag: input['tag'] as String?,
          variants: variantsList,
          extras: extrasList,
        );

    // ── String ─────────────────────────────────────────────────────────────
      case 'String':
        return input['value'] as String;

      default:
        return input;
    }
  }
}

// ── Router ────────────────────────────────────────────────────────────────────

@singleton
class AppRouter {
  final FlutterSecureStorage _storage;
  final AuthRepository _authRepo;

  AppRouter(this._storage, this._authRepo);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _authGuard,
    extraCodec: const _AppExtraCodec(),
    routes: [
      // ── Auth Flow ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (ctx, state) =>
            _buildFadeTransition(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        pageBuilder: (ctx, state) {
          final extra = state.extra as Map<String, String>;
          return _buildSlideTransition(
            state,
            OtpPage(
              phone: extra['phone']!,
              maskedPhone: extra['maskedPhone']!,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registration,
        name: 'registration',
        pageBuilder: (ctx, state) {
          String phone = '';
          if (state.extra is UserEntity) {
            phone = (state.extra as UserEntity).phone;
          } else {
            phone = Uri.decodeComponent(
              state.uri.queryParameters['phone'] ?? '',
            );
          }

          return _buildSlideTransition(
            state,
            RegistrationPage(phone: phone),
          );
        },
      ),

      // ── Main App (Protected) ─────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (ctx, state) {
          final user = state.extra is UserEntity ? state.extra as UserEntity : null;
          return _buildFadeTransition(state, HomePage(user: user));
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (ctx, state) {
          final user = state.extra is UserEntity
              ? state.extra as UserEntity
              : null;
          return _buildSlideTransition(
            state,
            ProfilePage(user: user),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.menuItemDetail,
        name: 'menu-item-detail',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          MenuItemDetailPage(itemId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const CartPage()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const CheckoutPage()),
      ),
      GoRoute(
        path: AppRoutes.orderConfirm,
        name: 'order-confirm',
        pageBuilder: (ctx, state) => _buildFadeTransition(
          state,
          OrderConfirmPage(orderId: state.extra as String),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'order-tracking',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          OrderTrackingPage(
              orderId: state.pathParameters['orderId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'order-history',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const OrderHistoryPage()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (ctx, state) =>
            _buildSlideTransition(state, const NotificationsPage()),
      ),
    ],
    errorBuilder: (ctx, state) => _ErrorPage(error: state.error),
  );

  // ── Auth Guard ────────────────────────────────────────────
  Future<String?> _authGuard(
      BuildContext context, GoRouterState state) async {
    final token =
    await _storage.read(key: AppConstants.kAccessToken);
    final isAuthenticated = token != null;

    const publicRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.otp,
    };

    final isPublicRoute =
    publicRoutes.contains(state.matchedLocation);

    if (!isAuthenticated && !isPublicRoute) return AppRoutes.login;
    if (isAuthenticated &&
        state.matchedLocation == AppRoutes.login) {
      return AppRoutes.home;
    }

    if (isAuthenticated && state.matchedLocation != AppRoutes.registration) {
      final userResult = await _authRepo.getCurrentUser();
      final user = userResult.fold((_) => null, (u) => u);
      if (user != null && !user.isProfileComplete) {
        return '${AppRoutes.registration}?phone=${Uri.encodeComponent(user.phone)}';
      }
    }
    return null;
  }

  // ── Page transitions ──────────────────────────────────────
  static CustomTransitionPage<void> _buildFadeTransition(
      GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animMedium,
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage<void> _buildSlideTransition(
      GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animMedium,
      transitionsBuilder: (context, animation, secondary, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
            position: animation.drive(tween), child: child);
      },
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('404 - Page not found',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}