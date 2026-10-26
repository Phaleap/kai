import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class WorkoutCelebrationScreen extends StatefulWidget {
  final WorkoutResult result;
  final VoidCallback onOpenCoach;

  const WorkoutCelebrationScreen({
    super.key,
    required this.result,
    required this.onOpenCoach,
  });

  @override
  State<WorkoutCelebrationScreen> createState() =>
      _WorkoutCelebrationScreenState();
}

class _WorkoutCelebrationScreenState extends State<WorkoutCelebrationScreen> {
  String _selectedRpe = 'Just Right';

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '35 min';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins == 0) return '$secs sec';
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final name = app.profile?.name ?? 'Champ';
    final prs = widget.result.personalBests;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.gutter,
            vertical: 24,
          ),
          children: [
            const SizedBox(height: 12),
            // Celebration Icon Header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent.withValues(alpha: 0.15),
                  border: Border.all(color: c.accent, width: 2),
                ),
                child: Center(
                  child: Icon(
                    prs.isNotEmpty ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
                    size: 44,
                    color: prs.isNotEmpty ? c.gold : c.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              prs.isNotEmpty ? 'New Records Unlocked! 🏆' : 'Workout Crushed! 🔥',
              textAlign: TextAlign.center,
              style: text.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'High quality effort today, $name. Consistency is how strength compounds.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: c.muted),
            ),
            const SizedBox(height: 28),

            // Performance Metrics Grid
            Row(
              children: [
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.fitness_center_rounded,
                    label: 'Volume',
                    value: app.formatWeight(widget.result.totalVolume),
                    accentColor: c.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(widget.result.durationSeconds),
                    accentColor: c.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.repeat_rounded,
                    label: 'Sets Finished',
                    value: '${widget.result.totalSets} sets',
                    accentColor: c.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatMetricTile(
                    icon: Icons.checklist_rounded,
                    label: 'Exercises',
                    value: '${widget.result.session.exercises.length} moves',
                    accentColor: c.accentText,
                  ),
                ),
              ],
            ),

            // PR Showcase Cards (if any)
            if (prs.isNotEmpty) ...[
              const SizedBox(height: 24),
              CoachCard(
                color: c.gold.withValues(alpha: 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: c.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'PERSONAL BESTS TODAY',
                          style: TextStyle(
                            color: c.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final pr in prs)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pr.exercise,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: c.gold,
                                borderRadius: BorderRadius.circular(Radii.pill),
                              ),
                              child: Text(
                                '${app.formatWeight(pr.weight)} x ${pr.reps}',
                                style: TextStyle(
                                  color: c.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Effort / RPE Check
            CoachCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Overline('How did today feel?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final level in ['Smooth', 'Just Right', 'Intense'])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: PillChip(
                              label: level,
                              selected: _selectedRpe == level,
                              onTap: () => setState(() => _selectedRpe = level),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Navigation Actions
            FilledButton.icon(
              onPressed: () {
                widget.onOpenCoach();
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              label: const Text('Discuss with Coach Kai'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Back to Today',
                style: TextStyle(
                  color: c.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
