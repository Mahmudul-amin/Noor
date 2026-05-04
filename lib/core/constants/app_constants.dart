class AppConstants {
  AppConstants._();

  // Layout
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  static const double cardElevation = 0.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // API
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String quranApiBaseUrl = 'https://api.alquran.cloud/v1';
  static const String quranAudioBaseUrl =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy';

  // Hive boxes
  static const String settingsBox = 'settings_box';
  static const String tasbihBox = 'tasbih_box';
  static const String habitsBox = 'habits_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String quranProgressBox = 'quran_progress_box';
  static const String chatHistoryBox = 'chat_history_box';

  // Hive keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';
  static const String locationKey = 'location';
  static const String notifEnabledKey = 'notifications_enabled';
  static const String calculationMethodKey = 'calc_method';

  // Prayer calculation methods
  static const Map<String, int> calculationMethods = {
    'Muslim World League': 3,
    'Islamic Society of North America': 2,
    'Egyptian General Authority': 5,
    'Umm Al-Qura University': 4,
    'University of Islamic Sciences, Karachi': 1,
  };

  // Default values
  static const int defaultTasbihGoal = 33;
  static const int totalSurahs = 114;

  // Google Maps API (replace with your key)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Kaaba coordinates
  static const double kaabaLat = 21.3891;
  static const double kaabaLng = 39.8579;
}
