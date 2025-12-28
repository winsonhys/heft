import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/logging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging before anything else
  initializeLogging();

  runApp(
    const ProviderScope(
      child: HeftyChestApp(),
    ),
  );
}
