import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/menu/presentation/pages/menu_item_detail_page.dart';
import '../../features/order_tracking/presentation/pages/order_confirm_page.dart';
import '../../features/order_tracking/presentation/pages/order_tracking_page.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';

@singleton
class AppRouter {
  final FlutterSecureStorage _storage;

  AppRouter(this._storage);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _authGuard,
    routes: [
      // ── Auth Flow ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (ctx, state) => _buildFadeTransition(
          state,
          const SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          OtpPage(phone: state.extra as String),
        ),
      ),

      // ── Main App (Protected) ─────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (ctx, state) => _buildFadeTransition(
          state,
          const HomePage(),
        ),
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
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          const CartPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (ctx, state) => _buildSlideTransition(
          state,
          const CheckoutPage(),
        ),
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
          OrderTrackingPage(orderId: state.pathParameters['orderId']!),
        ),
      ),
    ],
    errorBuilder: (ctx, state) => _ErrorPage(error: state.error),
  );

  // ── Auth Guard ────────────────────────────────────────────
  Future<String?> _authGuard(BuildContext context, GoRouterState state) async {
    final token = await _storage.read(key: AppConstants.kAccessToken);
    final isAuthenticated = token != null;

    final publicRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.otp,
    };

    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    if (!isAuthenticated && !isPublicRoute) return AppRoutes.login;
    if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
      return AppRoutes.home;
    }
    return null; // No redirect
  }

  // ── Page transitions ──────────────────────────────────────
  static CustomTransitionPage<void> _buildFadeTransition(
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage<void> _buildSlideTransition(
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.animMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// Fallback error page for unmatched routes
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
            const Text('404 - Page not found', style: TextStyle(fontSize: 18)),
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