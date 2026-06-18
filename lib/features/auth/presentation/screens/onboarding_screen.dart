import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Screen 3 Logic State
  String _selectedLocation = 'New York, USA';
  String _selectedMadhab = 'Select Madhab';
  bool _notificationsEnabled = true;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    await prefs.setString(AppConstants.locationKey, _selectedLocation);
    
    if (!mounted) return;
    context.go('/login');
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['New York, USA', 'London, UK', 'Dubai, UAE', 'Dhaka, BD', 'Madinah, KSA'].map((city) => 
              ListTile(
                title: Text(city),
                onTap: () {
                  setState(() => _selectedLocation = city);
                  Navigator.pop(ctx);
                },
                trailing: _selectedLocation == city ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              )
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMadhabPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Madhab', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['Hanafi', 'Shafi', 'Maliki', 'Hanbali'].map((madhab) => 
              ListTile(
                title: Text(madhab),
                onTap: () {
                  setState(() => _selectedMadhab = madhab);
                  Navigator.pop(ctx);
                },
                trailing: _selectedMadhab == madhab ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              )
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildSimpleImagePage(1),
              _buildSimpleImagePage(2),
              _buildPersonalizePage(),
            ],
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: TextButton(
              onPressed: _finish,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const WormEffect(
                    dotColor: Color(0xFFE0E0E0),
                    activeDotColor: AppColors.primary,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006D44),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == 2 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleImagePage(int index) {
    // PageView children should NOT be Positioned widgets.
    return Image.asset(
      'assets/images/onboarding$index.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Text('Image assets/images/onboarding$index.png not found'));
      },
    );
  }

  Widget _buildPersonalizePage() {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/onboarding3.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.white);
            },
          ),
        ),
        
        // Interactive Form Overlay
        Positioned(
          top: MediaQuery.of(context).size.height * 0.32,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), 
                _buildInteractiveInput(
                  'Location',
                  _selectedLocation,
                  Icons.location_on_rounded,
                  onTap: _showLocationPicker,
                ),
                const SizedBox(height: 20),
                _buildInteractiveInput(
                  'Madhab (Optional)',
                  _selectedMadhab,
                  Icons.account_balance_rounded,
                  isDropdown: true,
                  onTap: _showMadhabPicker,
                ),
                const SizedBox(height: 20),
                _buildInteractiveSwitch(
                  'Notifications',
                  'Enable Notifications',
                  Icons.notifications_rounded,
                  _notificationsEnabled,
                  (v) => setState(() => _notificationsEnabled = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveInput(String label, String value, IconData icon, {bool isDropdown = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF006D44)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1B1B1B)))),
                Icon(
                  isDropdown ? Icons.keyboard_arrow_down_rounded : Icons.my_location_rounded,
                  color: const Color(0xFFAAAAAA),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSwitch(String label, String value, IconData icon, bool enabled, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF006D44)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1B1B1B)))),
              Switch.adaptive(
                value: enabled,
                onChanged: onChanged,
                activeTrackColor: const Color(0xFF006D44),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
