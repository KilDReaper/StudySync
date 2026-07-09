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
    return SessionModel(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      duration: json['duration'] ?? 0,
      progress: json['progress'] ?? 0,
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'duration': duration,
      'progress': progress,
      'done': done,
    };
  }
}
