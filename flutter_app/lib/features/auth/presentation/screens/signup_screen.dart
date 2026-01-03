import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _usernameError;
  String? _displayNameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _usernameError = null;
      _displayNameError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      // Email validation
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Email is required';
        isValid = false;
      } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(_emailController.text)) {
        _emailError = 'Email is invalid';
        isValid = false;
      }

      // Username validation
      if (_usernameController.text.trim().isEmpty) {
        _usernameError = 'Username is required';
        isValid = false;
      } else if (_usernameController.text.length < 3) {
        _usernameError = 'Username must be at least 3 characters';
        isValid = false;
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_usernameController.text)) {
        _usernameError = 'Username can only contain letters, numbers, and underscores';
        isValid = false;
      }

      // Display name validation
      if (_displayNameController.text.trim().isEmpty) {
        _displayNameError = 'Display name is required';
        isValid = false;
      }

      // Password validation
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
        isValid = false;
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }

      // Confirm password validation
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
        isValid = false;
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _handleSignup() async {
    if (!_validateForm()) return;

    final success = await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          displayName: _displayNameController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to see photos and videos from your friends',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Input
              CustomTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                prefixIcon: Icons.mail_outline,
                errorText: _emailError,
                onChanged: (_) => setState(() => _emailError = null),
              ),
              const SizedBox(height: 16),

              // Username Input
              CustomTextField(
                label: 'Username',
                hintText: 'Choose a username',
                controller: _usernameController,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                prefixIcon: Icons.alternate_email,
                errorText: _usernameError,
                onChanged: (_) => setState(() => _usernameError = null),
              ),
              const SizedBox(height: 16),

              // Display Name Input
              CustomTextField(
                label: 'Display Name',
                hintText: 'Enter your display name',
                controller: _displayNameController,
                prefixIcon: Icons.person_outline,
                errorText: _displayNameError,
                onChanged: (_) => setState(() => _displayNameError = null),
              ),
              const SizedBox(height: 16),

              // Password Input
              CustomTextField(
                label: 'Password',
                hintText: 'Create a password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                errorText: _passwordError,
                onChanged: (_) => setState(() => _passwordError = null),
              ),
              const SizedBox(height: 16),

              // Confirm Password Input
              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                errorText: _confirmPasswordError,
                onChanged: (_) => setState(() => _confirmPasswordError = null),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign Up Button
              CustomButton(
                text: 'Sign Up',
                onPressed: _handleSignup,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 16),

              // Terms
              Text(
                'By signing up, you agree to our Terms, Data Policy and Cookies Policy.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have an account? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
