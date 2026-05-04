import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/quran/presentation/screens/quran_list_screen.dart';
import '../../features/quran/presentation/screens/surah_reading_screen.dart';
import '../../features/prayer/presentation/screens/prayer_times_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/tasbih/presentation/screens/tasbih_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/habit/presentation/screens/habit_screen.dart';
import '../../features/ramadan/presentation/screens/ramadan_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/main_shell.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/quran',
            builder: (context, state) => const QuranListScreen(),
            routes: [
              GoRoute(
                path: ':surahNumber',
                builder: (context, state) {
                  final surahNumber =
                      int.parse(state.pathParameters['surahNumber']!);
                  final surahName =
                      state.uri.queryParameters['name'] ?? '';
                  return SurahReadingScreen(
                    surahNumber: surahNumber,
                    surahName: surahName,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/prayer',
            builder: (context, state) => const PrayerTimesScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/tasbih',
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/habits',
        builder: (context, state) => const HabitScreen(),
      ),
      GoRoute(
        path: '/ramadan',
        builder: (context, state) => const RamadanScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
  );
});
