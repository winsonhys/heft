import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hefty_chest/app/router.dart';

void main() {
  group('Route matching', () {
    test('/session/empty matches EmptySessionRoute, not ResumeSessionRoute', () {
      // Both routes could match /session/empty — order determines winner
      expect(const EmptySessionRoute().location, '/session/empty');
      expect(
        const ResumeSessionRoute(sessionId: 'empty').location,
        '/session/empty',
      );

      // EmptySessionRoute must precede ResumeSessionRoute in the route list
      // so GoRouter matches the literal path before the parameterized one
      final emptyIdx = $appRoutes.indexWhere(
        (r) => r is GoRoute && (r as GoRoute).path == '/session/empty',
      );
      final resumeIdx = $appRoutes.indexWhere(
        (r) => r is GoRoute && (r as GoRoute).path == '/session/:sessionId',
      );
      expect(emptyIdx, isNonNegative, reason: 'EmptySessionRoute must exist');
      expect(resumeIdx, isNonNegative, reason: 'ResumeSessionRoute must exist');
      expect(emptyIdx, lessThan(resumeIdx),
          reason: '/session/empty must precede /session/:sessionId to avoid collision');
    });

    test('/session/<uuid> matches ResumeSessionRoute', () {
      const uuid = '550e8400-e29b-41d4-a716-446655440000';
      expect(
        const ResumeSessionRoute(sessionId: uuid).location,
        '/session/$uuid',
      );
    });

    test('/ matches HomeRoute', () {
      expect(const HomeRoute().location, '/');
    });

    test('/history/<uuid> matches HistoryDetailRoute', () {
      const uuid = '550e8400-e29b-41d4-a716-446655440000';
      expect(
        const HistoryDetailRoute(sessionId: uuid).location,
        '/history/$uuid',
      );
    });
  });
}
