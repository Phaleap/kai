import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'workout_screen.dart';

class PlanScreen extends StatefulWidget {
  final VoidCallback onOpenCoach;
  const PlanScreen({super.key, required this.onOpenCoach});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedDayIndex = 0;

  Future<void> _startSession(BuildContext context, Session session) async {
    final finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(session: session),
      ),
    );
    if (finished == true) {
      widget.onOpenCoach();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final plan = app.weekPlan;
    final activeSession = plan[_selectedDayIndex.clamp(0, plan.length - 1)];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.gutter,
            16,
            Space.gutter,
            24,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY ROUTINE',
                      style: text.labelSmall?.copyWith(color: c.accentText),
                    ),
                    const SizedBox(height: 2),
                    Text('Training Plan', style: text.headlineLarge),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Text(
                    '${app.profile?.daysPerWeek ?? 4} Days / Wk',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal Day Selector Strip
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plan.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final s = plan[i];
                  final isSelected = i == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = i),
                    child: Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c.primary : c.surface,
                        borderRadius: BorderRadius.circular(Radii.bubble),
                        border: Border.all(
                          color: isSelected ? c.primary : c.cardBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.dayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? c.onPrimary : c.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? c.onPrimary : c.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Current Selected Session Card
            CoachCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Overline('${activeSession.dayLabel} • ${activeSession.tag.toUpperCase()}'),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: c.muted),
                          const SizedBox(width: 4),
                          Text(
                            '~${activeSession.minutes} min',
                            style: TextStyle(fontSize: 12, color: c.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(activeSession.name, style: text.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${activeSession.exercises.length} programmed movements targeting '
                    '${activeSession.exercises.map((e) => e.muscleGroup).toSet().join(', ')}.',
                    style: text.bodyMedium?.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _startSession(context, activeSession),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('Start ${activeSession.name}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Programmed Exercises', style: text.headlineSmall),
            const SizedBox(height: 12),

            // Exercise List
            for (var i = 0; i < activeSession.exercises.length; i++) ...[
              _ExerciseCard(
                exercise: activeSession.exercises[i],
                index: i + 1,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseCard({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.bubble),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              MuscleTag(muscle: exercise.muscleGroup),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${exercise.sets} sets × ${exercise.targetReps} reps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.onSurface,
                ),
              ),
              if (exercise.startWeight > 0) ...[
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: c.muted)),
                const SizedBox(width: 8),
                Text(
                  'Starting at ${formatKg(exercise.startWeight)} kg',
                  style: TextStyle(fontSize: 13, color: c.muted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            exercise.tip,
            style: text.bodyMedium?.copyWith(
              fontSize: 12,
              color: c.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
