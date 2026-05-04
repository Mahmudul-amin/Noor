import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/noor_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../habit/providers/habit_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final habit = ref.watch(habitProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final achievements = [
      {
        'icon': '🔥',
        'title': 'First Streak',
        'desc': '3 days in a row',
        'unlocked': habit.streak >= 3
      },
      {
        'icon': '📖',
        'title': 'Quran Reader',
        'desc': 'Read 10 Surahs',
        'unlocked': false
      },
      {
        'icon': '🕌',
        'title': 'Perfect Salah',
        'desc': 'All 5 prayers for 7 days',
        'unlocked': false
      },
      {
        'icon': '🌙',
        'title': 'Night Worshipper',
        'desc': 'Tahajjud for 5 days',
        'unlocked': false
      },
      {
        'icon': '💎',
        'title': 'Month Champion',
        'desc': '30 day streak',
        'unlocked': habit.streak >= 30
      },
    ];

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Header
        SliverToBoxAdapter(
            child: Container(
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
          child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(children: [
                  // Avatar
                  Stack(children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        (auth.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                              color: AppColors.gold, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded,
                              size: 14, color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(auth.displayName ?? 'Believer',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text(auth.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(children: [
                    _StatChip(
                        label: 'Streak',
                        value: '${habit.streak}d',
                        emoji: '🔥'),
                    const SizedBox(width: 12),
                    _StatChip(
                        label: 'Today',
                        value: '${habit.todayPercent.toStringAsFixed(0)}%',
                        emoji: '📊'),
                    const SizedBox(width: 12),
                    _StatChip(
                        label: 'Salahs',
                        value: '${habit.salahCount}/5',
                        emoji: '🕌'),
                  ]),
                ]),
              )),
        )),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            // Quick links
            const SectionHeader(title: 'Quick Access'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _QuickLink(
                      icon: Icons.brightness_5_rounded,
                      label: 'Tasbih',
                      color: AppColors.primary,
                      onTap: () => context.push('/tasbih'))),
              const SizedBox(width: 12),
              Expanded(
                  child: _QuickLink(
                      icon: Icons.explore_rounded,
                      label: 'Qibla',
                      color: AppColors.gold,
                      onTap: () => context.push('/qibla'))),
              const SizedBox(width: 12),
              Expanded(
                  child: _QuickLink(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'AI Chat',
                      color: AppColors.fajr,
                      onTap: () => context.push('/ai-chat'))),
              const SizedBox(width: 12),
              Expanded(
                  child: _QuickLink(
                      icon: Icons.track_changes_rounded,
                      label: 'Habits',
                      color: AppColors.warning,
                      onTap: () => context.push('/habits'))),
            ]),
            const SizedBox(height: 28),

            // Achievements
            const SectionHeader(title: 'Achievements'),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final a = achievements[i];
                  final unlocked = a['unlocked'] as bool;
                  return Container(
                    width: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.1)
                          : (isDark
                              ? AppColors.cardDark
                              : const Color(0xFFF5F7F6)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: unlocked
                              ? AppColors.gold.withValues(alpha: 0.4)
                              : (isDark
                                  ? const Color(0xFF1E3045)
                                  : const Color(0xFFE8EFF0))),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(a['icon'] as String,
                              style: TextStyle(
                                      fontSize: 28,
                                      color: unlocked ? null : null)
                                  .merge(TextStyle(
                                      color: unlocked ? null : Colors.grey))),
                          const SizedBox(height: 6),
                          Text(a['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: unlocked
                                      ? (isDark
                                          ? Colors.white
                                          : AppColors.textDark)
                                      : AppColors.textLight)),
                        ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Settings
            const SectionHeader(title: 'Settings'),
            const SizedBox(height: 14),
            NoorCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _SettingRow(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark Mode',
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (v) => ref
                        .read(themeProvider.notifier)
                        .setTheme(v ? ThemeMode.dark : ThemeMode.light),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textLight)),
                const Divider(height: 1),
                _SettingRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('English',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textLight)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textLight),
                    ])),
                const Divider(height: 1),
                _SettingRow(
                    icon: Icons.info_outline_rounded,
                    label: 'About NOOR',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textLight)),
              ]),
            ),
            const SizedBox(height: 16),
            // Logout
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Logout',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
            ),
          ])),
        ),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value, emoji;
  const _StatChip(
      {required this.label, required this.value, required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label,
            style:
                TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
      ]),
    ));
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickLink(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingRow(
      {required this.icon, required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 15))),
        trailing,
      ]),
    );
  }
}
