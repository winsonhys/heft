import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../core/client.dart';
import '../features/auth/providers/auth_providers.dart';
import '../shared/theme/app_theme.dart';
import 'router.dart';

/// Main app widget
class HeftyChestApp extends ConsumerStatefulWidget {
  const HeftyChestApp({super.key});

  @override
  ConsumerState<HeftyChestApp> createState() => _HeftyChestAppState();
}

class _HeftyChestAppState extends ConsumerState<HeftyChestApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Set up token provider for API client
    setTokenProvider(() => ref.read(authProvider).token);

    // Create router with ref for auth checking
    _router = createAppRouter(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to trigger router refresh on auth changes
    final authState = ref.watch(authProvider);

    // Show loading screen while checking auth
    if (authState.isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0A0E1A),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4F5FFF),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    // Refresh router when auth state changes
    _router.refresh();

    return shadcn.ShadcnApp.router(
      title: 'Heft',
      theme: shadcn.ThemeData(
        colorScheme: buildShadcnColorScheme(),
        radius: 0.5,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
