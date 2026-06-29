import 'package:flutter/material.dart';

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
              home: const HomeShell(),
            );
          },
        );
      },
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ager'),
        centerTitle: true,
        actions: [
          // A simple button to toggle between Light and Dark mode
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ager MVP Starting...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const Text('Select Theme Color:'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _ColorButton(color: Colors.deepPurple, name: 'Purple'),
                _ColorButton(color: Colors.teal, name: 'Teal'),
                _ColorButton(color: Colors.orange, name: 'Orange'),
                _ColorButton(color: Colors.blueGrey, name: 'Slate'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final String name;

  const _ColorButton({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        colorNotifier.value = color;
      },
      child: Text(name),
    );
  }
}