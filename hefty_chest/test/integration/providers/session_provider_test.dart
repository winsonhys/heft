import 'package:connectrpc/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hefty_chest/gen/session.connect.spec.dart' as session_specs;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    resetTransport();
  });

  group('Session Provider - Contract Tests', () {
    test('checks for active session via provider', () async {
      final fakeSession = Session()
        ..id = 'session-1'
        ..workoutTemplateId = 'w-1'
        ..name = 'Test Workout'
        ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

      final transport = (FakeTransportBuilder()
            ..unary(session_specs.SessionService.listSessions, (req, ctx) {
              return ListSessionsResponse()
                ..sessions.add(SessionSummary()..id = 'session-1');
            })
            ..unary(session_specs.SessionService.getSession, (req, ctx) {
              return GetSessionResponse()..session = fakeSession;
            }))
          .build();

      useTestTransport(transport);

      final container = ProviderContainer();
      final activeSession =
          await container.read(hasActiveSessionProvider.future);

      expect(activeSession, isNotNull);
      expect(activeSession!.id, equals('session-1'));

      container.dispose();
    });

    test('hasActiveSessionProvider returns null when no active session',
        () async {
      final transport = (FakeTransportBuilder()
            ..unary(session_specs.SessionService.listSessions, (req, ctx) {
              return ListSessionsResponse(); // empty
            }))
          .build();

      useTestTransport(transport);

      final container = ProviderContainer();
      final activeSession =
          await container.read(hasActiveSessionProvider.future);

      expect(activeSession, isNull);

      container.dispose();
    });

    test('hasActiveSessionProvider returns null after finishing session',
        () async {
      var sessionFinished = false;

      final fakeSession = Session()
        ..id = 'session-1'
        ..workoutTemplateId = 'w-1'
        ..name = 'Test Workout'
        ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

      final transport = (FakeTransportBuilder()
            ..unary(session_specs.SessionService.listSessions, (req, ctx) {
              if (sessionFinished) return ListSessionsResponse();
              return ListSessionsResponse()
                ..sessions.add(SessionSummary()..id = 'session-1');
            })
            ..unary(session_specs.SessionService.getSession, (req, ctx) {
              return GetSessionResponse()..session = fakeSession;
            })
            ..unary(session_specs.SessionService.finishSession, (req, ctx) {
              sessionFinished = true;
              return FinishSessionResponse();
            }))
          .build();

      useTestTransport(transport);

      final container = ProviderContainer();

      // Verify session is active
      final activeSessionBefore =
          await container.read(hasActiveSessionProvider.future);
      expect(activeSessionBefore, isNotNull);
      expect(activeSessionBefore!.id, equals('session-1'));

      // Finish the session
      await sessionClient.finishSession(
        FinishSessionRequest()..id = 'session-1',
      );

      // Refresh and verify no active session
      final activeSessionAfter =
          await container.refresh(hasActiveSessionProvider.future);
      expect(activeSessionAfter, isNull);

      container.dispose();
    });

    test('hasActiveSessionProvider returns null after abandoning session',
        () async {
      var sessionAbandoned = false;

      final fakeSession = Session()
        ..id = 'session-1'
        ..workoutTemplateId = 'w-1'
        ..name = 'Test Workout'
        ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

      final transport = (FakeTransportBuilder()
            ..unary(session_specs.SessionService.listSessions, (req, ctx) {
              if (sessionAbandoned) return ListSessionsResponse();
              return ListSessionsResponse()
                ..sessions.add(SessionSummary()..id = 'session-1');
            })
            ..unary(session_specs.SessionService.getSession, (req, ctx) {
              return GetSessionResponse()..session = fakeSession;
            })
            ..unary(session_specs.SessionService.abandonSession, (req, ctx) {
              sessionAbandoned = true;
              return AbandonSessionResponse();
            }))
          .build();

      useTestTransport(transport);

      final container = ProviderContainer();

      // Verify session is active
      final activeSessionBefore =
          await container.read(hasActiveSessionProvider.future);
      expect(activeSessionBefore, isNotNull);
      expect(activeSessionBefore!.id, equals('session-1'));

      // Abandon the session
      await sessionClient.abandonSession(
        AbandonSessionRequest()..id = 'session-1',
      );

      // Refresh and verify no active session
      final activeSessionAfter =
          await container.refresh(hasActiveSessionProvider.future);
      expect(activeSessionAfter, isNull);

      container.dispose();
    });
  });
}
