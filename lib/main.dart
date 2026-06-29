import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AgerApp());
}

// We use a global ValueNotifier for the MVP so any widget can swap the theme instantly.
// In a production app, this would live in a state management solution (like Riverpod or Bloc),
// but ValueNotifier is perfect and native for our current scope.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
// We also track the seed color so we can implement multiple custom themes later.
final ValueNotifier<Color> colorNotifier = ValueNotifier(Colors.deepPurple);

class AgerApp extends StatelessWidget {
  const AgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: colorNotifier,
          builder: (context, seedColor, _) {
            return MaterialApp(
              title: 'Ager',
              debugShowCheckedModeBanner: false,
              // Light Theme Configuration
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              // Dark Theme Configuration
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              // The mode is controlled by our ValueNotifier
              themeMode: currentMode,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
