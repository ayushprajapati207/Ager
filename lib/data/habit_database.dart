import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitDatabase {
  // This is the secret key we use to find our data on the phone
  static const String _storageKey = 'ager_user_habits';

  // 1. SAVE: Converts our List of Habits into a text string and saves it
  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();

    // Map each habit to JSON, then convert the whole list to a JSON string
    final String habitsJson = jsonEncode(
      habits.map((habit) => habit.toJson()).toList(),
    );

    // Save it to the phone!
    await prefs.setString(_storageKey, habitsJson);
  }

  // 2. LOAD: Reads the text string from the phone and turns it back into Habits
  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);

    // If it's the user's first time opening the app, return an empty list
    if (savedData == null) {
      return [];
    }

    // Otherwise, decode the text back into a list of Habit objects
    final List<dynamic> decodedData = jsonDecode(savedData);
    return decodedData.map((jsonMap) => Habit.fromJson(jsonMap)).toList();
  }
}
