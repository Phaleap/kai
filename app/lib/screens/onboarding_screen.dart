import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class _Answer {
  final String title;
  final String subtitle;
  const _Answer(this.title, this.subtitle);
}

class _Question {
  final String text;
  final String help;
  final List<_Answer> answers;
  const _Question(this.text, this.help, this.answers);
}

const _questions = [
  _Question('What is your main goal?', 'We can change it any time.', [
    _Answer('Build muscle', 'Get bigger and stronger'),
    _Answer('Lose fat', 'Get leaner, keep my muscle'),
    _Answer('Get fitter', 'More energy, feel better'),
  ]),
  _Question(
    'How much have you trained before?',
    'No wrong answer. I will set the starting point.',
    [
      _Answer('New to the gym', 'I will teach every move'),
      _Answer('Some experience', 'I know the basics'),
      _Answer('A year or more', 'I train regularly'),
    ],
  ),
  _Question(
    'How many days a week can you train?',
    'Pick what fits a normal week, not your best week.',
    [
      _Answer('2 days', 'Short and simple'),
      _Answer('3 days', 'Great for most beginners'),
      _Answer('4 days', 'A bit more volume'),
      _Answer('5 days', 'For when you are hooked'),
    ],
  ),
  _Question(
    'Any injuries or pain I should know about?',
    'This helps me pick safe exercises for you.',
    [
      _Answer('No, I feel good', 'Train normally'),
      _Answer('An old injury', 'I will avoid moves that bother it'),
      _Answer('Something hurts right now', 'We start gentle and safe'),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  // Step 0 is the name, steps 1..4 are the questions.
  int _step = 0;
  final List<int?> _picked = List.filled(_questions.length, null);

  int get _totalSteps => _questions.length + 1;

  bool get _canContinue => _step == 0
      ? _nameController.text.trim().isNotEmpty
      : _picked[_step - 1] != null;

  bool get _hurtsNow => _step == 4 && _picked[3] == 2;

  void _next() {
    if (!_canContinue) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      return;
    }
    final a = _picked;
    AppScope.of(context).finishOnboarding(
      Profile(
        name: _nameController.text.trim(),
        goal: _questions[0].answers[a[0]!].title,
        experience: _questions[1].answers[a[1]!].title,
        daysPerWeek: a[2]! + 2,
        injuries: _questions[3].answers[a[3]!].title,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final question = _step == 0 ? null : _questions[_step - 1];

    return Scaffold(
      body: SafeArea(
        // Scrolls on small phones; on normal phones the Spacer pushes
        // the answers to the bottom, near your thumb.
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              16,
              Space.gutter,
              24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 40),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        RoundButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          tooltip: 'Back',
                          onPressed: _step == 0
                              ? null
                              : () => setState(() => _step--),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'About you',
                                    style: text.labelMedium?.copyWith(
                                      color: c.muted,
                                    ),
                                  ),
                                  Text(
                                    '${_step + 1} of $_totalSteps',
                                    style: text.labelMedium?.copyWith(
                                      color: c.muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SegmentBar(total: _totalSteps, done: _step + 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const CoachAvatar(size: 52),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kai',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Your coach',
                              style: text.labelMedium?.copyWith(color: c.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(26),
                          bottomLeft: Radius.circular(26),
                          bottomRight: Radius.circular(26),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question?.text ??
                                'Hi, I\'m Kai. What should I call you?',
                            style: text.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          // Kai answers right away when something hurts now.
                          if (_hurtsNow)
                            Text(
                              'If the pain is sharp or getting worse, please see a doctor '
                              'or physio first. Until then I will keep things gentle.',
                              style: text.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              question?.help ??
                                  'I will be your coach for every workout.',
                              style: text.bodyLarge?.copyWith(color: c.muted),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (question == null)
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _next(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your first name',
                          filled: true,
                          fillColor: c.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Radii.bubble),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < question.answers.length; i++) ...[
                        _AnswerButton(
                          answer: question.answers[i],
                          selected: _picked[_step - 1] == i,
                          onTap: () => setState(() => _picked[_step - 1] = i),
                        ),
                        const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 6),
                    FilledButton(
                      onPressed: _canContinue ? _next : null,
                      child: Text(
                        _step == _totalSteps - 1 ? 'Build my plan' : 'Continue',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final _Answer answer;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.bubble),
          side: BorderSide(
            color: selected ? c.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.bubble),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        answer.subtitle,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? c.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? c.primary : c.outline,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 16, color: c.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
