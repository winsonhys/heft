import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/client.dart';
import '../features/auth/providers/auth_providers.dart';
import '../shared/theme/heft_theme.dart';
import '../shared/widgets/floating_session_widget.dart';
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
    // Watch auth state to trigger rebuild on auth changes
    final authState = ref.watch(authProvider);

    // Listen to auth state changes to refresh router (only when actually changed)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        _router.refresh();
      }
    });

    // Show loading screen while checking auth
    if (authState.isLoading) {
      return MaterialApp(
        theme: heftDarkTheme.toApproximateMaterialTheme(),
        home: FTheme(
          data: heftDarkTheme,
          child: const FScaffold(
            child: Center(
              child: FProgress(),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp.router(
      title: 'Heft',
      theme: heftDarkTheme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(
        data: heftDarkTheme,
        child: _AppShell(router: _router, child: child!),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Shell widget that adds the floating session widget overlay
/// Listens to route changes to show/hide floating widget appropriately
class _AppShell extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;

  const _AppShell({required this.router, required this.child});

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRouteChange);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    // Schedule rebuild after route change completes
    // Using Future.microtask to defer setState after the current event loop
    if (mounted) {
      Future.microtask(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = widget.router.routerDelegate.currentConfiguration.uri.path;
    final isAuthScreen = currentPath.startsWith('/auth');

    return Stack(
      children: [
        widget.child,
        // Show floating session widget on all screens except auth
        // (FloatingSessionWidget handles hiding itself on tracker screen internally)
        if (!isAuthScreen) FloatingSessionWidget(router: widget.router),
      ],
    );
  }
}
