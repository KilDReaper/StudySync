import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tracker_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  String _getInitials(String name) {
    if (name.isEmpty) return 'AJ';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, (parts[0].length >= 2 ? 2 : 1)).toUpperCase();
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTaskBottomSheet();
      },
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddHabitBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = user?.fullName ?? 'Alex Thompson';
    final userEmail = user?.email ?? 'alex@example.com';
    final initials = _getInitials(userName);

    // 5 Figma tabs list
    final List<Widget> children = [
      HomeTabView(userName: userName, initials: initials),
      PlannerTabView(onAddTask: () => _showAddTaskSheet(context)),
      const FocusTimerTabView(),
      HabitsTabView(
          onNewHabit: () => _showAddHabitSheet(context), userName: userName),
      ProfileTabView(
          userName: userName, userEmail: userEmail, initials: initials),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128), // Figma Deep Blue Background
      body: Stack(
        children: [
          // Sub-screen viewport
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 96.0), // Prevent bottom navbar clipping
              child: IndexedStack(
                index: _selectedIndex,
                children: children,
              ),
            ),
          ),

          // Custom 5-item Bottom Navigation Bar (Figma High Fidelity)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
                  _buildNavItem(1, Icons.calendar_month_rounded, 'Planner'),
                  _buildNavItem(2, Icons.timer_rounded, 'Timer'),
                  _buildNavItem(3, Icons.check_circle_rounded, 'Habits'),
                  _buildNavItem(4, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final themeColor =
        isSelected ? const Color(0xFF4D7DF2) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColor, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF4D7DF2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 1. DASHBOARD VIEW (HOME TAB VIEW)
// ==========================================================================
class HomeTabView extends StatelessWidget {
  final String userName;
  final String initials;

  const HomeTabView(
      {super.key, required this.userName, required this.initials});

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);

    return RefreshIndicator(
      onRefresh: () => trackerProvider.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting & Avatar Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning ☀️',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D7DF2), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Overview Stats Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    icon: Icons.menu_book_rounded,
                    iconBg: const Color(0xFFE0E9FE),
                    iconColor: const Color(0xFF3B82F6),
                    value:
                        '${trackerProvider.totalStudyHours.toStringAsFixed(1)}h',
                    label: 'Studied',
                  ),
                  _buildStatDivider(),
                  _buildStatColumn(
                    icon: Icons.track_changes_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    value: trackerProvider.habitsRatioString,
                    label: 'Habits',
                  ),
                  _buildStatDivider(),
                  _buildStatColumn(
                    icon: Icons.local_fire_department_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFF59E0B),
                    value: '${trackerProvider.streakPercentage}%',
                    label: 'Streak',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today's Sessions Section
            Text(
              "Today's Sessions",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            trackerProvider.sessions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132A60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No study sessions recorded for today.',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trackerProvider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = trackerProvider.sessions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () =>
                              trackerProvider.toggleSession(session.id),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: session.done
                                  ? Colors.white
                                  : const Color(0xFF132A60),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: session.done
                                    ? Colors.transparent
                                    : const Color(0xFF4D7DF2)
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.subject,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: session.done
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            session.topic,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              color: session.done
                                                  ? const Color(0xFF64748B)
                                                  : Colors.white
                                                      .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    session.done
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6FDF4),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.check_rounded,
                                                    color: Color(0xFF059669),
                                                    size: 12),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Done',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFF059669),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4D7DF2)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${session.duration} min',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF93C5FD),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: SizedBox(
                                    height: 6,
                                    child: LinearProgressIndicator(
                                      value: session.progress / 100.0,
                                      backgroundColor: session.done
                                          ? const Color(0xFFF1F5F9)
                                          : Colors.white.withValues(alpha: 0.1),
                                      color: session.done
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF4D7DF2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Daily Habits
            Text(
              "Daily Habits",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            trackerProvider.habits.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132A60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No habits created yet.',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 13),
                    ),
                  )
                : SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trackerProvider.habits.length,
                      itemBuilder: (context, index) {
                        final habit = trackerProvider.habits[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: InkWell(
                            onTap: () => trackerProvider.toggleHabit(habit.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 96,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: habit.done
                                    ? const Color(0xFF132A60)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: habit.done
                                      ? const Color(0xFF4D7DF2)
                                          .withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    habit.icon,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  Text(
                                    habit.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: habit.done
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Color(0xFFF97316),
                                          size: 12),
                                      Text(
                                        '${habit.streak}d',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFF97316),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),

            // Streak Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D7DF2), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You're on a ${trackerProvider.highestStreakCount}-day streak!",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trackerProvider.remainingHabitsCount > 0
                              ? "Complete ${trackerProvider.remainingHabitsCount} more habit${trackerProvider.remainingHabitsCount > 1 ? 's' : ''} to keep it going"
                              : "All daily habits completed! Awesome job! 🚀",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE2E8F0),
    );
  }
}

// ==========================================================================
// 2. PLANNER VIEW (SCHEDULE & TASKS TAB VIEW)
// ==========================================================================
class PlannerTabView extends StatelessWidget {
  final VoidCallback onAddTask;

  const PlannerTabView({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);

    final days = [
      {'name': 'M', 'num': '6', 'active': false},
      {'name': 'T', 'num': '7', 'active': false},
      {'name': 'W', 'num': '8', 'active': true},
      {'name': 'T', 'num': '9', 'active': false},
      {'name': 'F', 'num': '10', 'active': false},
      {'name': 'S', 'num': '11', 'active': false},
      {'name': 'S', 'num': '12', 'active': false},
    ];

    return RefreshIndicator(
      onRefresh: () => trackerProvider.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule Planner',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Task',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D7DF2),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Days selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((day) {
                  final bool active = day['active'] as bool;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          active ? const Color(0xFF4D7DF2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          day['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: active
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day['num'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                active ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Tasks Section
            Text(
              "Your Study Tasks",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            trackerProvider.tasks.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132A60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No tasks created. Click "+ Task" to create one!',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trackerProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = trackerProvider.tasks[index];
                      final isCompleted = task.status == 'completed';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A60),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.transparent
                                  : const Color(0xFF4D7DF2)
                                      .withValues(alpha: 0.15),
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: isCompleted,
                              onChanged: (_) =>
                                  trackerProvider.toggleTask(task.id),
                              activeColor: const Color(0xFF4D7DF2),
                              side: const BorderSide(
                                  color: Colors.white54, width: 2),
                            ),
                            title: Text(
                              task.title,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color:
                                    isCompleted ? Colors.white38 : Colors.white,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              task.subject.isNotEmpty
                                  ? task.subject
                                  : 'No subject',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isCompleted
                                    ? Colors.white24
                                    : Colors.white54,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: task.priority == 'high'
                                        ? const Color(0xFFFEE2E2)
                                        : task.priority == 'medium'
                                            ? const Color(0xFFFEF3C7)
                                            : const Color(0xFFE0E9FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.priority.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: task.priority == 'high'
                                          ? const Color(0xFFEF4444)
                                          : task.priority == 'medium'
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      trackerProvider.deleteTask(task.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 3. FOCUS TIMER VIEW (NEW TIMER TAB)
// ==========================================================================
class FocusTimerTabView extends StatefulWidget {
  const FocusTimerTabView({super.key});

  @override
  State<FocusTimerTabView> createState() => _FocusTimerTabViewState();
}

class _FocusTimerTabViewState extends State<FocusTimerTabView> {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes default
  int _focusDurationMinutes = 25;
  bool _isRunning = false;

  final List<String> _subjects = [
    'Advanced Macroeconomics',
    'Mathematics',
    'Physics',
    'Computer Science',
    'General Study'
  ];
  String _selectedSubject = 'Advanced Macroeconomics';

  final List<String> _quotes = [
    '"The secret of getting ahead is getting started."',
    '"It always seems impossible until it\'s done."',
    '"Focus on being productive instead of busy."',
    '"Your future is created by what you do today, not tomorrow."',
    '"Believe you can and you\'re halfway there."'
  ];
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _focusDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timerCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _focusDurationMinutes * 60;
      _quoteIndex = (_quoteIndex + 1) % _quotes.length; // Rotate quotes
    });
  }

  void _timerCompleted() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _focusDurationMinutes * 60;
    });

    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.addCompletedFocusSession(
      _selectedSubject,
      'Focus Session completed',
      _focusDurationMinutes,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF132A60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🎉 Session Complete!',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Great job! You focused on $_selectedSubject for $_focusDurationMinutes minutes. This session has been saved in MongoDB.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Awesome',
                style: GoogleFonts.outfit(
                    color: const Color(0xFF4D7DF2),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _changeDurationSetting() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedTemp = _focusDurationMinutes;
        return AlertDialog(
          backgroundColor: const Color(0xFF132A60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Timer Setup',
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [15, 25, 45, 60].map((mins) {
              return RadioListTile<int>(
                value: mins,
                groupValue: selectedTemp,
                title: Text('$mins Minutes',
                    style: GoogleFonts.inter(color: Colors.white)),
                activeColor: const Color(0xFF4D7DF2),
                onChanged: (val) {
                  if (val != null) {
                    Navigator.of(context).pop(val);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          _focusDurationMinutes = val;
          _secondsRemaining = val * 60;
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    final minStr = mins.toString().padLeft(2, '0');
    final secStr = secs.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_focusDurationMinutes * 60 - _secondsRemaining) /
        (_focusDurationMinutes * 60);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Focus Timer',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Focusing on selector card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF132A60),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded,
                    color: Color(0xFF4D7DF2), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSubject,
                      dropdownColor: const Color(0xFF132A60),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _subjects.map((sub) {
                        return DropdownMenuItem<String>(
                          value: sub,
                          child: Text(sub),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSubject = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),

          // Beautiful timer circle paint progress
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: TimerPainter(
                    progress: progress, color: const Color(0xFF4D7DF2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FOCUS SESSION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Control buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset button
              GestureDetector(
                onTap: _resetTimer,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: const Icon(Icons.replay_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 24),

              // Start/Pause action pill
              ElevatedButton.icon(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24),
                label: Text(
                  _isRunning ? 'Pause Timer' : 'Start Timer',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D7DF2),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
              ),
              const SizedBox(width: 24),

              // Settings button
              GestureDetector(
                onTap: _changeDurationSetting,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: const Icon(Icons.settings_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Quote at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              _quotes[_quoteIndex],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: Colors.white60,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angle = 2 * 3.1415926535 * (1.0 - progress);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      -angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ==========================================================================
// 4. HABITS TRACKER VIEW (NEW HABITS TAB)
// ==========================================================================
class HabitsTabView extends StatelessWidget {
  final VoidCallback onNewHabit;
  final String userName;

  const HabitsTabView(
      {super.key, required this.onNewHabit, required this.userName});

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);

    // Dynamic banner text
    final highestHabit = trackerProvider.habits.isNotEmpty
        ? trackerProvider.habits
            .reduce((curr, next) => curr.streak > next.streak ? curr : next)
        : null;

    final nameOnly = userName.split(' ')[0];

    return RefreshIndicator(
      onRefresh: () => trackerProvider.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Habits Tracker',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Consistency Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEEKLY PERFORMANCE',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Consistency Score',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${trackerProvider.streakPercentage}%',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4D7DF2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Performance Graph
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGraphBar('M', 0.6),
                      _buildGraphBar('T', 0.8),
                      _buildGraphBar('W', 0.4),
                      _buildGraphBar('T', 0.7),
                      _buildGraphBar('F', 0.9),
                      _buildGraphBar('S', 0.5),
                      _buildGraphBar('S', 0.2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Habits Title + NEW HABIT button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Habits',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: onNewHabit,
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Color(0xFF4D7DF2)),
                  label: Text(
                    'NEW HABIT',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D7DF2)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vertical list of habits
            trackerProvider.habits.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132A60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No habits created. Click "+ NEW HABIT" to start!',
                      style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trackerProvider.habits.length,
                    itemBuilder: (context, index) {
                      final habit = trackerProvider.habits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A60),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: habit.done
                                  ? Colors.transparent
                                  : const Color(0xFF4D7DF2)
                                      .withValues(alpha: 0.15),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0A1128),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(habit.icon,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                            title: Text(
                              habit.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '${habit.streak} Day Streak',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFF97316),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      trackerProvider.toggleHabit(habit.id),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: habit.done
                                          ? const Color(0xFF4D7DF2)
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.white54, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: habit.done
                                        ? const Icon(Icons.check_rounded,
                                            color: Colors.white, size: 18)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      trackerProvider.deleteHabit(habit.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Consistency Record Banner
            if (highestHabit != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D7DF2), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Keep going, $nameOnly! Completing your ${highestHabit.name.toLowerCase()} today will put you at a ${highestHabit.streak + 1}-day personal record.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphBar(String label, double val) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80 * val,
            decoration: BoxDecoration(
              color: const Color(0xFF4D7DF2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// 5. PROFILE VIEW (UPDATED FIGMA PROFILE SCREEN)
// ==========================================================================
class ProfileTabView extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String initials;

  const ProfileTabView({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trackerProvider = Provider.of<TrackerProvider>(context);

    final completedTasksRatio =
        (trackerProvider.tasksDonePercentage * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Central Profile details
          Center(
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D7DF2), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15), width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4D7DF2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            userName,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stanford University • Computer Science',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Badge pro plan
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4D7DF2), width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded,
                      color: Color(0xFF4D7DF2), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'PRO PLAN',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4D7DF2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Study Hours & Tasks Done Stats Cards side by side
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDY HOURS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trackerProvider.totalStudyHours.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Small blue visual bar indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          value: 0.75, // mock styling representation
                          backgroundColor: Colors.white10,
                          color: Color(0xFF4D7DF2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASKS DONE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$completedTasksRatio%',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Small green visual bar indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: trackerProvider.tasksDonePercentage,
                          backgroundColor: Colors.white10,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Preferences section title
          Text(
            'PREFERENCES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // Preferences cards
          _buildPrefCard(Icons.person_outline_rounded, 'Account Settings',
              'Manage personal info and security'),
          _buildPrefCard(Icons.notifications_none_rounded, 'Notifications',
              'Customize study alerts & reminders',
              trailing: 'ON'),
          _buildPrefCard(Icons.hourglass_empty_rounded,
              'Focus Mode Preferences', '25m Pomodoro, strict blocking'),
          _buildPrefCard(Icons.wb_sunny_outlined, 'Theme', 'Light Mode Active'),

          const SizedBox(height: 24),

          // Red outline Logout button
          OutlinedButton.icon(
            onPressed: () {
              authProvider.logout();
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              'Logout',
              style:
                  GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefCard(IconData icon, String title, String subtitle,
      {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF132A60),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4D7DF2), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailing,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4D7DF2),
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 6. ADD TASK BOTTOM SHEET (FIGMA COMPLIANT)
// ==========================================================================
class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  String _selectedSubject = 'Advanced Macroeconomics';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _priority = 'Low';

  final List<String> _subjects = [
    'Advanced Macroeconomics',
    'Mathematics',
    'Physics',
    'Computer Science',
    'General Study'
  ];

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);

    // Combine Date and Time
    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    trackerProvider.addTask(
      _taskNameController.text.trim(),
      _selectedSubject,
      dueDateTime,
      _priority,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Task',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task Name
              _buildInputLabel('TASK NAME'),
              TextFormField(
                controller: _taskNameController,
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration: _buildInputDecoration(
                    'e.g., Finalize Macroeconomics Essay'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Task name is required' : null,
              ),
              const SizedBox(height: 16),

              // Subject Dropdown
              _buildInputLabel('SUBJECT'),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                dropdownColor: Colors.white,
                style: GoogleFonts.inter(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold),
                decoration: _buildInputDecoration(''),
                items: _subjects.map((sub) {
                  return DropdownMenuItem(
                    value: sub,
                    child: Text(sub),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSubject = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Due Date & Time Side-by-Side
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('DUE DATE'),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 305)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF1E293B),
                                      fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('TIME'),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = time;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedTime.format(context),
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF1E293B),
                                      fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.access_time_rounded,
                                    size: 16, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority Selector
              _buildInputLabel('PRIORITY LEVEL'),
              Row(
                children: ['Low', 'Medium', 'High'].map((p) {
                  final isSel = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _priority = p;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isSel ? const Color(0xFFE0E9FE) : Colors.white,
                          side: BorderSide(
                            color: isSel
                                ? const Color(0xFF4D7DF2)
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          p,
                          style: GoogleFonts.inter(
                            color: isSel
                                ? const Color(0xFF4D7DF2)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D7DF2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Create Task',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4D7DF2), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ==========================================================================
// 7. ADD HABIT BOTTOM SHEET (COMPLEMENTARY)
// ==========================================================================
class AddHabitBottomSheet extends StatefulWidget {
  const AddHabitBottomSheet({super.key});

  @override
  State<AddHabitBottomSheet> createState() => _AddHabitBottomSheetState();
}

class _AddHabitBottomSheetState extends State<AddHabitBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  String _selectedEmoji = '📖';
  final List<String> _emojiOptions = ['📖', '🏃', '🧘', '💧', '🍎', '💻', '💤'];

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.addHabit(
      _habitNameController.text.trim(),
      _selectedEmoji,
      0,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Habit',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputLabel('HABIT NAME'),
              TextFormField(
                controller: _habitNameController,
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration:
                    _buildInputDecoration('e.g., Read 30 min, Exercise'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Habit name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildInputLabel('HABIT ICON/EMOJI'),
              DropdownButtonFormField<String>(
                initialValue: _selectedEmoji,
                dropdownColor: Colors.white,
                style: GoogleFonts.inter(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold),
                decoration: _buildInputDecoration(''),
                items: _emojiOptions.map((emoji) {
                  return DropdownMenuItem(
                    value: emoji,
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(_getEmojiName(emoji)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedEmoji = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D7DF2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Add Habit',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4D7DF2), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _getEmojiName(String emoji) {
    switch (emoji) {
      case '📖':
        return 'Book Reading';
      case '🏃':
        return 'Exercise / Workout';
      case '🧘':
        return 'Meditation';
      case '💧':
        return 'Water Hydration';
      case '🍎':
        return 'Healthy Eating';
      case '💻':
        return 'Coding Practice';
      case '💤':
        return 'Sleep Schedule';
      default:
        return 'Habit';
    }
  }
}
