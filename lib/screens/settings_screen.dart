import 'package:flutter/material.dart';
import '../main.dart'; // We import this to access our global theme and color notifiers

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Theme Mode Selection
          Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('System'),
                    selected: currentMode == ThemeMode.system,
                    onSelected: (_) => themeNotifier.value = ThemeMode.system,
                  ),
                  ChoiceChip(
                    label: const Text('Light'),
                    selected: currentMode == ThemeMode.light,
                    onSelected: (_) => themeNotifier.value = ThemeMode.light,
                  ),
                  ChoiceChip(
                    label: const Text('Dark'),
                    selected: currentMode == ThemeMode.dark,
                    onSelected: (_) => themeNotifier.value = ThemeMode.dark,
                  ),
                ],
              );
            },
          ),

          const Divider(height: 40),

          // 2. Accent Color Selection
          Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ValueListenableBuilder<Color>(
            valueListenable: colorNotifier,
            builder: (context, currentColor, child) {
              return Wrap(
                spacing: 10,
                children: [
                  _ColorChip(
                    color: Colors.deepPurple,
                    label: 'Purple',
                    currentColor: currentColor,
                  ),
                  _ColorChip(
                    color: Colors.teal,
                    label: 'Teal',
                    currentColor: currentColor,
                  ),
                  _ColorChip(
                    color: Colors.orange,
                    label: 'Orange',
                    currentColor: currentColor,
                  ),
                  _ColorChip(
                    color: Colors.blueGrey,
                    label: 'Slate',
                    currentColor: currentColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// A small helper widget to keep our color buttons clean
class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final Color currentColor;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: currentColor == color,
      // Gives a slight tint to the selected chip so it stands out
      selectedColor: color.withOpacity(0.3),
      onSelected: (_) => colorNotifier.value = color,
    );
  }
}
