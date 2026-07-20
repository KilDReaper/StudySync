import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/habit_model.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TrackerProvider extends ChangeNotifier {
  List<SessionModel> _sessions = [];
  List<HabitModel> _habits = [];
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<SessionModel> get sessions => _sessions;
  List<HabitModel> get habits => _habits;
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Load data from the MongoDB backend API
  Future<void> loadData() async {
    _isLoading = true;
    // Don't call notifyListeners here if called during build,
    // but tryAutoLogin / main call is fine. To be safe, delay it.
    Future.microtask(() => notifyListeners());

    try {
      final responses = await Future.wait([
        ApiService.get('/study-sessions'),
        ApiService.get('/habits'),
        ApiService.get('/tasks'),
      ]);

      final sessionsRes = responses[0];
      final habitsRes = responses[1];
      final tasksRes = responses[2];

      if (sessionsRes.statusCode == 200) {
        final body = jsonDecode(sessionsRes.body);
        final List<dynamic> decoded = body['data']['sessions'] ?? [];
        _sessions = decoded.map((item) => SessionModel.fromJson(item)).toList();
      }

      if (habitsRes.statusCode == 200) {
        final body = jsonDecode(habitsRes.body);
        final List<dynamic> decoded = body['data']['habits'] ?? [];
        _habits = decoded.map((item) => HabitModel.fromJson(item)).toList();
      }

      if (tasksRes.statusCode == 200) {
        final body = jsonDecode(tasksRes.body);
        final List<dynamic> decoded = body['data']['tasks'] ?? [];
        _tasks = decoded.map((item) => TaskModel.fromJson(item)).toList();
      }
    } catch (e) {
      // Keep existing data or silent fail
    }

    _isLoading = false;
    notifyListeners();
  }

  // Toggle study session done status
  Future<void> toggleSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final session = _sessions[index];
      final newDone = !session.done;
      session.done = newDone;
      session.progress = newDone ? 100 : 60;
      notifyListeners();

      try {
        if (newDone) {
          await ApiService.patch('/study-sessions/$id/complete', {});
        } else {
          await ApiService.patch('/study-sessions/$id', {'status': 'pending'});
        }
      } catch (e) {
        // failed silently
      }
      loadData();
    }
  }

  // Toggle habit done status
  Future<void> toggleHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final newDone = !habit.done;
      habit.done = newDone;
      if (newDone) {
        habit.streak += 1;
      } else {
        habit.streak = (habit.streak - 1).clamp(0, 999);
      }
      notifyListeners();

      try {
        // Backend handles completedDates array push inside markHabitComplete
        await ApiService.patch('/habits/$id/complete', {});
      } catch (e) {
        // error
      }
      loadData();
    }
  }

  // Toggle task completed status
  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = task.status == 'completed' ? 'pending' : 'completed';
      task.status = newStatus;
      notifyListeners();

      try {
        await ApiService.patch('/tasks/$id', {
          'status': newStatus,
        });
      } catch (e) {
        // error
      }
      loadData();
    }
  }

  // Add a new study session
  Future<void> addSession(String subject, String topic, int duration) async {
    final now = DateTime.now();
    try {
      await ApiService.post('/study-sessions', {
        'title': topic,
        'description': 'Focus Session',
        'subject': subject,
        'startTime':
            now.subtract(Duration(minutes: duration)).toIso8601String(),
        'endTime': now.toIso8601String(),
        'priority': 'medium',
        'status': 'pending',
      });
      loadData();
    } catch (e) {
      // error
    }
  }

  // Add a new completed focus session (from focus timer completion)
  Future<void> addCompletedFocusSession(
      String subject, String topic, int durationInMinutes) async {
    final now = DateTime.now();
    try {
      final res = await ApiService.post('/study-sessions', {
        'title': topic,
        'description': 'Focus Session completed via Timer',
        'subject': subject,
        'startTime': now
            .subtract(Duration(minutes: durationInMinutes))
            .toIso8601String(),
        'endTime': now.toIso8601String(),
        'priority': 'high',
        'status': 'completed',
      });

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final sessionId =
            body['data']['session']['_id'] ?? body['data']['session']['id'];
        if (sessionId != null) {
          // Invoke the specific completion endpoint to increment hours studied on backend
          await ApiService.patch('/study-sessions/$sessionId/complete', {});
        }
      }
      loadData();
    } catch (e) {
      // error
    }
  }

  // Add a new habit
  Future<void> addHabit(String name, String icon, int streak) async {
    try {
      await ApiService.post('/habits', {
        'title': name,
        'icon': icon,
      });
      loadData();
    } catch (e) {
      // error
    }
  }

  // Add a new task
  Future<void> addTask(
      String title, String subject, DateTime dueDate, String priority) async {
    try {
      await ApiService.post('/tasks', {
        'title': title,
        'description': 'Subject: $subject',
        'subject': subject,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.toLowerCase(),
        'status': 'pending',
      });
      loadData();
    } catch (e) {
      // error
    }
  }

  // Delete study session
  Future<void> deleteSession(String id) async {
    try {
      await ApiService.delete('/study-sessions/$id');
      loadData();
    } catch (e) {
      // error
    }
  }

  // Delete habit
  Future<void> deleteHabit(String id) async {
    try {
      await ApiService.delete('/habits/$id');
      loadData();
    } catch (e) {
      // error
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      await ApiService.delete('/tasks/$id');
      loadData();
    } catch (e) {
      // error
    }
  }

  // --- Computed Stats ---

  // Hours studied (duration sum of completed sessions in hours)
  double get totalStudyHours {
    final totalMinutes = _sessions.fold<int>(0, (sum, item) {
      return item.done ? sum + item.duration : sum;
    });
    return totalMinutes / 60.0;
  }

  // Tasks completed percentage
  double get tasksDonePercentage {
    if (_tasks.isEmpty) return 0.0;
    final completed = _tasks.where((t) => t.status == 'completed').length;
    return (completed / _tasks.length);
  }

  // Habits completed ratio (e.g., "5/7")
  String get habitsRatioString {
    final completed = _habits.where((h) => h.done).length;
    return '$completed/${_habits.length}';
  }

  // Streak percentage: based on habit completion percentage
  int get streakPercentage {
    if (_habits.isEmpty) return 0;
    final completed = _habits.where((h) => h.done).length;
    return ((completed / _habits.length) * 100).round();
  }

  // Highest streak count among habits
  int get highestStreakCount {
    if (_habits.isEmpty) return 0;
    return _habits.fold<int>(
        0, (max, item) => item.streak > max ? item.streak : max);
  }

  // Remaining habits to complete today
  int get remainingHabitsCount {
    return _habits.where((h) => !h.done).length;
  }
}
