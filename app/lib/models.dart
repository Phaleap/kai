/// Answers from onboarding.
class Profile {
  final String name;
  final String goal;
  final String experience;
  final int daysPerWeek;
  final String injuries;

  const Profile({
    required this.name,
    required this.goal,
    required this.experience,
    required this.daysPerWeek,
    required this.injuries,
  });
}

/// The 10-second check-in on Today. Each value is 0, 1 or 2.
class CheckIn {
  final int sleep;
  final int energy;
  final int soreness;

  CheckIn({this.sleep = 1, this.energy = 1, this.soreness = 0});

  CheckIn copyWith({int? sleep, int? energy, int? soreness}) => CheckIn(
    sleep: sleep ?? this.sleep,
    energy: energy ?? this.energy,
    soreness: soreness ?? this.soreness,
  );
}

class Exercise {
  final String name;
  final int sets;
  final int targetReps;
  final double startWeight;
  final double weightStep;
  final double? lastWeight;
  final int? lastReps;
  final String tip;
  final String muscleGroup;

  const Exercise({
    required this.name,
    required this.sets,
    required this.targetReps,
    required this.startWeight,
    this.weightStep = 2.5,
    this.lastWeight,
    this.lastReps,
    required this.tip,
    this.muscleGroup = 'General',
  });
}

class Session {
  final String name;
  final int minutes;
  final List<Exercise> exercises;
  final String tag;
  final String dayLabel;

  const Session({
    required this.name,
    required this.minutes,
    required this.exercises,
    this.tag = 'Strength',
    this.dayLabel = 'Workout',
  });
}

/// Sample session until plans come from the server.
Session sampleSession() => const Session(
  name: 'Upper Body A',
  minutes: 45,
  tag: 'Upper Body',
  dayLabel: 'Day 1',
  exercises: [
    Exercise(
      name: 'Dumbbell bench press',
      sets: 3,
      targetReps: 10,
      startWeight: 22.5,
      lastWeight: 20,
      lastReps: 10,
      muscleGroup: 'Chest',
      tip:
          'Squeeze your shoulder blades and keep feet flat. '
          'Lower for 2 seconds, then press up strong.',
    ),
    Exercise(
      name: 'Seated cable row',
      sets: 3,
      targetReps: 10,
      startWeight: 40,
      lastWeight: 40,
      lastReps: 10,
      muscleGroup: 'Back',
      tip:
          'Sit tall, pull your elbows back to your ribs, '
          'and pause for a second at the end.',
    ),
    Exercise(
      name: 'Dumbbell shoulder press',
      sets: 3,
      targetReps: 10,
      startWeight: 12.5,
      lastWeight: 12.5,
      lastReps: 9,
      muscleGroup: 'Shoulders',
      tip:
          'Brace your stomach and do not lean back. '
          'Press straight up over your shoulders.',
    ),
    Exercise(
      name: 'Lat pulldown',
      sets: 3,
      targetReps: 12,
      startWeight: 35,
      weightStep: 5,
      lastWeight: 35,
      lastReps: 12,
      muscleGroup: 'Back',
      tip:
          'Pull the bar to your upper chest. '
          'Control it on the way up, no swinging.',
    ),
    Exercise(
      name: 'Dumbbell curl',
      sets: 2,
      targetReps: 12,
      startWeight: 10,
      lastWeight: 10,
      lastReps: 12,
      muscleGroup: 'Arms',
      tip: 'Keep your elbows by your sides. Lower slowly.',
    ),
  ],
);

/// Full weekly routine preview for the Plan tab.
List<Session> sampleWeeklyPlan() => [
  const Session(
    name: 'Upper Body A',
    minutes: 45,
    tag: 'Upper',
    dayLabel: 'Mon',
    exercises: [
      Exercise(
        name: 'Dumbbell bench press',
        sets: 3,
        targetReps: 10,
        startWeight: 22.5,
        lastWeight: 20,
        lastReps: 10,
        muscleGroup: 'Chest',
        tip: 'Keep shoulder blades tucked and drive with your feet.',
      ),
      Exercise(
        name: 'Seated cable row',
        sets: 3,
        targetReps: 10,
        startWeight: 40,
        lastWeight: 40,
        lastReps: 10,
        muscleGroup: 'Back',
        tip: 'Pull to lower ribcage and feel the squeeze.',
      ),
      Exercise(
        name: 'Dumbbell shoulder press',
        sets: 3,
        targetReps: 10,
        startWeight: 12.5,
        lastWeight: 12.5,
        lastReps: 9,
        muscleGroup: 'Shoulders',
        tip: 'Smooth vertical path, avoid arching your lower back.',
      ),
    ],
  ),
  const Session(
    name: 'Lower Body A',
    minutes: 50,
    tag: 'Lower',
    dayLabel: 'Tue',
    exercises: [
      Exercise(
        name: 'Goblet squat',
        sets: 3,
        targetReps: 10,
        startWeight: 24,
        lastWeight: 22,
        lastReps: 10,
        muscleGroup: 'Quads',
        tip: 'Keep elbows under the weight and knees tracking over toes.',
      ),
      Exercise(
        name: 'Romanian deadlift',
        sets: 3,
        targetReps: 10,
        startWeight: 45,
        lastWeight: 40,
        lastReps: 10,
        muscleGroup: 'Hamstrings',
        tip: 'Hinge at the hips, slight knee bend, spine neutral.',
      ),
      Exercise(
        name: 'Leg press',
        sets: 3,
        targetReps: 12,
        startWeight: 80,
        lastWeight: 80,
        lastReps: 12,
        muscleGroup: 'Legs',
        tip: 'Feet shoulder-width, controlled descent.',
      ),
    ],
  ),
  const Session(
    name: 'Mobility & Recovery',
    minutes: 25,
    tag: 'Rest',
    dayLabel: 'Wed',
    exercises: [
      Exercise(
        name: 'World\'s greatest stretch',
        sets: 2,
        targetReps: 8,
        startWeight: 0,
        muscleGroup: 'Full Body',
        tip: 'Sink deep into the lunge and twist towards the sky.',
      ),
      Exercise(
        name: 'Dead hang & Thoracic flow',
        sets: 3,
        targetReps: 45,
        startWeight: 0,
        muscleGroup: 'Back',
        tip: 'Breathe into your belly and decompress the spine.',
      ),
    ],
  ),
  const Session(
    name: 'Upper Body B',
    minutes: 45,
    tag: 'Upper',
    dayLabel: 'Thu',
    exercises: [
      Exercise(
        name: 'Incline dumbbell press',
        sets: 3,
        targetReps: 10,
        startWeight: 20,
        muscleGroup: 'Chest',
        tip: 'Focus on upper chest contraction at the top.',
      ),
      Exercise(
        name: 'Lat pulldown',
        sets: 3,
        targetReps: 12,
        startWeight: 40,
        muscleGroup: 'Back',
        tip: 'Pull elbows down toward back pockets.',
      ),
      Exercise(
        name: 'Cable lateral raise',
        sets: 3,
        targetReps: 15,
        startWeight: 7.5,
        muscleGroup: 'Shoulders',
        tip: 'Lead with the elbows, controlled 2-second negative.',
      ),
    ],
  ),
  const Session(
    name: 'Lower Body B',
    minutes: 45,
    tag: 'Lower',
    dayLabel: 'Fri',
    exercises: [
      Exercise(
        name: 'Bulgarian split squat',
        sets: 3,
        targetReps: 8,
        startWeight: 14,
        muscleGroup: 'Quads',
        tip: 'Keep torso upright or slightly hinged for glute bias.',
      ),
      Exercise(
        name: 'Lying leg curl',
        sets: 3,
        targetReps: 12,
        startWeight: 30,
        muscleGroup: 'Hamstrings',
        tip: 'Point toes toward your shins and pause on squeeze.',
      ),
      Exercise(
        name: 'Standing calf raise',
        sets: 4,
        targetReps: 15,
        startWeight: 35,
        muscleGroup: 'Calves',
        tip: 'Full 3-second stretch at bottom, explosive squeeze on top.',
      ),
    ],
  ),
  const Session(
    name: 'Weekend Active Rest',
    minutes: 30,
    tag: 'Rest',
    dayLabel: 'Sat',
    exercises: [
      Exercise(
        name: 'Brisk outdoor walk / hike',
        sets: 1,
        targetReps: 30,
        startWeight: 0,
        muscleGroup: 'Cardio',
        tip: 'Elevate heart rate gently, get morning sunlight.',
      ),
    ],
  ),
  const Session(
    name: 'Reset & Recharge',
    minutes: 20,
    tag: 'Rest',
    dayLabel: 'Sun',
    exercises: [
      Exercise(
        name: 'Foam rolling & breathing',
        sets: 1,
        targetReps: 20,
        startWeight: 0,
        muscleGroup: 'Recovery',
        tip: 'Relax muscles and prepare mentally for the week ahead.',
      ),
    ],
  ),
];

class LoggedSet {
  final double weight;
  final int reps;
  const LoggedSet(this.weight, this.reps);
}

class PersonalBest {
  final String exercise;
  final double weight;
  final int reps;
  final DateTime? achievedAt;

  const PersonalBest(
    this.exercise,
    this.weight,
    this.reps, {
    this.achievedAt,
  });
}

String formatKg(double w) =>
    w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

class WorkoutResult {
  final Session session;
  final Map<int, List<LoggedSet>> sets;
  final int durationSeconds;
  final String? rpe;
  final DateTime timestamp;

  WorkoutResult(
    this.session,
    this.sets, {
    this.durationSeconds = 0,
    this.rpe,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Total weight lifted across all sets.
  double get totalVolume {
    var sum = 0.0;
    for (final list in sets.values) {
      for (final s in list) {
        sum += s.weight * s.reps;
      }
    }
    return sum;
  }

  /// Total logged sets in this workout.
  int get totalSets {
    var count = 0;
    for (final list in sets.values) {
      count += list.length;
    }
    return count;
  }

  /// Heaviest set that beats last time at the same or more reps.
  List<PersonalBest> get personalBests {
    final result = <PersonalBest>[];
    sets.forEach((i, logged) {
      final ex = session.exercises[i];
      if (ex.lastWeight == null || logged.isEmpty) return;
      final best = logged.reduce((a, b) => a.weight >= b.weight ? a : b);
      if (best.weight > ex.lastWeight! && best.reps >= (ex.lastReps ?? 1)) {
        result.add(PersonalBest(ex.name, best.weight, best.reps));
      }
    });
    return result;
  }

  /// Plain text the coach (and its log_workout tool) can read.
  String summaryText() {
    final lines = <String>['I just finished ${session.name}.'];
    sets.forEach((i, logged) {
      if (logged.isEmpty) return;
      final ex = session.exercises[i];
      final parts = logged
          .map((s) => '${formatKg(s.weight)} kg x ${s.reps}')
          .join(', ');
      lines.add('${ex.name}: $parts');
    });
    return lines.join('\n');
  }
}

enum MessageKind { text, pr }

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;
  final MessageKind kind;
  final PersonalBest? pr;

  const ChatMessage._(this.role, this.text, this.kind, this.pr);

  factory ChatMessage.user(String text) =>
      ChatMessage._('user', text, MessageKind.text, null);
  factory ChatMessage.coach(String text) =>
      ChatMessage._('assistant', text, MessageKind.text, null);
  factory ChatMessage.pr(PersonalBest pr) =>
      ChatMessage._('assistant', '', MessageKind.pr, pr);

  bool get isUser => role == 'user';
}
