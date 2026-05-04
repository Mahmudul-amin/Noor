import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signUp(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    if (ref.read(authProvider).isAuthenticated) context.go('/home');
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
              Container(
                height: size.height * 0.30,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Create Account',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Join the NOOR community',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.22,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.signup, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: AppStrings.fullName, prefixIcon: Icon(Icons.person_outline)),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: AppStrings.email, prefixIcon: Icon(Icons.email_outlined)),
                          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                        ),
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(auth.error!, style: const TextStyle(color: AppColors.error)),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: auth.isLoading ? null : _signUp,
                          child: auth.isLoading
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text(AppStrings.signup),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(AppStrings.alreadyHaveAccount, style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(AppStrings.login, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                            ),
                          ],
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
