import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import 'providers/auth_providers.dart';

/// Landing screen with email login
class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> handleLogin() async {
      final email = emailController.text.trim();

      // Basic validation
      if (email.isEmpty) {
        errorMessage.value = 'Please enter your email';
        return;
      }

      if (!RegExp(r'^[\w\.\-\+]+@[\w\.\-]+\.\w+$').hasMatch(email)) {
        errorMessage.value = 'Please enter a valid email';
        return;
      }

      errorMessage.value = null;
      isLoading.value = true;

      final success = await ref.read(authProvider.notifier).login(email);

      // Check if widget is still mounted before updating state
      if (!context.mounted) return;

      if (success) {
        // Navigate away - don't update state as widget will be disposed
        context.go('/');
      } else {
        isLoading.value = false;
        errorMessage.value = ref.read(authProvider).error ?? 'Login failed';
      }
    }

    return FScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo/Brand
            const Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.accentBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Heft',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your workouts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),

            // Email field
            FTextField.email(
              controller: emailController,
              hint: 'you@example.com',
              label: const Text('Email'),
              description: errorMessage.value != null
                  ? null
                  : const Text(
                      'No password needed - just enter your email to get started'),
              error: errorMessage.value != null
                  ? Text(errorMessage.value!)
                  : null,
              onSubmit: (_) => handleLogin(),
            ),

            const SizedBox(height: 24),

            // Login button
            FButton(
              onPress: isLoading.value ? null : handleLogin,
              child: isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: FProgress(),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
