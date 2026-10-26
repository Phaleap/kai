import 'package:flutter/material.dart';

import 'theme.dart';

/// Big soft card on the background.
class CoachCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  const CoachCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.cardPadding),
    this.color,
    this.radius = Radii.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.c.cardBorder, width: 1.0),
      ),
      child: child,
    );
  }
}

/// Small uppercase card label, e.g. "TODAY'S SESSION".
class Overline extends StatelessWidget {
  final String text;
  const Overline(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

/// Kai's round avatar.
class CoachAvatar extends StatelessWidget {
  final double size;
  const CoachAvatar({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.c.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        'K',
        style: TextStyle(
          color: context.c.onAccent,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

/// Round icon button (back, close, steppers, nav).
class RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color? background;
  final Color? foreground;

  const RoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? context.c.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.42,
              color: foreground ?? context.c.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill chip that can be selected (check-in, quick replies).
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool outlined;
  final double height;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.outlined = false,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bg = selected
        ? c.primary
        : (outlined ? Colors.transparent : c.surfaceAlt);
    final fg = selected ? c.onPrimary : c.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: outlined && !selected
              ? BorderSide(color: c.onSurface, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin progress segments (onboarding steps, exercises in a workout).
class SegmentBar extends StatelessWidget {
  final int total;
  final int done;
  final bool highlightCurrent;

  const SegmentBar({
    super.key,
    required this.total,
    required this.done,
    this.highlightCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.pill),
                color: i < done
                    ? c.success
                    : (highlightCurrent && i == done ? c.accent : c.outline),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact metric card for workout completion, progress, and history.
class StatMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const StatMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor ?? c.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: c.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact muscle group indicator badge.
class MuscleTag extends StatelessWidget {
  final String muscle;
  const MuscleTag({super.key, required this.muscle});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        muscle.toUpperCase(),
        style: TextStyle(
          color: c.accentText,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
