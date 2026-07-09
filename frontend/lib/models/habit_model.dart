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
    return HabitModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📖',
      streak: json['streak'] ?? 0,
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'streak': streak,
      'done': done,
    };
  }
}
