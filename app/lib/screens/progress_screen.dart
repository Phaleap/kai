import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class ProgressScreen extends StatelessWidget {
  final VoidCallback onStartTodayWorkout;

  const ProgressScreen({super.key, required this.onStartTodayWorkout});

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final prs = app.allPersonalBests;
    final history = app.workoutHistory;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'METRICS & MILESTONES',
                  style: text.labelSmall?.copyWith(color: c.accentText),
                ),
                const SizedBox(height: 2),
                Text('Progress', style: text.headlineLarge),
              ],
            ),
            const SizedBox(height: 16),

            // Key Highlights Bar
            Row(
              children: [
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Streak',
                    value: '${app.streak} days',
                    accentColor: c.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.fitness_center_rounded,
                    label: 'Total Volume',
                    value: app.formatWeight(app.totalVolumeLifted),
                    accentColor: c.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Workouts',
                    value: '${app.completedDays.length}',
                    accentColor: c.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Personal Records (PR) Showcase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Personal Records (PR)', style: text.headlineSmall),
                Icon(Icons.emoji_events_rounded, color: c.gold, size: 22),
              ],
            ),
            const SizedBox(height: 12),

            if (prs.isEmpty)
              CoachCard(
                color: c.surface,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.workspace_premium_rounded, color: c.gold),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No PRs yet — your records await!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete workouts with progressive overload to unlock records.',
                            style: TextStyle(fontSize: 12, color: c.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final pr in prs)
                    Container(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(Radii.bubble),
                        border: Border.all(color: c.gold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.military_tech_rounded, size: 18, color: c.gold),
                              const SizedBox(width: 4),
                              Text(
                                'NEW BEST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: c.gold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pr.exercise,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${app.formatWeight(pr.weight)} x ${pr.reps} reps',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.accentText,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 28),

            // Workout History
            Text('Workout Log History', style: text.headlineSmall),
            const SizedBox(height: 12),

            if (history.isEmpty)
              CoachCard(
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 40, color: c.muted),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to log your first session?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed sessions will log here with total weight lifted and duration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: c.muted),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onStartTodayWorkout,
                      child: const Text('Start Workout'),
                    ),
                  ],
                ),
              )
            else
              for (final workout in history) ...[
                _HistoryCard(workout: workout, formatDate: _formatDate),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WorkoutResult workout;
  final String Function(DateTime) formatDate;

  const _HistoryCard({required this.workout, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                workout.session.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                formatDate(workout.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${workout.totalSets} sets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text('•', style: TextStyle(color: c.muted)),
              const SizedBox(width: 8),
              Text(
                'Volume: ${app.formatWeight(workout.totalVolume)}',
                style: TextStyle(fontSize: 13, color: c.muted),
              ),
              if (workout.personalBests.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: c.muted)),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 14, color: c.gold),
                    const SizedBox(width: 2),
                    Text(
                      '${workout.personalBests.length} PR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
