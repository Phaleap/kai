import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

void main() {
  runApp(CoachApp(state: AppState()));
}

class CoachApp extends StatelessWidget {
  final AppState state;
  const CoachApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Coach',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        // Follows the phone's light or dark setting.
        themeMode: ThemeMode.system,
        home: const _Start(),
      ),
    );
  }
}

/// Shows onboarding until the profile is filled in, then the main tabs.
class _Start extends StatelessWidget {
  const _Start();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return app.profile == null ? const OnboardingScreen() : const HomeShell();
  }
}
