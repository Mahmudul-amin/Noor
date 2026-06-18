import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.tasbihBox);
  await Hive.openBox(AppConstants.habitsBox);
  await Hive.openBox(AppConstants.bookmarksBox);
  await Hive.openBox(AppConstants.quranProgressBox);
  await Hive.openBox(AppConstants.chatHistoryBox);

  // Init SharedPreferences
  await SharedPreferences.getInstance();

  runApp(const ProviderScope(child: NoorApp()));
}

class NoorApp extends ConsumerWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final isRamadan = ref.watch(isRamadanModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final resolvedTheme =
        resolveTheme(themeMode, platformBrightness, isRamadan);

    return MaterialApp.router(
      title: 'NOOR',
      debugShowCheckedModeBanner: false,
      theme: resolvedTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
