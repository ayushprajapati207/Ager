class Habit {
  final String id;
  final String title;
  final List<String> completedDays;

  // The curly braces {} here are what allow us to use named parameters like "id:" and "title:"
  Habit({required this.id, required this.title, List<String>? completedDays})
    : completedDays =
          completedDays ?? []; // Defaults to an empty list for new habits

  // Translates the Habit into JSON text to save on the phone
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'completedDays': completedDays};
  }

  // Translates the JSON text back into a Habit object when the app opens
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      completedDays: List<String>.from(json['completedDays'] ?? []),
    );
  }
}
