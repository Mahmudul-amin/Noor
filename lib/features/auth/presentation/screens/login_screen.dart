import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Header gradient
              Container(
                height: size.height * 0.38,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('☪', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'NOOR',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form card
              Positioned(
                top: size.height * 0.30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.login,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: AppStrings.email,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) =>
                              v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.length < 6 ? 'Min 6 characters' : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(AppStrings.forgotPassword,
                                style: TextStyle(color: AppColors.primary)),
                          ),
                        ),
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(auth.error!,
                                style: const TextStyle(color: AppColors.error)),
                          ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(AppStrings.login),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(authProvider.notifier)
                                      .signInWithGoogle();
                                  if (!context.mounted) return;
                                  if (ref.read(authProvider).isAuthenticated) {
                                    context.go('/home');
                                  }
                                },
                          icon: const Text('G',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 17)),
                          label: const Text(AppStrings.continueWithGoogle),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(AppStrings.dontHaveAccount,
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: const Text(
                                AppStrings.signup,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    await ref
                                        .read(authProvider.notifier)
                                        .loginAsGuest();
                                    if (!context.mounted) return;
                                    context.go('/home');
                                  },
                            child: const Text(
                              AppStrings.continueAsGuest,
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
