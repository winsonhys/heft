import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Assert finder matches exactly one widget, then tap it.
/// Never silently skips — fails with [reason] if widget not found.
Future<void> safeTap(
  WidgetTester tester,
  Finder finder, {
  String? reason,
  bool warnIfMissed = true,
}) async {
  expect(finder, findsOneWidget,
      reason: reason ?? 'safeTap: widget not found for $finder');
  await tester.tap(finder, warnIfMissed: warnIfMissed);
}

/// Find a widget by Key, assert it exists, then tap it.
Future<void> tapByKey(
  WidgetTester tester,
  String key, {
  String? reason,
  bool warnIfMissed = true,
}) async {
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget,
      reason: reason ?? 'tapByKey: no widget with Key("$key")');
  await tester.tap(finder, warnIfMissed: warnIfMissed);
}

/// Tap a widget that may be off-screen (e.g. FHeaderAction suffixes at x~975).
/// Finds the widget and invokes onTap directly on its GestureDetector ancestor.
Future<void> tapOffScreen(
  WidgetTester tester,
  Finder finder, {
  String? reason,
}) async {
  expect(finder, findsOneWidget,
      reason: reason ?? 'tapOffScreen: widget not found for $finder');
  final gestureDetector = find.ancestor(
    of: finder,
    matching: find.byType(GestureDetector),
  );
  expect(gestureDetector, findsWidgets,
      reason:
          'tapOffScreen: no GestureDetector ancestor for $finder');
  final widget = tester.widget<GestureDetector>(gestureDetector.first);
  widget.onTap?.call();
}

/// Tap a GestureDetector found by Key, invoking onTap directly.
/// Works even if the widget is off-screen.
Future<void> tapOffScreenByKey(
  WidgetTester tester,
  String key, {
  String? reason,
}) async {
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget,
      reason: reason ?? 'tapOffScreenByKey: no widget with Key("$key")');
  final widget = tester.firstWidget(finder);
  if (widget is GestureDetector) {
    widget.onTap?.call();
  } else {
    // Find enclosing GestureDetector
    final gestureDetector = find.ancestor(
      of: finder,
      matching: find.byType(GestureDetector),
    );
    expect(gestureDetector, findsWidgets,
        reason:
            'tapOffScreenByKey: no GestureDetector ancestor for Key("$key")');
    tester.widget<GestureDetector>(gestureDetector.first).onTap?.call();
  }
}

/// Poll for a widget to appear, failing after [timeout] instead of silently returning.
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration pollInterval = const Duration(milliseconds: 500),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await Future.delayed(pollInterval);
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return;
  }
  fail(reason ??
      'waitForWidget: $finder did not appear within ${timeout.inSeconds}s');
}
