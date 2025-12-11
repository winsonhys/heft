import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../shared/theme/app_theme.dart';
import 'router.dart';

/// Main app widget
class HeftyChestApp extends StatelessWidget {
  const HeftyChestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp.router(
      title: 'Heft',
      theme: shadcn.ThemeData(
        colorScheme: buildShadcnColorScheme(),
        radius: 0.5,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
