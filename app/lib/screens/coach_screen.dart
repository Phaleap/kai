import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

const _quickReplies = ['How did I do?', 'Swap an exercise', 'I feel sore'];

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  void _send(AppState app, String text) {
    _controller.clear();
    app.sendToCoach(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    // Newest message at the bottom: the list is reversed.
    final items = app.messages.reversed.toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              16,
              Space.gutter,
              8,
            ),
            child: Row(
              children: [
                const CoachAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kai',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your coach · not medical advice',
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(
                Space.gutter,
                8,
                Space.gutter,
                8,
              ),
              itemCount: items.length + (app.chatLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (app.chatLoading && index == 0) return const _TypingBubble();
                final m = items[index - (app.chatLoading ? 1 : 0)];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: m.kind == MessageKind.pr
                      ? _PrCard(pr: m.pr!)
                      : _Bubble(message: m),
                );
              },
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Space.gutter,
                vertical: 4,
              ),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => PillChip(
                label: _quickReplies[i],
                selected: false,
                outlined: true,
                onTap: () => _send(app, _quickReplies[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Row(
                children: [
                  RoundButton(
                    icon: Icons.photo_camera_outlined,
                    tooltip: 'Add a photo',
                    background: c.surfaceAlt,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photos are coming soon.')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (t) => _send(app, t),
                      decoration: const InputDecoration(
                        hintText: 'Message Kai',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  RoundButton(
                    icon: Icons.arrow_upward_rounded,
                    tooltip: 'Send',
                    background: c.primary,
                    foreground: c.onPrimary,
                    onPressed: app.chatLoading
                        ? null
                        : () => _send(app, _controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = message.isUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: user ? c.primary : c.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(Radii.bubble),
            topRight: const Radius.circular(Radii.bubble),
            bottomLeft: Radius.circular(user ? Radii.bubble : 6),
            bottomRight: Radius.circular(user ? 6 : Radii.bubble),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: user ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  final PersonalBest pr;
  const _PrCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(Radii.bubble),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: c.onAccent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    size: 16,
                    color: c.onAccent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'NEW PERSONAL BEST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                pr.exercise,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${app.formatWeight(pr.weight)} × ${pr.reps}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.bubble),
        ),
        child: Text(
          'Kai is typing…',
          style: TextStyle(fontSize: 14, color: c.muted),
        ),
      ),
    );
  }
}
