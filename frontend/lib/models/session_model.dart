class SessionModel {
  final String id;
  final String subject;
  final String topic;
  final int duration;
  int progress;
  bool done;

  SessionModel({
    required this.id,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.progress,
    required this.done,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final isCompleted = json['done'] ?? (json['status'] == 'completed');
    int dur = json['duration'] ?? 0;
    if (dur == 0 && json['startTime'] != null && json['endTime'] != null) {
      final start = DateTime.parse(json['startTime']);
      final end = DateTime.parse(json['endTime']);
      dur = end.difference(start).inMinutes;
    }

    return SessionModel(
      id: json['_id'] ?? json['id'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['title'] ?? json['topic'] ?? '',
      duration: dur,
      progress: json['progress'] ?? (isCompleted ? 100 : 60),
      done: isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    final now = DateTime.now();
    return {
      'id': id,
      '_id': id,
      'subject': subject,
      'title': topic,
      'topic': topic,
      'duration': duration,
      'progress': progress,
      'done': done,
      'status': done ? 'completed' : 'pending',
      'startTime': now.subtract(Duration(minutes: duration)).toIso8601String(),
      'endTime': now.toIso8601String(),
    };
  }
}
