import 'package:flutter/material.dart';
import '../logic/habit_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This connects this specific screen to our Brain
  final HabitManager _habitManager = HabitManager();

  @override
  void initState() {
    super.initState();
    // Tells the Brain to load saved data from the phone when the app opens
    _habitManager.loadHabits();
  }

  // A popup box to type in a new habit
  void _showAddHabitDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Habit'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'e.g., Read 10 pages'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _habitManager.addHabit(textController.text); // Save it!
                Navigator.pop(context); // Close the popup
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text('Ager Habits')),
      // ListenableBuilder automatically repaints the screen when the Brain says notifyListeners()
      body: ListenableBuilder(
        listenable: _habitManager,
        builder: (context, child) {
          final habits = _habitManager.habits;

          if (habits.isEmpty) {
            return const Center(
              child: Text('No habits yet. Tap + to add one!'),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isCompletedToday = habit.completedDays.contains(
                todayString,
              );

              return ListTile(
                title: Text(
                  habit.title,
                  style: TextStyle(
                    decoration: isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: Checkbox(
                  value: isCompletedToday,
                  onChanged: (value) {
                    _habitManager.toggleHabitCompletion(habit.id, today);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
