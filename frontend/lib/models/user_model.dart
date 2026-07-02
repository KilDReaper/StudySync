class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final int studyStreak;
  final double totalStudyHours;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.studyStreak,
    required this.totalStudyHours,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      studyStreak: json['studyStreak'] ?? 0,
      totalStudyHours: (json['totalStudyHours'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'studyStreak': studyStreak,
      'totalStudyHours': totalStudyHours,
    };
  }
}
