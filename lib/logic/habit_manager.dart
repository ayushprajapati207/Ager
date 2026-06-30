import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../data/habit_database.dart';

class HabitManager extends ChangeNotifier {
  final HabitDatabase _database = HabitDatabase();
  List<Habit> _habits = [];

  // This lets our UI read the habits, but not accidentally overwrite them
  List<Habit> get habits => _habits;

  // 1. LOAD: Fetch habits when the app opens and tell the UI to paint them
  Future<void> loadHabits() async {
    _habits = await _database.loadHabits();
    notifyListeners(); // This magic command tells the screen to refresh!
  }

  // 2. ADD: Create a new habit, save it to the database, and refresh UI
  Future<void> addHabit(String title) async {
    final newHabit = Habit(
      id: const Uuid().v4(), // Generates a unique, random ID
      title: title,
    );
    _habits.add(newHabit);
    await _database.saveHabits(_habits);
    notifyListeners();
  }

  // 3. TOGGLE: Check or uncheck a habit for a specific day
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    // Find the exact habit the user tapped
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = _habits[habitIndex];

      // Format the date to match our YYYY-MM-DD standard
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // If it's already checked, uncheck it. Otherwise, check it.
      if (habit.completedDays.contains(dateString)) {
        habit.completedDays.remove(dateString);
      } else {
        habit.completedDays.add(dateString);
      }

      // Save the change and refresh the screen
      await _database.saveHabits(_habits);
      notifyListeners();
    }
  }

  Map<DateTime, int> getHeatMapData() {
    Map<DateTime, int> dataset = {};

    for (var habit in _habits) {
      for (var dateString in habit.completedDays) {
        // Parse the YYYY-MM-DD string back into a DateTime object
        DateTime date = DateTime.parse(dateString);

        // Normalize the date to midnight to ensure exact matching
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        // If the date already has a habit, increase its intensity. Otherwise, start at 1.
        if (dataset.containsKey(normalizedDate)) {
          dataset[normalizedDate] = dataset[normalizedDate]! + 1;
        } else {
          dataset[normalizedDate] = 1;
        }
      }
    }
    return dataset;
  }
}
