import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coach_app/app_state.dart';
import 'package:coach_app/main.dart';
import 'package:coach_app/models.dart';

void main() {
  testWidgets('Onboarding leads to the Today screen', (tester) async {
    // A normal phone screen, so the layout is checked at real size.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CoachApp(state: AppState()));

    await tester.enterText(find.byType(TextField), 'Leap');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    for (final answer in ['Build muscle', 'Some experience', '3 days']) {
      await tester.tap(find.text(answer));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
    }
    await tester.tap(find.text('Something hurts right now'));
    await tester.pump();
    expect(find.textContaining('see a doctor'), findsOneWidget);
    await tester.tap(find.text('Build my plan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Leap'), findsWidgets);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('A full workout ends in the coach chat with a PR card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = AppState()
      ..finishOnboarding(
        const Profile(
          name: 'Leap',
          goal: 'Build muscle',
          experience: 'Some experience',
          daysPerWeek: 3,
          injuries: 'No, I feel good',
        ),
      );
    await tester.pumpWidget(CoachApp(state: state));
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(find.text('Dumbbell bench press'), findsOneWidget);
    expect(find.text('+2.5 kg on last time'), findsOneWidget);

    final totalSets = state.todaySession.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets,
    );
    for (var i = 0; i < totalSets; i++) {
      await tester.tap(find.textContaining('Log set and'));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // Celebration screen appears, tap to discuss with Coach Kai
    expect(find.text('Discuss with Coach Kai'), findsOneWidget);
    await tester.tap(find.text('Discuss with Coach Kai'));
    await tester.pumpAndSettle();

    // We land on the Coach tab, and the PR card is in the chat.
    expect(find.text('Message Kai'), findsOneWidget);
    expect(state.messages.where((m) => m.kind == MessageKind.pr).length, 1);
    expect(state.doneToday, isTrue);
    expect(state.streak, 1);
  });

  test('Rest days do not break the streak', () {
    final app = AppState();
    final today = dateOnly(DateTime.now());
    app.completedDays.addAll([
      today,
      today.subtract(const Duration(days: 2)), // one rest day between
      today.subtract(const Duration(days: 3)),
    ]);
    expect(app.streak, 3);
  });

  test('A heavier set than last time is a personal best', () {
    final session = sampleSession();
    final result = WorkoutResult(session, {
      0: const [LoggedSet(22.5, 10), LoggedSet(22.5, 9)],
      1: const [LoggedSet(40, 10)],
    });
    expect(result.personalBests.length, 1);
    expect(result.personalBests.first.exercise, 'Dumbbell bench press');
    expect(result.summaryText(), contains('22.5 kg x 10, 22.5 kg x 9'));
  });
}
