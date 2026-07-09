import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../models/habit_model.dart';

class TrackerProvider extends ChangeNotifier {
  List<SessionModel> _sessions = [];
  List<HabitModel> _habits = [];

  List<SessionModel> get sessions => _sessions;
  List<HabitModel> get habits => _habits;

  // Load data from SharedPreferences or initialize default mock data
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final sessionsJson = prefs.getString('ss_sessions');
    final habitsJson = prefs.getString('ss_habits');

    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      _sessions = decoded.map((item) => SessionModel.fromJson(item)).toList();
    } else {
      _sessions = [
        SessionModel(
          id: 'session-1',
          subject: 'Mathematics',
          topic: 'Calculus — Derivatives',
          duration: 45,
          progress: 60,
          done: false,
        ),
        SessionModel(
          id: 'session-2',
          subject: 'Physics',
          topic: 'Wave Mechanics',
          duration: 60,
          progress: 100,
          done: true,
        ),
      ];
    }

    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      _habits = decoded.map((item) => HabitModel.fromJson(item)).toList();
    } else {
      _habits = [
        HabitModel(
          id: 'habit-1',
          name: 'Read 30 min',
          icon: '📖',
          streak: 7,
          done: true,
        ),
        HabitModel(
          id: 'habit-2',
          name: 'Exercise',
          icon: '🏃',
          streak: 14,
          done: true,
        ),
        HabitModel(
          id: 'habit-3',
          name: 'Meditate',
          icon: '🧘',
          streak: 3,
          done: false,
        ),
        HabitModel(
          id: 'habit-4',
          name: 'Water 8 cups',
          icon: '💧',
          streak: 21,
          done: false,
        ),
      ];
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final sessionsJson = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    final habitsJson = jsonEncode(_habits.map((h) => h.toJson()).toList());

    await prefs.setString('ss_sessions', sessionsJson);
    await prefs.setString('ss_habits', habitsJson);
  }

  // Toggle study session done status
  void toggleSession(String id) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].done = !_sessions[index].done;
      if (_sessions[index].done) {
        _sessions[index].progress = 100;
      } else {
        _sessions[index].progress = 60; // Mock default progress for active card
      }
      saveData();
      notifyListeners();
    }
  }

  // Toggle habit done status
  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].done = !_habits[index].done;
      if (_habits[index].done) {
        _habits[index].streak += 1;
      } else {
        _habits[index].streak = (_habits[index].streak - 1).clamp(0, 999);
      }
      saveData();
      notifyListeners();
    }
  }

  // Add a new session
  void addSession(String subject, String topic, int duration) {
    final newSession = SessionModel(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      subject: subject,
      topic: topic,
      duration: duration,
      progress: 0,
      done: false,
    );
    _sessions.add(newSession);
    saveData();
    notifyListeners();
  }

  // Add a new habit
  void addHabit(String name, String icon, int streak) {
    final newHabit = HabitModel(
      id: 'habit-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      streak: streak,
      done: false,
    );
    _habits.add(newHabit);
    saveData();
    notifyListeners();
  }

  // --- Computed Stats ---
  
  // Hours studied (duration sum of completed sessions in hours)
  double get totalStudyHours {
    final totalMinutes = _sessions.fold<int>(0, (sum, item) {
      return item.done ? sum + item.duration : sum;
    });
    return totalMinutes / 60.0;
  }

  // Habits completed ratio (e.g., "5/7")
  String get habitsRatioString {
    final completed = _habits.where((h) => h.done).length;
    // The Figma defaults show "5/7" in the dashboard, so if habits are 4, we display completed/total
    // Let's use actual counts
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
    return _habits.fold<int>(0, (max, item) => item.streak > max ? item.streak : max);
  }

  // Remaining habits to complete today
  int get remainingHabitsCount {
    return _habits.where((h) => !h.done).length;
  }
}
