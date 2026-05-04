import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Progress animation (0 to 100 in 2.5 seconds)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigate();
        }
      });

    // Subtle glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _progressController.forward();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;
    
    if (!mounted) return;
    if (onboardingDone) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003D2B), // Fallback to deep green
      body: Stack(
        children: [
          // Background Image from User
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF004D36), Color(0xFF00291C)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.mosque, size: 80, color: Colors.white24),
                  ),
                );
              },
            ),
          ),
          
          // Animated Progress Bar at the bottom
          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Column(
              children: [
                _buildAnimatedProgressBar(),
                const SizedBox(height: 12),
                const Text(
                  'Loading your spiritual journey...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37), // Metallic Gold
                        Color(0xFFF9E272), // Bright Gold
                        Color(0xFFB8860B), // Dark Gold
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
