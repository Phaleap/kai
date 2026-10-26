import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

const String baseUrl = 'http://127.0.0.1:8000';

/// Everything the screens share. Lives in memory for now
/// (it resets when the app restarts; a database comes in Stage 2).
class AppState extends ChangeNotifier {
  Profile? profile;
  final Set<DateTime> completedDays = {};
  CheckIn checkIn = CheckIn();
  final List<ChatMessage> messages = [];
  bool chatLoading = false;
  Session todaySession = sampleSession();
  List<Session> weekPlan = sampleWeeklyPlan();
  final List<WorkoutResult> workoutHistory = [];
  final List<PersonalBest> allPersonalBests = [];
  String weightUnit = 'kg'; // 'kg' or 'lbs'

  void finishOnboarding(Profile p) {
    profile = p;
    messages.add(
      ChatMessage.coach(
        'Hi ${p.name}, I\'m Kai. I built your first week around '
        '${p.daysPerWeek} days of training. Ask me anything, '
        'and tell me if something hurts.',
      ),
    );
    notifyListeners();
  }

  void updateProfile(Profile p) {
    profile = p;
    notifyListeners();
  }

  void setWeightUnit(String unit) {
    weightUnit = unit;
    notifyListeners();
  }

  void selectTodaySession(Session s) {
    todaySession = s;
    notifyListeners();
  }

  void updateCheckIn(CheckIn value) {
    checkIn = value;
    notifyListeners();
  }

  bool get doneToday => completedDays.contains(dateOnly(DateTime.now()));

  /// Training days in a row. Rest days in between do not break it:
  /// a streak only ends after 3 days without training.
  int get streak {
    if (completedDays.isEmpty) return 0;
    var day = dateOnly(DateTime.now());
    var count = 0;
    var gap = 0;
    while (gap < 3) {
      if (completedDays.contains(day)) {
        count++;
        gap = 0;
      } else {
        gap++;
      }
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Total volume lifted across all logged workouts.
  double get totalVolumeLifted {
    var sum = 0.0;
    for (final w in workoutHistory) {
      sum += w.totalVolume;
    }
    return sum;
  }

  /// Formats weight using current unit.
  String formatWeight(double weightInKg) {
    final val = weightUnit == 'lbs' ? weightInKg * 2.20462 : weightInKg;
    final str = val == val.roundToDouble()
        ? val.toStringAsFixed(0)
        : val.toStringAsFixed(1);
    return '$str $weightUnit';
  }

  /// Called when a workout ends: marks today done, records history & PRs,
  /// and sends the summary to the coach so Kai can react.
  Future<void> finishWorkout(WorkoutResult result) async {
    completedDays.add(dateOnly(DateTime.now()));
    workoutHistory.insert(0, result);
    for (final pr in result.personalBests) {
      allPersonalBests.insert(
        0,
        PersonalBest(
          pr.exercise,
          pr.weight,
          pr.reps,
          achievedAt: DateTime.now(),
        ),
      );
      messages.add(ChatMessage.pr(pr));
    }
    notifyListeners();
    await sendToCoach(result.summaryText());
  }

  Future<void> sendToCoach(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || chatLoading) return;
    messages.add(ChatMessage.user(clean));
    chatLoading = true;
    notifyListeners();

    String reply;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'messages': messages
                  .where((m) => m.kind != MessageKind.pr)
                  .map((m) => {'role': m.role, 'content': m.text})
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 4));
      reply = jsonDecode(utf8.decode(response.bodyBytes))['reply'] as String;
    } catch (e) {
      // Smart offline fallback when AI backend at 127.0.0.1:8000 is not running
      reply = _generateOfflineFallback(clean);
    }

    messages.add(ChatMessage.coach(stripMarkdown(reply)));
    chatLoading = false;
    notifyListeners();
  }

  String _generateOfflineFallback(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('finished') || lower.contains('just finished')) {
      return 'Great work on finishing that session! That was high quality effort. Make sure you get 20-30g of protein within the next couple hours and drink plenty of water. Sleep is where the real adaptation happens.';
    }
    if (lower.contains('sore') || lower.contains('pain') || lower.contains('hurt')) {
      return 'Remember that sharp pain is always a sign to stop and check with a physician. Mild muscle tightness or soreness usually benefits from light walking, gentle foam rolling, and adequate hydration.';
    }
    if (lower.contains('swap') || lower.contains('replace')) {
      return 'If an exercise machine is taken or an angle feels awkward, you can always swap to a dumbbell variation or a bodyweight equivalent with similar movement mechanics.';
    }
    if (lower.contains('how did i do') || lower.contains('progress')) {
      return 'You are building serious momentum! Consistency is the number one driver of progress. Keep logging each set, respect your rest days, and the results will compound.';
    }
    return 'I hear you! Stay consistent, keep progressive overload in mind, and listen to your body. (Note: AI backend at localhost:8000 is offline; responding via smart local assistant).';
  }
}

/// The server sometimes replies with markdown stars; show plain text.
String stripMarkdown(String text) {
  return text
      .replaceAll('**', '')
      .replaceAll(RegExp(r'^\s*[\*\-] ', multiLine: true), '• ')
      .replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Gives every screen access to AppState: `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
