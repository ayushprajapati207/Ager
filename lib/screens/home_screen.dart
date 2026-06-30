import 'package:flutter/material.dart';
import '../logic/habit_manager.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

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

  // A popup box to edit the habit's name
  void _showEditHabitDialog(String habitId, String currentTitle) {
    final textController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit Name'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Rename your habit'),
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
                _habitManager.editHabit(habitId, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // A safety confirmation prompt before deleting data permanently
  void _showDeleteConfirmationDialog(String habitId, String habitTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'Are you sure you want to permanently remove "$habitTitle"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _habitManager.deleteHabit(habitId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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

          return Column(
            children: [
              // 1. The GitHub-style Heatmap Grid Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: HeatMap(
                      // 1. Force it to show exactly the last 365 days
                      startDate: today.subtract(const Duration(days: 365)),
                      endDate: today,

                      // 2. Shrink the boxes down to look like GitHub (12-15 is the sweet spot)
                      size: 13,

                      // 3. Make the gaps between the boxes tighter
                      margin: const EdgeInsets.all(2),

                      // The rest remains exactly the same!
                      datasets: _habitManager.getHeatMapData(),
                      colorMode: ColorMode.color,
                      defaultColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      showColorTip: false,
                      showText: false,
                      scrollable: true,
                      colorsets: {
                        1: Theme.of(context).colorScheme.primary.withAlpha(50),
                        2: Theme.of(context).colorScheme.primary.withAlpha(100),
                        3: Theme.of(context).colorScheme.primary.withAlpha(180),
                        4: Theme.of(context).colorScheme.primary,
                      },
                    ),
                  ),
                ),
              ),

              // Divider between the Grid and the Habits list
              const Divider(),

              // 2. The Habit Checklist Section
              Expanded(
                child: habits.isEmpty
                    ? const Center(
                        child: Text('No habits yet. Tap + to add one!'),
                      )
                    : ListView.builder(
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
                            // We wrap the actions in a Row so they layout beautifully side by side
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // The standard tracking Checkbox
                                Checkbox(
                                  value: isCompletedToday,
                                  onChanged: (value) {
                                    _habitManager.toggleHabitCompletion(
                                      habit.id,
                                      today,
                                    );
                                  },
                                ),

                                // The new Management Options Menu (Three Vertical Dots)
                                PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      _showEditHabitDialog(
                                        habit.id,
                                        habit.title,
                                      );
                                    } else if (action == 'delete') {
                                      _showDeleteConfirmationDialog(
                                        habit.id,
                                        habit.title,
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
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
