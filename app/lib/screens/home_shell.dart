import 'package:flutter/material.dart';

import '../theme.dart';
import 'coach_screen.dart';
import 'plan_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(onOpenCoach: () => setState(() => _tab = 3)),
      PlanScreen(onOpenCoach: () => setState(() => _tab = 3)),
      ProgressScreen(onStartTodayWorkout: () => setState(() => _tab = 0)),
      const CoachScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Today',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Plan',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                selected: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Coach',
                selected: _tab == 3,
                onTap: () => setState(() => _tab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? c.primary : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: c.outline, width: 1.5),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? c.onPrimary : c.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? c.onSurface : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
