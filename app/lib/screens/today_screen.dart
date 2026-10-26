import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'settings_sheet.dart';
import 'workout_screen.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class TodayScreen extends StatelessWidget {
  /// Switches the bottom nav to the Coach tab.
  final VoidCallback onOpenCoach;

  const TodayScreen({super.key, required this.onOpenCoach});

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Morning';
    if (now.hour < 18) return 'Afternoon';
    return 'Evening';
  }

  /// Kai's one line for today, based on the check-in.
  String _coachLine(AppState app) {
    if (app.doneToday) {
      return 'Session done. Nice work. Rest, eat well and sleep, that is where you grow.';
    }
    final ci = app.checkIn;
    if (ci.soreness == 2) {
      return 'Lots of soreness today. Go a bit lighter and stop if anything feels sharp.';
    }
    if (ci.sleep == 0) {
      return 'Short on sleep? Keep the same weights and focus on clean form.';
    }
    if (ci.energy == 2) {
      return 'Energy is high. Let\'s chase one more rep than last time.';
    }
    return 'Same plan as always: good form first, then one more rep if it feels easy.';
  }

  Future<void> _startWorkout(BuildContext context, AppState app) async {
    final finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(session: app.todaySession),
      ),
    );
    if (finished == true) onOpenCoach();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final name = app.profile?.name ?? 'there';
    final session = app.todaySession;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.gutter, 16, Space.gutter, 16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}',
                      style: text.labelMedium?.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 2),
                    Text('${_greeting(now)}, $name', style: text.headlineLarge),
                  ],
                ),
              ),
              RoundButton(
                icon: Icons.tune_rounded,
                tooltip: 'Settings & Profile',
                size: 40,
                onPressed: () => SettingsSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CoachAvatar(size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Text(_coachLine(app), style: text.bodyMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.cardGap),
          _WeekCard(app: app),
          const SizedBox(height: Space.cardGap),
          CoachCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Overline(app.doneToday ? 'Done today' : 'Today\'s session'),
                const SizedBox(height: 8),
                Text(session.name, style: text.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '${session.exercises.length} exercises · about ${session.minutes} min',
                  style: text.bodyMedium?.copyWith(color: c.muted),
                ),
                Text(
                  '${session.exercises.take(3).map((e) => e.name).join(', ')}'
                  '${session.exercises.length > 3 ? ' +${session.exercises.length - 3} more' : ''}',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in session.exercises.map((e) => e.muscleGroup).toSet())
                      MuscleTag(muscle: m),
                  ],
                ),
                const SizedBox(height: 14),
                if (app.doneToday)
                  FilledButton.icon(
                    onPressed: onOpenCoach,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Talk it over with Kai'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _startWorkout(context, app),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start workout'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.cardGap),
          _CheckInCard(app: app),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final AppState app;
  const _WeekCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final today = dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return CoachCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Overline('Streak'),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${app.streak}', style: text.displayMedium),
                        const SizedBox(width: 6),
                        Text(
                          app.streak == 1 ? 'day' : 'days',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'Rest days count.\nKeep it going.',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, height: 1.4, color: c.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _DayCircle(
                  letter: letters[i],
                  date: monday.add(Duration(days: i)),
                  today: today,
                  done: app.completedDays.contains(
                    monday.add(Duration(days: i)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String letter;
  final DateTime date;
  final DateTime today;
  final bool done;

  const _DayCircle({
    required this.letter,
    required this.date,
    required this.today,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isToday = date == today;
    final Color bg;
    final Color fg;
    final Color border;
    if (done) {
      bg = c.primary;
      fg = c.onPrimary;
      border = c.primary;
    } else if (isToday) {
      bg = c.accent;
      fg = c.onAccent;
      border = c.accent;
    } else if (date.isBefore(today)) {
      // A past day without training is a rest day, never a "miss".
      bg = c.surfaceAlt;
      fg = c.onSurface;
      border = c.surfaceAlt;
    } else {
      bg = Colors.transparent;
      fg = c.muted;
      border = c.outline;
    }
    final tag = isToday
        ? 'today'
        : (!done && date.isBefore(today) ? 'rest' : '');

    return Column(
      children: [
        Text(
          letter,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 12,
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: c.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final AppState app;
  const _CheckInCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ci = app.checkIn;
    final rows = <(String, List<String>, int, CheckIn Function(int))>[
      (
        'Sleep',
        ['Poor', 'OK', 'Great'],
        ci.sleep,
        (v) => ci.copyWith(sleep: v),
      ),
      (
        'Energy',
        ['Low', 'OK', 'High'],
        ci.energy,
        (v) => ci.copyWith(energy: v),
      ),
      (
        'Soreness',
        ['None', 'Some', 'A lot'],
        ci.soreness,
        (v) => ci.copyWith(soreness: v),
      ),
    ];

    return CoachCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'How do you feel?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '10 sec check-in',
                style: TextStyle(fontSize: 12, color: c.muted),
              ),
            ],
          ),
          for (final (label, options, value, update) in rows) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ),
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: PillChip(
                      label: options[i],
                      selected: value == i,
                      onTap: () => app.updateCheckIn(update(i)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
