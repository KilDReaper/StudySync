class HabitModel {
  final String id;
  final String name;
  final String icon;
  int streak;
  bool done;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.streak,
    required this.done,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    bool isCompletedToday = false;
    if (json['done'] != null) {
      isCompletedToday = json['done'];
    } else if (json['completedDates'] != null) {
      final List<dynamic> dates = json['completedDates'];
      final todayStr = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      isCompletedToday = dates.any((date) => date.toString().startsWith(todayStr));
    }

    return HabitModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['title'] ?? json['name'] ?? '',
      icon: json['icon'] ?? '📖',
      streak: json['streakCount'] ?? json['streak'] ?? 0,
      done: isCompletedToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'title': name,
      'name': name,
      'icon': icon,
      'streakCount': streak,
      'streak': streak,
      'done': done,
    };
  }
}
