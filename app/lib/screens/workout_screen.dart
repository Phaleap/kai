import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'workout_celebration_screen.dart';

const _restSeconds = 120;

class WorkoutScreen extends StatefulWidget {
  final Session session;
  const WorkoutScreen({super.key, required this.session});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _exIndex = 0;
  int _setIndex = 0;
  late double _weight;
  late int _reps;
  final Map<int, List<LoggedSet>> _logged = {};
  final Stopwatch _elapsed = Stopwatch()..start();

  Timer? _ticker;
  int _restLeft = 0;

  Exercise get _ex => widget.session.exercises[_exIndex];
  bool get _isLastExercise => _exIndex == widget.session.exercises.length - 1;

  @override
  void initState() {
    super.initState();
    _loadExercise();
    // One tick per second keeps the rest timer and the clock fresh.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_restLeft > 0) _restLeft--;
      });
    });
  }

  void _loadExercise() {
    _weight = _ex.startWeight;
    _reps = _ex.targetReps;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _logSet() {
    _logged.putIfAbsent(_exIndex, () => []).add(LoggedSet(_weight, _reps));
    if (_setIndex < _ex.sets - 1) {
      setState(() {
        _setIndex++;
        _restLeft = _restSeconds;
      });
    } else if (!_isLastExercise) {
      setState(() {
        _exIndex++;
        _setIndex = 0;
        _loadExercise();
        _restLeft = _restSeconds;
      });
    } else {
      _finish();
    }
  }

  void _skipExercise() {
    if (_isLastExercise) {
      _finish();
      return;
    }
    setState(() {
      _exIndex++;
      _setIndex = 0;
      _loadExercise();
      _restLeft = 0;
    });
  }

  Future<void> _finish() async {
    final app = AppScope.of(context);
    final result = WorkoutResult(
      widget.session,
      Map.of(_logged),
      durationSeconds: _elapsed.elapsed.inSeconds,
    );
    // Don't wait for the coach's reply; it appears in the chat.
    app.finishWorkout(result);
    if (!mounted) return;
    final openCoach = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkoutCelebrationScreen(
          result: result,
          onOpenCoach: () {},
        ),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(openCoach ?? true);
  }

  Future<void> _confirmEnd() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End workout?'),
        content: Text(
          _logged.isEmpty
              ? 'Nothing is logged yet. That\'s okay, rest days count too.'
              : 'I\'ll save the sets you logged so far.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (end != true || !mounted) return;
    if (_logged.isEmpty) {
      Navigator.of(context).pop(false);
    } else {
      _finish();
    }
  }

  Future<void> _painHelp() async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop this exercise'),
        content: const Text(
          'Sharp pain is a signal to stop, not push through. '
          'If it does not go away or gets worse, please see a doctor or physio. '
          'I am a coach, not a medical professional.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('It was nothing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Skip exercise'),
          ),
        ],
      ),
    );
    if (skip == true) _skipExercise();
  }

  String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final ex = _ex;
    final diff = ex.lastWeight == null ? 0.0 : _weight - ex.lastWeight!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.gutter,
                  16,
                  Space.gutter,
                  12,
                ),
                children: [
                  Row(
                    children: [
                      RoundButton(
                        icon: Icons.close_rounded,
                        tooltip: 'End workout',
                        onPressed: _confirmEnd,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.session.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Exercise ${_exIndex + 1} of ${widget.session.exercises.length}',
                              style: TextStyle(fontSize: 12, color: c.muted),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          _clock(_elapsed.elapsed.inSeconds),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.muted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentBar(
                    total: widget.session.exercises.length,
                    done: _exIndex,
                    highlightCurrent: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ex.name,
                    style: text.headlineLarge?.copyWith(
                      fontSize: 30,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MuscleTag(muscle: ex.muscleGroup),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Set ${_setIndex + 1}/${ex.sets}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      for (var i = 0; i < ex.sets; i++)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _setIndex
                                ? c.primary
                                : (i == _setIndex ? c.accent : null),
                            border: i > _setIndex
                                ? Border.all(color: c.outline, width: 1.5)
                                : null,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (ex.lastWeight != null)
                        Expanded(
                          child: Text(
                            'Last time ${formatKg(ex.lastWeight!)} kg × ${ex.lastReps}',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: c.muted),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Stepper(
                    label: 'Weight',
                    value: formatKg(_weight),
                    unit: 'kg',
                    badge: diff > 0
                        ? '+${formatKg(diff)} kg on last time'
                        : null,
                    onMinus: _weight > 0
                        ? () => setState(
                            () => _weight = (_weight - ex.weightStep).clamp(
                              0,
                              999,
                            ),
                          )
                        : null,
                    onPlus: () => setState(() => _weight += ex.weightStep),
                    minusTip: 'Less weight',
                    plusTip: 'More weight',
                  ),
                  const SizedBox(height: Space.cardGap),
                  _Stepper(
                    label: 'Reps',
                    value: '$_reps',
                    unit: 'reps',
                    onMinus: _reps > 1 ? () => setState(() => _reps--) : null,
                    onPlus: () => setState(() => _reps++),
                    minusTip: 'Fewer reps',
                    plusTip: 'More reps',
                  ),
                  const SizedBox(height: Space.cardGap),
                  if (_restLeft > 0) ...[
                    CoachCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: CircularProgressIndicator(
                              value: _restLeft / _restSeconds,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              color: c.accent,
                              backgroundColor: c.surfaceAlt,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _clock(_restLeft),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Rest · ${_clock(_restSeconds)} between sets',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _SmallPill(
                            label: '+30s',
                            outlined: true,
                            onTap: () => setState(() => _restLeft += 30),
                          ),
                          const SizedBox(width: 8),
                          _SmallPill(
                            label: 'Skip',
                            onTap: () => setState(() => _restLeft = 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.cardGap),
                  ],
                  CoachCard(
                    color: c.surfaceAlt,
                    radius: Radii.bubble,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Form tip',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(ex.tip, style: text.bodyMedium),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: _painHelp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                            foregroundColor: c.accentText,
                          ),
                          child: const Text(
                            'Sharp pain? Stop this exercise.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.gutter,
                0,
                Space.gutter,
                16,
              ),
              child: FilledButton(
                onPressed: _logSet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _isLastExercise && _setIndex == ex.sets - 1
                            ? 'Log set and finish'
                            : 'Log set and next',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? badge;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  final String minusTip;
  final String plusTip;

  const _Stepper({
    required this.label,
    required this.value,
    required this.unit,
    this.badge,
    required this.onMinus,
    required this.onPlus,
    required this.minusTip,
    required this.plusTip,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CoachCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Overline(label),
              const SizedBox(width: 8),
              if (badge != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Text(
                      badge!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.onAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              RoundButton(
                icon: Icons.remove_rounded,
                tooltip: minusTip,
                size: 56,
                background: c.surfaceAlt,
                onPressed: onMinus,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RoundButton(
                icon: Icons.add_rounded,
                tooltip: plusTip,
                size: 56,
                background: c.primary,
                foreground: c.onPrimary,
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  const _SmallPill({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: outlined ? Colors.transparent : c.surfaceAlt,
      shape: StadiumBorder(
        side: outlined
            ? BorderSide(color: c.outline, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
