abstract class AppConstants {
  // ── App Info ──────────────────────────────────────────────
  static const String appName        = 'ChakulaChap';
  static const String appTagline     = 'Your community, your food.';
  static const String appVersion     = '1.0.0';

  // ── API ───────────────────────────────────────────────────
  static const String baseUrl        = 'https://localhost:90100/api/v1';
  static const String wsBaseUrl      = 'wss://api.zetu.co.tz/ws';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Storage Keys ──────────────────────────────────────────
  static const String kAccessToken   = 'access_token';
  static const String kRefreshToken  = 'refresh_token';
  static const String kUserId        = 'user_id';
  static const String kUserPhone     = 'user_phone';
  static const String kOnboardingDone = 'onboarding_done';
  static const String kCachedUser     = 'cached_user';
  static const String kCartBox       = 'cart_box';
  static const String kMenuCacheBox  = 'menu_cache_box';

  // ── Payment ───────────────────────────────────────────────
  static const String countryCode    = '+255';
  static const String currency       = 'Tsh';
  static const int    deliveryFee    = 3000;
  static const int    freeDeliveryThreshold = 20000;
  static const int    otpLength      = 6;
  static const Duration otpExpiry    = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 60);

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize   = 20;
  static const int firstPage         = 1;

  // ── Cache ─────────────────────────────────────────────────
  static const Duration menuCacheDuration = Duration(minutes: 30);

  // ── Animation durations ───────────────────────────────────
  static const Duration animFast     = Duration(milliseconds: 200);
  static const Duration animMedium   = Duration(milliseconds: 350);
  static const Duration animSlow     = Duration(milliseconds: 600);

  // ── Lottie animation paths ────────────────────────────────
  static const String lottieSuccess        = 'assets/animations/success.json';
  static const String lottieLoading        = 'assets/animations/loading.json';
  static const String lottieEmptyCart      = 'assets/animations/empty_list.json';
  static const String lottieOrderTracking  = 'assets/animations/order_tracking.json';
  static const String lottieDelivery       = 'assets/animations/delivery.json';
  static const String lottieNoInternet     = 'assets/animations/no_internet.json';
  static const String lottieError          = 'assets/animations/error.json';
  static const String lottieSplash         = 'assets/animations/splash.json';
  static const String splashIcon           = 'assets/icons/splashIcon.png';
  static const String lottiePayment        = 'assets/animations/payment.json';
}

/// Route path constants — single source of truth for navigation
abstract class AppRoutes {
  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String otp            = '/otp';
  static const String registration = '/registration';
  static const String home           = '/home';
  static const String menuItemDetail = '/menu/item/:id';
  static const String cart           = '/cart';
  static const String checkout       = '/checkout';
  static const String orderConfirm   = '/order/confirm';
  static const String orderTracking  = '/order/tracking/:orderId';
  static const String orderHistory   = '/orders';
  static const String profile        = '/profile';
  static const String notifications  = '/notifications';
}

/// API endpoint constants
abstract class ApiEndpoints {
  // Auth
  static const String sendOtp     = '/auth/otp/send';
  static const String verifyOtp   = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String logout      = '/auth/logout';
  static const String profile = '/auth/profile';

  // Menu
  static const String categories  = '/menu/categories';
  static const String menuItems   = '/menu/items';
  static String menuItemById(String id) => '/menu/items/$id';

  // Orders
  static const String placeOrder  = '/orders';
  static const String myOrders    = '/orders/me';
  static String orderById(String id) => '/orders/$id';
  static String orderTracking(String id) => '/orders/$id/tracking';

  // Payment
  static const String initPayment    = '/payments/init';
  static const String paymentStatus  = '/payments/status';
  static const String controlNumber  = '/payments/selcom/control-number';
}