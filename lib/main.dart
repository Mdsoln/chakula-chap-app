import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/observer/app_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureSystemUI();

  await Hive.initFlutter();

  await _initFirebase();

  await configureDependencies();

  Bloc.observer = AppBlocObserver();

  runApp(const ChakulaChapApp());
}

// ── UI chrome ─────────────────────────────────────────────────────────────────

Future<void> _configureSystemUI() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,      // white icons on dark bg
      systemNavigationBarColor: Color(0xFF0A1628),    // navyDeep
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

// ── Firebase ──────────────────────────────────────────────────────────────────

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // firebase_options.dart has not been generated yet (run: flutterfire configure)
    // App continues without Firebase — push notifications won't work until configured
    debugPrint('[ChakulaChap] Firebase init skipped: $e');
  }
}

// ── Root widget ───────────────────────────────────────────────────────────────

class ChakulaChapApp extends StatelessWidget {
  const ChakulaChapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChakulaChap',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,       // ChakulaChap uses dark theme exclusively

      // Navigation — GoRouter handles deep links, auth guard, transitions
      routerConfig: getIt<AppRouter>().router,

      // Accessibility
      builder: (context, child) {
        return MediaQuery(
          // Prevent system font-scaling from breaking layouts
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}