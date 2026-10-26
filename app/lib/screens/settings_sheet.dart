import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final profile = AppScope.of(context).profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.c;
    final text = Theme.of(context).textTheme;
    final profile = app.profile;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: c.cardBorder),
      ),
      padding: EdgeInsets.fromLTRB(
        Space.gutter,
        16,
        Space.gutter,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile & Settings', style: text.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name field
            const Overline('Your Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: c.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.bubble),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty && profile != null) {
                  app.updateProfile(
                    Profile(
                      name: val.trim(),
                      goal: profile.goal,
                      experience: profile.experience,
                      daysPerWeek: profile.daysPerWeek,
                      injuries: profile.injuries,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Training Goal
            const Overline('Goal'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final goal in ['Build muscle', 'Lose fat', 'Get fitter'])
                  PillChip(
                    label: goal,
                    selected: (profile?.goal ?? '') == goal,
                    onTap: () {
                      if (profile != null) {
                        app.updateProfile(
                          Profile(
                            name: _nameCtrl.text.trim().isNotEmpty
                                ? _nameCtrl.text.trim()
                                : profile.name,
                            goal: goal,
                            experience: profile.experience,
                            daysPerWeek: profile.daysPerWeek,
                            injuries: profile.injuries,
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Training Days per Week
            const Overline('Training Schedule'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final days in [2, 3, 4, 5])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PillChip(
                        label: '$days days',
                        selected: (profile?.daysPerWeek ?? 3) == days,
                        onTap: () {
                          if (profile != null) {
                            app.updateProfile(
                              Profile(
                                name: _nameCtrl.text.trim().isNotEmpty
                                    ? _nameCtrl.text.trim()
                                    : profile.name,
                                goal: profile.goal,
                                experience: profile.experience,
                                daysPerWeek: days,
                                injuries: profile.injuries,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Weight Units Toggle
            const Overline('Weight Unit'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: PillChip(
                    label: 'Kilograms (kg)',
                    selected: app.weightUnit == 'kg',
                    onTap: () => app.setWeightUnit('kg'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PillChip(
                    label: 'Pounds (lbs)',
                    selected: app.weightUnit == 'lbs',
                    onTap: () => app.setWeightUnit('lbs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Status & Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(Radii.bubble),
              ),
              child: Row(
                children: [
                  const CoachAvatar(size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coach Kai AI Engine',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Connected to 127.0.0.1:8000 (with smart local fallback)',
                          style: TextStyle(
                            fontSize: 11,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: () {
                if (_nameCtrl.text.trim().isNotEmpty && profile != null) {
                  app.updateProfile(
                    Profile(
                      name: _nameCtrl.text.trim(),
                      goal: profile.goal,
                      experience: profile.experience,
                      daysPerWeek: profile.daysPerWeek,
                      injuries: profile.injuries,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save & Close'),
            ),
          ],
        ),
      ),
    );
  }
}
